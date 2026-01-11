import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum EndpointType {
  REST_API = 'rest_api',
  GRAPHQL = 'graphql',
  WEBSOCKET = 'websocket',
  GRPC = 'grpc',
  SOAP = 'soap',
  DATABASE = 'database',
  FILE_SYSTEM = 'file_system',
  MESSAGE_QUEUE = 'message_queue',
  FTP = 'ftp',
  SFTP = 'sftp',
}

export enum EndpointStatus {
  DISCOVERED = 'discovered',
  VALIDATED = 'validated',
  ACTIVE = 'active',
  DEGRADED = 'degraded',
  OFFLINE = 'offline',
  ERROR = 'error',
  DEPRECATED = 'deprecated',
}

export enum AuthenticationType {
  NONE = 'none',
  API_KEY = 'api_key',
  BEARER_TOKEN = 'bearer_token',
  BASIC_AUTH = 'basic_auth',
  OAUTH2 = 'oauth2',
  CERTIFICATE = 'certificate',
  CUSTOM = 'custom',
}

export enum DataCategory {
  FUEL_TRANSACTIONS = 'fuel_transactions',
  FUEL_INVENTORY = 'fuel_inventory',
  FUEL_DELIVERY = 'fuel_delivery',
  FUEL_PRICING = 'fuel_pricing',
  AUTO_WORK_ORDERS = 'auto_work_orders',
  AUTO_INVENTORY = 'auto_inventory',
  AUTO_SCHEDULING = 'auto_scheduling',
  CUSTOMER_DATA = 'customer_data',
  PAYMENT_DATA = 'payment_data',
  EMPLOYEE_DATA = 'employee_data',
  REPORTING = 'reporting',
  CONFIGURATION = 'configuration',
  OTHER = 'other',
}

@Entity('discovered_endpoints')
@Index(['status', 'lastHealthCheck'])
@Index(['sourceSystem', 'dataCategory'])
@Index(['siteId'])
export class DiscoveredEndpoint {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Identification
  @Column({ type: 'varchar', length: 100 })
  @Index()
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 50 })
  @Index()
  sourceSystem: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  siteId: string;

  // Endpoint details
  @Column({ type: 'enum', enum: EndpointType })
  endpointType: EndpointType;

  @Column({ type: 'varchar', length: 500 })
  baseUrl: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  path: string;

  @Column({ type: 'varchar', length: 10, nullable: true })
  httpMethod: string;

  @Column({ type: 'int', nullable: true })
  port: number;

  // Status and health
  @Column({ type: 'enum', enum: EndpointStatus, default: EndpointStatus.DISCOVERED })
  status: EndpointStatus;

  @Column({ type: 'timestamp with time zone', nullable: true })
  lastHealthCheck: Date;

  @Column({ type: 'int', nullable: true })
  lastResponseTimeMs: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  uptimePercentage: number;

  @Column({ type: 'int', default: 0 })
  consecutiveFailures: number;

  @Column({ type: 'text', nullable: true })
  lastErrorMessage: string;

  @Column({ type: 'timestamp with time zone', nullable: true })
  lastSuccessfulCall: Date;

  // Authentication
  @Column({ type: 'enum', enum: AuthenticationType, default: AuthenticationType.NONE })
  authenticationType: AuthenticationType;

  @Column({ type: 'jsonb', nullable: true })
  authenticationConfig: AuthenticationConfig;

  @Column({ type: 'boolean', default: false })
  requiresMfa: boolean;

  // Data characteristics
  @Column({ type: 'enum', enum: DataCategory })
  dataCategory: DataCategory;

  @Column({ type: 'simple-array', nullable: true })
  dataFields: string[];

  @Column({ type: 'boolean', default: false })
  supportsRealtime: boolean;

  @Column({ type: 'boolean', default: false })
  supportsBatch: boolean;

  @Column({ type: 'boolean', default: false })
  supportsWebhooks: boolean;

  @Column({ type: 'int', nullable: true })
  rateLimitPerMinute: number;

  @Column({ type: 'int', nullable: true })
  maxBatchSize: number;

  // Polling configuration
  @Column({ type: 'int', nullable: true })
  pollIntervalSeconds: number;

  @Column({ type: 'timestamp with time zone', nullable: true })
  lastPolledAt: Date;

  @Column({ type: 'timestamp with time zone', nullable: true })
  nextPollAt: Date;

  @Column({ type: 'boolean', default: true })
  pollingEnabled: boolean;

  // Schema information
  @Column({ type: 'jsonb', nullable: true })
  requestSchema: Record<string, unknown>;

  @Column({ type: 'jsonb', nullable: true })
  responseSchema: Record<string, unknown>;

  @Column({ type: 'varchar', length: 50, nullable: true })
  responseFormat: string;

  // Transformation
  @Column({ type: 'jsonb', nullable: true })
  fieldMappings: FieldMapping[];

  @Column({ type: 'text', nullable: true })
  transformationScript: string;

  // Discovery metadata
  @Column({ type: 'varchar', length: 50, nullable: true })
  discoveryMethod: string;

  @Column({ type: 'timestamp with time zone' })
  discoveredAt: Date;

  @Column({ type: 'varchar', length: 100, nullable: true })
  discoveredBy: string;

  @Column({ type: 'boolean', default: false })
  isManuallyConfigured: boolean;

  @Column({ type: 'boolean', default: false })
  isVerified: boolean;

  @Column({ type: 'varchar', length: 100, nullable: true })
  verifiedBy: string;

  @Column({ type: 'timestamp with time zone', nullable: true })
  verifiedAt: Date;

  // Metrics
  @Column({ type: 'bigint', default: 0 })
  totalRequests: number;

  @Column({ type: 'bigint', default: 0 })
  successfulRequests: number;

  @Column({ type: 'bigint', default: 0 })
  failedRequests: number;

  @Column({ type: 'bigint', default: 0 })
  totalRecordsProcessed: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  averageResponseTimeMs: number;

  // Dependencies
  @Column({ type: 'simple-array', nullable: true })
  dependsOn: string[];

  @Column({ type: 'simple-array', nullable: true })
  dependedOnBy: string[];

  // Metadata
  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, unknown>;

  @Column({ type: 'jsonb', nullable: true })
  tags: string[];

  @Column({ type: 'varchar', length: 50, nullable: true })
  environment: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  version: string;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Calculated properties
  get fullUrl(): string {
    const base = this.baseUrl.endsWith('/') ? this.baseUrl.slice(0, -1) : this.baseUrl;
    const path = this.path?.startsWith('/') ? this.path : `/${this.path || ''}`;
    return `${base}${path}`;
  }

  get successRate(): number {
    if (this.totalRequests === 0) return 0;
    return (Number(this.successfulRequests) / Number(this.totalRequests)) * 100;
  }

  get isHealthy(): boolean {
    return this.status === EndpointStatus.ACTIVE && this.consecutiveFailures < 3;
  }
}

// Authentication configuration interface
export interface AuthenticationConfig {
  apiKeyHeader?: string;
  apiKeyValue?: string;
  tokenEndpoint?: string;
  clientId?: string;
  clientSecret?: string;
  scope?: string;
  refreshToken?: string;
  accessToken?: string;
  tokenExpiry?: Date;
  username?: string;
  password?: string;
  certificatePath?: string;
  certificatePassword?: string;
  customHeaders?: Record<string, string>;
}

// Field mapping interface
export interface FieldMapping {
  sourceField: string;
  targetField: string;
  transformation?: 'none' | 'uppercase' | 'lowercase' | 'trim' | 'parse_date' | 'parse_number' | 'custom';
  transformationConfig?: Record<string, unknown>;
  required?: boolean;
  defaultValue?: unknown;
}

// DTOs for API responses
export interface EndpointHealth {
  endpointId: string;
  name: string;
  status: EndpointStatus;
  lastCheck: Date;
  responseTime: number | null;
  uptime: number;
  consecutiveFailures: number;
  lastError: string | null;
}

export interface EndpointSummary {
  total: number;
  byStatus: {
    [key in EndpointStatus]?: number;
  };
  byType: {
    [key in EndpointType]?: number;
  };
  byCategory: {
    [key in DataCategory]?: number;
  };
  healthyPercentage: number;
  averageResponseTime: number;
}

export interface DiscoveryResult {
  discovered: DiscoveredEndpoint[];
  validated: DiscoveredEndpoint[];
  failed: Array<{
    url: string;
    error: string;
  }>;
  timestamp: Date;
  duration: number;
}

export interface EndpointMetrics {
  endpointId: string;
  period: {
    start: Date;
    end: Date;
  };
  requestCount: number;
  successCount: number;
  failureCount: number;
  avgResponseTime: number;
  minResponseTime: number;
  maxResponseTime: number;
  recordsProcessed: number;
  errorBreakdown: {
    [errorType: string]: number;
  };
  hourlyDistribution: Array<{
    hour: number;
    requests: number;
    avgResponseTime: number;
  }>;
}
