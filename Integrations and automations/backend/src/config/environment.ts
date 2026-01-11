import dotenv from 'dotenv';

dotenv.config();

export interface ServiceConfig {
  name: string;
  port: number;
  type: 'fuel' | 'auto' | 'pricing' | 'analytics' | 'scanning';
  baseUrl?: string;
}

export const JRD_SERVICES: ServiceConfig[] = [
  { name: 'JRD Fuel', port: 8001, type: 'fuel' },
  { name: 'JRD Auto', port: 8002, type: 'auto' },
  { name: 'Price-O-Tron', port: 8003, type: 'pricing' },
  { name: 'Jumbotron', port: 8004, type: 'analytics' },
  { name: 'Scanotron', port: 8005, type: 'scanning' },
];

export const config = {
  // Server
  port: parseInt(process.env.PORT || '3001', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  // Database
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'petrowise',
  },

  // API Discovery
  discovery: {
    scanTimeout: parseInt(process.env.SCAN_TIMEOUT || '5000', 10),
    retryAttempts: parseInt(process.env.RETRY_ATTEMPTS || '3', 10),
    retryDelay: parseInt(process.env.RETRY_DELAY || '1000', 10),
    services: JRD_SERVICES,
  },

  // WebSocket
  websocket: {
    cors: {
      origin: process.env.WS_CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
  },

  // Logging
  logging: {
    level: process.env.LOG_LEVEL || 'info',
  },
};

export default config;
