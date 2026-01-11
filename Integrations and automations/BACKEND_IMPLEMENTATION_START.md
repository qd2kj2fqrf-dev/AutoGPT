# BACKEND IMPLEMENTATION - QUICK START GUIDE

## 🚀 Getting Started with Node.js + TypeScript

### 1. Project Initialization

```bash
# Create project directory
mkdir integrations-backend
cd integrations-backend

# Initialize Node project
npm init -y

# Add TypeScript
npm install -D typescript ts-node @types/node

# Generate tsconfig.json
npx tsc --init

# Create directory structure
mkdir -p src/{routes,services,middleware,models,config,utils}
mkdir -p tests
```

### 2. Core Dependencies

```bash
# Web framework
npm install express cors dotenv helmet

# Database & ORM
npm install pg typeorm reflect-metadata

# Authentication
npm install jsonwebtoken bcryptjs passport passport-jwt

# Utilities
npm install uuid crypto-js class-validator class-transformer

# Real-time
npm install socket.io socket.io-client

# Validation
npm install joi

# Logging
npm install winston winston-daily-rotate-file

# Testing
npm install -D jest @types/jest ts-jest supertest @types/supertest
```

### 3. Environment Setup

```bash
# Create .env file
cat > .env << 'EOF'
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/integrations_db

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Encryption
ENCRYPTION_KEY=32-character-encryption-key-here

# OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-secret
APPLE_TEAM_ID=your-apple-team-id
MICROSOFT_CLIENT_ID=your-microsoft-id
MICROSOFT_CLIENT_SECRET=your-microsoft-secret

# File Storage
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
S3_BUCKET=integrations-studio

# Email (for notifications)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-key
EOF
```

---

## 🔧 Core Implementation Files

### 1. Main Application Entry Point

```typescript
// src/main.ts
import 'reflect-metadata'
import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import dotenv from 'dotenv'
import { createServer } from 'http'
import { Server as SocketIOServer } from 'socket.io'
import { AppDataSource } from './config/database'
import { errorHandler } from './middleware/errorHandler'
import authRoutes from './routes/auth'
import flowRoutes from './routes/flows'
import integrationRoutes from './routes/integrations'
import { authenticate } from './middleware/auth'

dotenv.config()

const app: Application = express()
const httpServer = createServer(app)
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: [
      'http://localhost:3000',
      'http://localhost:3001',
      'tauri://localhost', // Windows/macOS Tauri
    ],
    credentials: true,
  },
})

// Middleware
app.use(helmet())
app.use(cors())
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ limit: '10mb', extended: true }))

// Initialize database
AppDataSource.initialize().then(() => {
  console.log('✓ Database connected')
}).catch(error => {
  console.error('✗ Database connection failed:', error)
  process.exit(1)
})

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() })
})

// Routes
app.use('/api/v1/auth', authRoutes)
app.use('/api/v1/integrations', authenticate, integrationRoutes)
app.use('/api/v1/flows', authenticate, flowRoutes)

// WebSocket
io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`)
  
  socket.on('flow:execute', async (flowId) => {
    socket.emit('flow:executing', { flowId })
    // Execute flow, stream results
    socket.emit('flow:completed', { flowId, status: 'success' })
  })
  
  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`)
  })
})

// Error handling
app.use(errorHandler)

// Start server
const PORT = process.env.PORT || 3000
httpServer.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`)
})

export default app
```

### 2. Database Configuration

```typescript
// src/config/database.ts
import { DataSource } from 'typeorm'
import { User } from '../entities/User'
import { Integration } from '../entities/Integration'
import { AutomationFlow } from '../entities/AutomationFlow'
import { AutomationNode } from '../entities/AutomationNode'
import { ExecutionLog } from '../entities/ExecutionLog'

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  synchronize: process.env.NODE_ENV === 'development',
  logging: false,
  entities: [User, Integration, AutomationFlow, AutomationNode, ExecutionLog],
  subscribers: [],
  migrations: ['src/migrations/**/*.ts'],
})
```

### 3. User Entity

```typescript
// src/entities/User.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm'
import { Integration } from './Integration'
import { AutomationFlow } from './AutomationFlow'

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ unique: true })
  email: string

  @Column()
  name: string

  @Column()
  passwordHash: string

  @Column({ nullable: true })
  avatarUrl: string

  @Column({ default: 'copper-tide' })
  theme: 'copper-tide' | 'mint-voltage' | 'solar-drift'

  @Column({ type: 'jsonb', default: {} })
  preferences: Record<string, any>

  @Column({ type: 'jsonb', default: {} })
  oauthProviders: Record<string, any>

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date

  @OneToMany(() => Integration, integration => integration.user)
  integrations: Integration[]

  @OneToMany(() => AutomationFlow, flow => flow.user)
  flows: AutomationFlow[]
}
```

### 4. Authentication Service

```typescript
// src/services/AuthService.ts
import { Repository } from 'typeorm'
import { AppDataSource } from '../config/database'
import { User } from '../entities/User'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'

export class AuthService {
  private userRepository: Repository<User>

  constructor() {
    this.userRepository = AppDataSource.getRepository(User)
  }

  async register(email: string, name: string, password: string) {
    const existing = await this.userRepository.findOne({ where: { email } })
    if (existing) throw new Error('Email already registered')

    const passwordHash = await bcrypt.hash(password, 12)
    const user = this.userRepository.create({
      email,
      name,
      passwordHash,
    })

    await this.userRepository.save(user)
    return this.generateTokens(user)
  }

  async login(email: string, password: string) {
    const user = await this.userRepository.findOne({ where: { email } })
    if (!user) throw new Error('Invalid credentials')

    const isValid = await bcrypt.compare(password, user.passwordHash)
    if (!isValid) throw new Error('Invalid credentials')

    return this.generateTokens(user)
  }

  private generateTokens(user: User) {
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: process.env.JWT_EXPIRY || '15m' }
    )

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET!,
      { expiresIn: process.env.JWT_REFRESH_EXPIRY || '7d' }
    )

    return { accessToken, refreshToken, user }
  }

  verifyToken(token: string): any {
    return jwt.verify(token, process.env.JWT_SECRET!)
  }
}
```

### 5. Authentication Routes

```typescript
// src/routes/auth.ts
import { Router, Request, Response, NextFunction } from 'express'
import { AuthService } from '../services/AuthService'

const router = Router()
const authService = new AuthService()

router.post('/register', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, name, password } = req.body
    const result = await authService.register(email, name, password)
    res.status(201).json(result)
  } catch (error) {
    next(error)
  }
})

router.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body
    const result = await authService.login(email, password)
    res.json(result)
  } catch (error) {
    next(error)
  }
})

router.post('/refresh-token', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body
    // Verify refresh token and issue new access token
    res.json({ /* new tokens */ })
  } catch (error) {
    next(error)
  }
})

export default router
```

### 6. Authentication Middleware

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'

export interface AuthRequest extends Request {
  userId?: string
  user?: any
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing authorization header' })
  }

  const token = authHeader.slice(7)
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!)
    req.userId = decoded.userId
    req.user = decoded
    next()
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' })
  }
}
```

### 7. Error Handling Middleware

```typescript
// src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express'

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(error)

  if (error.message === 'Invalid credentials') {
    return res.status(401).json({ error: 'Invalid credentials' })
  }

  if (error.message === 'Email already registered') {
    return res.status(409).json({ error: 'Email already registered' })
  }

  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : undefined,
  })
}
```

### 8. Package.json Scripts

```json
{
  "scripts": {
    "dev": "ts-node --require dotenv/config src/main.ts",
    "build": "tsc",
    "start": "node dist/main.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "typeorm": "typeorm-ts-node-esm",
    "migration:generate": "typeorm migration:generate",
    "migration:run": "typeorm migration:run",
    "migration:revert": "typeorm migration:revert",
    "lint": "eslint src --ext .ts"
  }
}
```

---

## 🗄️ Create Initial Database Tables

```bash
# Connect to PostgreSQL
psql -U user -d integrations_db

# Run migrations
npm run migration:run
```

---

## ✅ Testing Backend

```bash
# Install test dependencies
npm install -D jest @types/jest ts-jest supertest

# Create jest config
cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.ts'],
}
EOF

# Create sample test
cat > tests/auth.test.ts << 'EOF'
import { AuthService } from '../src/services/AuthService'

describe('AuthService', () => {
  const authService = new AuthService()

  it('should register a new user', async () => {
    const result = await authService.register(
      'test@example.com',
      'Test User',
      'password123'
    )
    expect(result.user.email).toBe('test@example.com')
    expect(result.accessToken).toBeDefined()
  })
})
EOF

# Run tests
npm test
```

---

## 🚀 Next Steps

1. **Implement remaining entities** (Integration, AutomationFlow, AutomationNode)
2. **Create integration routes** (CRUD operations)
3. **Create flow routes** (flow execution engine)
4. **Add WebSocket handlers** (real-time updates)
5. **Set up logging** (Winston)
6. **Add validation** (Joi schemas)
7. **Implement OAuth** (Google, Apple, Microsoft)
8. **Deploy to cloud** (Docker → AWS/Azure)

**Status:** Backend scaffold complete ✅  
**Ready for:** Entity development and route implementation

