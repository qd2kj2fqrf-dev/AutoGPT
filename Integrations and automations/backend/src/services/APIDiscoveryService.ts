/**
 * JRD PetroWise - API Discovery Engine
 *
 * Core service that automatically discovers running JRD applications,
 * fetches their OpenAPI specifications, and registers all available endpoints.
 *
 * Services scanned:
 * - Port 8001: JRD Fuel
 * - Port 8002: JRD Auto
 * - Port 8003: Price-O-Tron
 * - Port 8004: Jumbotron
 * - Port 8005: Scanotron
 */

import axios, { AxiosInstance, AxiosError } from 'axios';

// ============================================================================
// INTERFACES
// ============================================================================

/**
 * Represents a discovered service running on a port
 */
export interface DiscoveredService {
  id: string;
  name: string;
  port: number;
  type: 'fuel' | 'auto' | 'pricing' | 'analytics' | 'scanning';
  baseUrl: string;
  status: 'online' | 'offline' | 'error';
  version?: string;
  healthEndpoint?: string;
  openApiUrl?: string;
  discoveredAt: Date;
  lastChecked: Date;
  errorMessage?: string;
}

/**
 * OpenAPI 3.0 specification structure (simplified)
 */
export interface OpenAPISpec {
  openapi: string;
  info: {
    title: string;
    version: string;
    description?: string;
  };
  servers?: Array<{
    url: string;
    description?: string;
  }>;
  paths: Record<string, OpenAPIPathItem>;
  components?: {
    schemas?: Record<string, any>;
    securitySchemes?: Record<string, any>;
  };
  tags?: Array<{
    name: string;
    description?: string;
  }>;
}

interface OpenAPIPathItem {
  get?: OpenAPIOperation;
  post?: OpenAPIOperation;
  put?: OpenAPIOperation;
  delete?: OpenAPIOperation;
  patch?: OpenAPIOperation;
  parameters?: OpenAPIParameter[];
}

interface OpenAPIOperation {
  operationId?: string;
  summary?: string;
  description?: string;
  tags?: string[];
  parameters?: OpenAPIParameter[];
  requestBody?: {
    required?: boolean;
    content: Record<string, { schema: any }>;
  };
  responses: Record<string, {
    description: string;
    content?: Record<string, { schema: any }>;
  }>;
  security?: Array<Record<string, string[]>>;
}

interface OpenAPIParameter {
  name: string;
  in: 'path' | 'query' | 'header' | 'cookie';
  required?: boolean;
  schema?: any;
  description?: string;
}

/**
 * Represents a mapped API endpoint ready for use in flows
 */
export interface IntegrationEndpoint {
  id: string;
  serviceId: string;
  serviceName: string;
  serviceType: string;
  path: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  operationId: string;
  summary: string;
  description: string;
  tags: string[];
  parameters: Array<{
    name: string;
    location: 'path' | 'query' | 'header' | 'cookie' | 'body';
    required: boolean;
    schema: any;
    description?: string;
  }>;
  requestBody?: {
    required: boolean;
    contentType: string;
    schema: any;
  };
  responses: Array<{
    statusCode: string;
    description: string;
    schema?: any;
  }>;
  fullUrl: string;
  registeredAt: Date;
}

/**
 * Result of environment scan
 */
export interface ScanResult {
  success: boolean;
  scanStarted: Date;
  scanCompleted: Date;
  durationMs: number;
  servicesScanned: number;
  servicesOnline: number;
  servicesOffline: number;
  totalEndpoints: number;
  services: DiscoveredService[];
  errors: Array<{
    service: string;
    port: number;
    error: string;
  }>;
}

// ============================================================================
// SERVICE CONFIGURATION
// ============================================================================

interface ServiceConfig {
  name: string;
  port: number;
  type: 'fuel' | 'auto' | 'pricing' | 'analytics' | 'scanning';
  openApiPaths: string[];
  healthPaths: string[];
}

const JRD_SERVICES: ServiceConfig[] = [
  {
    name: 'JRD Fuel',
    port: 8001,
    type: 'fuel',
    openApiPaths: ['/swagger.json', '/api/openapi.json', '/openapi.json', '/.well-known/openapi.json'],
    healthPaths: ['/health', '/api/health', '/healthz', '/'],
  },
  {
    name: 'JRD Auto',
    port: 8002,
    type: 'auto',
    openApiPaths: ['/swagger.json', '/api/openapi.json', '/openapi.json', '/.well-known/openapi.json'],
    healthPaths: ['/health', '/api/health', '/healthz', '/'],
  },
  {
    name: 'Price-O-Tron',
    port: 8003,
    type: 'pricing',
    openApiPaths: ['/swagger.json', '/api/openapi.json', '/openapi.json', '/pricing/openapi.json'],
    healthPaths: ['/health', '/api/health', '/healthz', '/'],
  },
  {
    name: 'Jumbotron',
    port: 8004,
    type: 'analytics',
    openApiPaths: ['/swagger.json', '/api/openapi.json', '/openapi.json', '/analytics/openapi.json'],
    healthPaths: ['/health', '/api/health', '/healthz', '/'],
  },
  {
    name: 'Scanotron',
    port: 8005,
    type: 'scanning',
    openApiPaths: ['/swagger.json', '/api/openapi.json', '/openapi.json', '/scan/openapi.json'],
    healthPaths: ['/health', '/api/health', '/healthz', '/'],
  },
];

// ============================================================================
// LOGGER
// ============================================================================

class Logger {
  private prefix: string;

  constructor(prefix: string) {
    this.prefix = prefix;
  }

  info(message: string, ...args: any[]): void {
    console.log(`[${new Date().toISOString()}] [INFO] [${this.prefix}] ${message}`, ...args);
  }

  warn(message: string, ...args: any[]): void {
    console.warn(`[${new Date().toISOString()}] [WARN] [${this.prefix}] ${message}`, ...args);
  }

  error(message: string, ...args: any[]): void {
    console.error(`[${new Date().toISOString()}] [ERROR] [${this.prefix}] ${message}`, ...args);
  }

  debug(message: string, ...args: any[]): void {
    if (process.env.DEBUG === 'true') {
      console.log(`[${new Date().toISOString()}] [DEBUG] [${this.prefix}] ${message}`, ...args);
    }
  }
}

// ============================================================================
// API DISCOVERY SERVICE
// ============================================================================

export class APIDiscoveryService {
  private logger: Logger;
  private httpClient: AxiosInstance;
  private discoveredServices: Map<string, DiscoveredService> = new Map();
  private registeredEndpoints: Map<string, IntegrationEndpoint[]> = new Map();
  private openApiSpecs: Map<string, OpenAPISpec> = new Map();
  private lastScanResult: ScanResult | null = null;

  // Retry configuration
  private readonly maxRetries = 3;
  private readonly retryDelayMs = 1000;
  private readonly requestTimeoutMs = 5000;
  private readonly healthCheckTimeoutMs = 2000;

  constructor() {
    this.logger = new Logger('APIDiscovery');
    this.httpClient = axios.create({
      timeout: this.requestTimeoutMs,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'JRD-PetroWise-Discovery/1.0',
      },
    });
  }

  // ==========================================================================
  // PUBLIC METHODS
  // ==========================================================================

  /**
   * Scans the environment for running JRD services on ports 8001-8005.
   * This is the primary entry point for discovery.
   */
  async scanEnvironment(): Promise<ScanResult> {
    const scanStarted = new Date();
    this.logger.info('Starting environment scan for JRD services...');

    const services: DiscoveredService[] = [];
    const errors: Array<{ service: string; port: number; error: string }> = [];
    let servicesOnline = 0;
    let servicesOffline = 0;

    // Scan all configured services in parallel
    const scanPromises = JRD_SERVICES.map(async (config) => {
      try {
        const service = await this.probeService(config);
        services.push(service);

        if (service.status === 'online') {
          servicesOnline++;
          this.discoveredServices.set(service.id, service);
          this.logger.info(`Service online: ${service.name} at port ${service.port}`);
        } else {
          servicesOffline++;
          this.logger.warn(`Service offline: ${service.name} at port ${service.port}`);
        }
      } catch (error) {
        servicesOffline++;
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        errors.push({
          service: config.name,
          port: config.port,
          error: errorMessage,
        });
        this.logger.error(`Failed to probe ${config.name}: ${errorMessage}`);
      }
    });

    await Promise.all(scanPromises);

    const scanCompleted = new Date();
    const durationMs = scanCompleted.getTime() - scanStarted.getTime();

    this.lastScanResult = {
      success: errors.length === 0,
      scanStarted,
      scanCompleted,
      durationMs,
      servicesScanned: JRD_SERVICES.length,
      servicesOnline,
      servicesOffline,
      totalEndpoints: this.getTotalEndpointCount(),
      services,
      errors,
    };

    this.logger.info(
      `Scan complete: ${servicesOnline}/${JRD_SERVICES.length} services online, ` +
      `${this.lastScanResult.totalEndpoints} endpoints discovered (${durationMs}ms)`
    );

    return this.lastScanResult;
  }

  /**
   * Discovers APIs by fetching OpenAPI specs from all online services.
   * Should be called after scanEnvironment().
   */
  async discoverAPIs(): Promise<Map<string, OpenAPISpec>> {
    this.logger.info('Discovering APIs from online services...');

    const discoveryPromises = Array.from(this.discoveredServices.values())
      .filter(service => service.status === 'online')
      .map(async (service) => {
        try {
          const spec = await this.fetchOpenAPISpec(service);
          if (spec) {
            this.openApiSpecs.set(service.id, spec);
            this.logger.info(`Discovered API spec for ${service.name}: ${spec.info.title} v${spec.info.version}`);
          }
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.warn(`Failed to fetch OpenAPI spec for ${service.name}: ${errorMessage}`);
        }
      });

    await Promise.all(discoveryPromises);

    this.logger.info(`API discovery complete: ${this.openApiSpecs.size} specs retrieved`);
    return new Map(this.openApiSpecs);
  }

  /**
   * Maps endpoints from discovered OpenAPI specs into IntegrationEndpoint objects.
   * Should be called after discoverAPIs().
   */
  async mapEndpoints(): Promise<Map<string, IntegrationEndpoint[]>> {
    this.logger.info('Mapping endpoints from discovered APIs...');

    this.registeredEndpoints.clear();
    let totalMapped = 0;

    for (const [serviceId, spec] of this.openApiSpecs) {
      const service = this.discoveredServices.get(serviceId);
      if (!service) continue;

      const endpoints = this.parseEndpointsFromSpec(service, spec);
      this.registeredEndpoints.set(serviceId, endpoints);
      totalMapped += endpoints.length;

      this.logger.info(`Mapped ${endpoints.length} endpoints for ${service.name}`);
    }

    this.logger.info(`Endpoint mapping complete: ${totalMapped} total endpoints registered`);
    return new Map(this.registeredEndpoints);
  }

  /**
   * Full discovery pipeline: scan -> discover APIs -> map endpoints.
   * Convenience method that runs all three steps.
   */
  async fullDiscovery(): Promise<{
    scan: ScanResult;
    specs: Map<string, OpenAPISpec>;
    endpoints: Map<string, IntegrationEndpoint[]>;
  }> {
    const scan = await this.scanEnvironment();
    const specs = await this.discoverAPIs();
    const endpoints = await this.mapEndpoints();

    return { scan, specs, endpoints };
  }

  // ==========================================================================
  // ACCESSOR METHODS
  // ==========================================================================

  /**
   * Get all discovered services
   */
  getDiscoveredServices(): DiscoveredService[] {
    return Array.from(this.discoveredServices.values());
  }

  /**
   * Get a specific service by ID
   */
  getService(serviceId: string): DiscoveredService | undefined {
    return this.discoveredServices.get(serviceId);
  }

  /**
   * Get all registered endpoints across all services
   */
  getAllEndpoints(): IntegrationEndpoint[] {
    const all: IntegrationEndpoint[] = [];
    for (const endpoints of this.registeredEndpoints.values()) {
      all.push(...endpoints);
    }
    return all;
  }

  /**
   * Get endpoints for a specific service
   */
  getEndpointsByService(serviceId: string): IntegrationEndpoint[] {
    return this.registeredEndpoints.get(serviceId) || [];
  }

  /**
   * Search endpoints by query string (matches path, operationId, summary)
   */
  searchEndpoints(query: string): IntegrationEndpoint[] {
    const lowerQuery = query.toLowerCase();
    return this.getAllEndpoints().filter(ep =>
      ep.path.toLowerCase().includes(lowerQuery) ||
      ep.operationId.toLowerCase().includes(lowerQuery) ||
      ep.summary.toLowerCase().includes(lowerQuery) ||
      ep.serviceName.toLowerCase().includes(lowerQuery) ||
      ep.tags.some(tag => tag.toLowerCase().includes(lowerQuery))
    );
  }

  /**
   * Get endpoint by ID
   */
  getEndpoint(endpointId: string): IntegrationEndpoint | undefined {
    for (const endpoints of this.registeredEndpoints.values()) {
      const found = endpoints.find(ep => ep.id === endpointId);
      if (found) return found;
    }
    return undefined;
  }

  /**
   * Get OpenAPI spec for a service
   */
  getOpenAPISpec(serviceId: string): OpenAPISpec | undefined {
    return this.openApiSpecs.get(serviceId);
  }

  /**
   * Get last scan result
   */
  getLastScanResult(): ScanResult | null {
    return this.lastScanResult;
  }

  /**
   * Get total endpoint count
   */
  getTotalEndpointCount(): number {
    let total = 0;
    for (const endpoints of this.registeredEndpoints.values()) {
      total += endpoints.length;
    }
    return total;
  }

  /**
   * Get discovery status summary
   */
  getStatus(): {
    lastScan: Date | null;
    servicesOnline: number;
    servicesOffline: number;
    totalEndpoints: number;
    services: Array<{ id: string; name: string; status: string; endpoints: number }>;
  } {
    const services = Array.from(this.discoveredServices.values()).map(s => ({
      id: s.id,
      name: s.name,
      status: s.status,
      endpoints: this.registeredEndpoints.get(s.id)?.length || 0,
    }));

    return {
      lastScan: this.lastScanResult?.scanCompleted || null,
      servicesOnline: services.filter(s => s.status === 'online').length,
      servicesOffline: services.filter(s => s.status !== 'online').length,
      totalEndpoints: this.getTotalEndpointCount(),
      services,
    };
  }

  // ==========================================================================
  // PRIVATE METHODS
  // ==========================================================================

  /**
   * Probe a service to check if it's running
   */
  private async probeService(config: ServiceConfig): Promise<DiscoveredService> {
    const baseUrl = `http://localhost:${config.port}`;
    const now = new Date();

    const service: DiscoveredService = {
      id: this.generateServiceId(config.name),
      name: config.name,
      port: config.port,
      type: config.type,
      baseUrl,
      status: 'offline',
      discoveredAt: now,
      lastChecked: now,
    };

    // Try health endpoints
    for (const healthPath of config.healthPaths) {
      try {
        const response = await this.httpClient.get(`${baseUrl}${healthPath}`, {
          timeout: this.healthCheckTimeoutMs,
        });

        if (response.status >= 200 && response.status < 300) {
          service.status = 'online';
          service.healthEndpoint = healthPath;

          // Try to extract version from response
          if (response.data && typeof response.data === 'object') {
            service.version = response.data.version || response.data.appVersion;
          }
          break;
        }
      } catch {
        // Continue to next health path
      }
    }

    // If no health endpoint worked, try root path
    if (service.status === 'offline') {
      try {
        await this.httpClient.get(baseUrl, {
          timeout: this.healthCheckTimeoutMs,
          validateStatus: (status) => status < 500,
        });
        service.status = 'online';
      } catch {
        // Service truly offline
      }
    }

    return service;
  }

  /**
   * Fetch OpenAPI specification from a service with retry logic
   */
  private async fetchOpenAPISpec(service: DiscoveredService): Promise<OpenAPISpec | null> {
    const config = JRD_SERVICES.find(c => c.port === service.port);
    if (!config) return null;

    for (const openApiPath of config.openApiPaths) {
      const spec = await this.fetchWithRetry(`${service.baseUrl}${openApiPath}`);
      if (spec && this.isValidOpenAPISpec(spec)) {
        service.openApiUrl = openApiPath;
        return spec as OpenAPISpec;
      }
    }

    this.logger.warn(`No valid OpenAPI spec found for ${service.name}`);
    return null;
  }

  /**
   * Fetch URL with retry logic
   */
  private async fetchWithRetry(url: string): Promise<any | null> {
    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= this.maxRetries; attempt++) {
      try {
        const response = await this.httpClient.get(url);
        return response.data;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error('Unknown error');

        if (error instanceof AxiosError) {
          // Don't retry on 404 or 403
          if (error.response?.status === 404 || error.response?.status === 403) {
            return null;
          }
        }

        if (attempt < this.maxRetries) {
          this.logger.debug(`Retry ${attempt}/${this.maxRetries} for ${url}`);
          await this.delay(this.retryDelayMs * attempt);
        }
      }
    }

    this.logger.debug(`All retries exhausted for ${url}: ${lastError?.message}`);
    return null;
  }

  /**
   * Validate that an object is a valid OpenAPI spec
   */
  private isValidOpenAPISpec(data: any): boolean {
    return (
      typeof data === 'object' &&
      data !== null &&
      (data.openapi || data.swagger) &&
      typeof data.info === 'object' &&
      typeof data.paths === 'object'
    );
  }

  /**
   * Parse endpoints from OpenAPI spec
   */
  private parseEndpointsFromSpec(service: DiscoveredService, spec: OpenAPISpec): IntegrationEndpoint[] {
    const endpoints: IntegrationEndpoint[] = [];
    const registeredAt = new Date();

    for (const [path, pathItem] of Object.entries(spec.paths)) {
      const methods: Array<'get' | 'post' | 'put' | 'delete' | 'patch'> =
        ['get', 'post', 'put', 'delete', 'patch'];

      for (const method of methods) {
        const operation = pathItem[method];
        if (!operation) continue;

        const endpoint = this.createEndpointFromOperation(
          service,
          path,
          method.toUpperCase() as IntegrationEndpoint['method'],
          operation,
          pathItem.parameters,
          registeredAt
        );

        endpoints.push(endpoint);
      }
    }

    return endpoints;
  }

  /**
   * Create IntegrationEndpoint from OpenAPI operation
   */
  private createEndpointFromOperation(
    service: DiscoveredService,
    path: string,
    method: IntegrationEndpoint['method'],
    operation: OpenAPIOperation,
    pathParams: OpenAPIParameter[] | undefined,
    registeredAt: Date
  ): IntegrationEndpoint {
    // Combine path-level and operation-level parameters
    const allParams = [...(pathParams || []), ...(operation.parameters || [])];

    // Map parameters
    const parameters = allParams.map(param => ({
      name: param.name,
      location: param.in as IntegrationEndpoint['parameters'][0]['location'],
      required: param.required || false,
      schema: param.schema || {},
      description: param.description,
    }));

    // Map request body if present
    let requestBody: IntegrationEndpoint['requestBody'];
    if (operation.requestBody) {
      const contentTypes = Object.keys(operation.requestBody.content);
      const primaryContentType = contentTypes[0] || 'application/json';
      requestBody = {
        required: operation.requestBody.required || false,
        contentType: primaryContentType,
        schema: operation.requestBody.content[primaryContentType]?.schema || {},
      };
    }

    // Map responses
    const responses = Object.entries(operation.responses).map(([statusCode, response]) => ({
      statusCode,
      description: response.description,
      schema: response.content?.['application/json']?.schema,
    }));

    // Generate unique ID
    const operationId = operation.operationId ||
      `${method.toLowerCase()}_${path.replace(/[^a-zA-Z0-9]/g, '_')}`;
    const id = `${service.id}_${operationId}`;

    return {
      id,
      serviceId: service.id,
      serviceName: service.name,
      serviceType: service.type,
      path,
      method,
      operationId,
      summary: operation.summary || path,
      description: operation.description || '',
      tags: operation.tags || [service.type],
      parameters,
      requestBody,
      responses,
      fullUrl: `${service.baseUrl}${path}`,
      registeredAt,
    };
  }

  /**
   * Generate service ID from name
   */
  private generateServiceId(name: string): string {
    return name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
  }

  /**
   * Delay helper for retry logic
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// ============================================================================
// SINGLETON EXPORT
// ============================================================================

const apiDiscoveryService = new APIDiscoveryService();

export default apiDiscoveryService;
