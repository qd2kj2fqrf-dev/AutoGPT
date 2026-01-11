import { Router, Request, Response, NextFunction } from 'express';

const router = Router();

// In-memory storage (replace with database in production)
interface DiscoveredService {
  id: string;
  name: string;
  type: 'rest' | 'graphql' | 'grpc' | 'webhook';
  baseUrl: string;
  authType: 'none' | 'apiKey' | 'oauth2' | 'basic';
  discoveredAt: Date;
  lastSeen: Date;
  status: 'active' | 'inactive' | 'error';
  metadata?: Record<string, unknown>;
}

interface DiscoveredEndpoint {
  id: string;
  serviceId: string;
  path: string;
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  description?: string;
  parameters?: Array<{
    name: string;
    in: 'query' | 'path' | 'header' | 'body';
    required: boolean;
    type: string;
  }>;
  responseSchema?: Record<string, unknown>;
  discoveredAt: Date;
  lastCalled?: Date;
  callCount: number;
}

interface DiscoveryStatus {
  isScanning: boolean;
  lastScanStarted?: Date;
  lastScanCompleted?: Date;
  servicesCount: number;
  endpointsCount: number;
  errors: string[];
}

// Storage
const services: Map<string, DiscoveredService> = new Map();
const endpoints: Map<string, DiscoveredEndpoint> = new Map();
let discoveryStatus: DiscoveryStatus = {
  isScanning: false,
  servicesCount: 0,
  endpointsCount: 0,
  errors: [],
};

// Async wrapper for error handling
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<void>) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * GET /api/discovery/scan
 * Trigger full system scan for APIs and services
 */
router.get('/scan', asyncHandler(async (_req: Request, res: Response) => {
  if (discoveryStatus.isScanning) {
    res.status(409).json({
      success: false,
      message: 'Scan already in progress',
      status: discoveryStatus,
    });
    return;
  }

  // Start scan asynchronously
  discoveryStatus.isScanning = true;
  discoveryStatus.lastScanStarted = new Date();
  discoveryStatus.errors = [];

  // Simulate async scan (replace with actual discovery logic)
  setImmediate(async () => {
    try {
      // TODO: Implement actual discovery logic
      // - Scan network for services
      // - Parse OpenAPI/Swagger specs
      // - Detect GraphQL endpoints
      // - Check webhook registrations

      await simulateDiscovery();

      discoveryStatus.lastScanCompleted = new Date();
      discoveryStatus.servicesCount = services.size;
      discoveryStatus.endpointsCount = endpoints.size;
    } catch (error) {
      discoveryStatus.errors.push(error instanceof Error ? error.message : 'Unknown error');
    } finally {
      discoveryStatus.isScanning = false;
    }
  });

  res.json({
    success: true,
    message: 'Scan initiated',
    status: discoveryStatus,
  });
}));

/**
 * GET /api/discovery/services
 * List all discovered services
 */
router.get('/services', asyncHandler(async (req: Request, res: Response) => {
  const { type, status } = req.query;

  let result = Array.from(services.values());

  if (type && typeof type === 'string') {
    result = result.filter(s => s.type === type);
  }

  if (status && typeof status === 'string') {
    result = result.filter(s => s.status === status);
  }

  res.json({
    success: true,
    count: result.length,
    services: result,
  });
}));

/**
 * GET /api/discovery/endpoints
 * List all registered endpoints with optional filtering
 */
router.get('/endpoints', asyncHandler(async (req: Request, res: Response) => {
  const { serviceId, method, path: pathFilter, limit, offset } = req.query;

  let result = Array.from(endpoints.values());

  // Filter by service
  if (serviceId && typeof serviceId === 'string') {
    result = result.filter(e => e.serviceId === serviceId);
  }

  // Filter by method
  if (method && typeof method === 'string') {
    result = result.filter(e => e.method === method.toUpperCase());
  }

  // Filter by path (substring match)
  if (pathFilter && typeof pathFilter === 'string') {
    result = result.filter(e => e.path.includes(pathFilter));
  }

  const total = result.length;

  // Pagination
  const offsetNum = typeof offset === 'string' ? parseInt(offset, 10) : 0;
  const limitNum = typeof limit === 'string' ? parseInt(limit, 10) : 50;
  result = result.slice(offsetNum, offsetNum + limitNum);

  res.json({
    success: true,
    total,
    count: result.length,
    offset: offsetNum,
    limit: limitNum,
    endpoints: result,
  });
}));

/**
 * GET /api/discovery/endpoints/:serviceId
 * Get endpoints for a specific service
 */
router.get('/endpoints/:serviceId', asyncHandler(async (req: Request, res: Response) => {
  const serviceId = req.params.serviceId as string;

  const service = services.get(serviceId);
  if (!service) {
    res.status(404).json({
      success: false,
      message: `Service not found: ${serviceId}`,
    });
    return;
  }

  const serviceEndpoints = Array.from(endpoints.values())
    .filter(e => e.serviceId === serviceId);

  res.json({
    success: true,
    service,
    count: serviceEndpoints.length,
    endpoints: serviceEndpoints,
  });
}));

/**
 * POST /api/discovery/refresh
 * Force refresh of all APIs
 */
router.post('/refresh', asyncHandler(async (_req: Request, res: Response) => {
  if (discoveryStatus.isScanning) {
    res.status(409).json({
      success: false,
      message: 'Scan already in progress',
    });
    return;
  }

  // Clear existing data
  services.clear();
  endpoints.clear();

  discoveryStatus = {
    isScanning: true,
    lastScanStarted: new Date(),
    servicesCount: 0,
    endpointsCount: 0,
    errors: [],
  };

  // Run discovery asynchronously
  setImmediate(async () => {
    try {
      await simulateDiscovery();
      discoveryStatus.lastScanCompleted = new Date();
      discoveryStatus.servicesCount = services.size;
      discoveryStatus.endpointsCount = endpoints.size;
    } catch (error) {
      discoveryStatus.errors.push(error instanceof Error ? error.message : 'Unknown error');
    } finally {
      discoveryStatus.isScanning = false;
    }
  });

  res.json({
    success: true,
    message: 'Full refresh initiated - all cached data cleared',
    status: discoveryStatus,
  });
}));

/**
 * GET /api/discovery/status
 * Get current discovery status
 */
router.get('/status', asyncHandler(async (_req: Request, res: Response) => {
  res.json({
    success: true,
    status: {
      ...discoveryStatus,
      servicesCount: services.size,
      endpointsCount: endpoints.size,
    },
  });
}));

/**
 * Simulate discovery process (replace with actual implementation)
 */
async function simulateDiscovery(): Promise<void> {
  // Simulate some discovered services
  const sampleServices: DiscoveredService[] = [
    {
      id: 'qbo-api',
      name: 'QuickBooks Online API',
      type: 'rest',
      baseUrl: 'https://quickbooks.api.intuit.com/v3',
      authType: 'oauth2',
      discoveredAt: new Date(),
      lastSeen: new Date(),
      status: 'active',
    },
    {
      id: 'ms-graph',
      name: 'Microsoft Graph API',
      type: 'rest',
      baseUrl: 'https://graph.microsoft.com/v1.0',
      authType: 'oauth2',
      discoveredAt: new Date(),
      lastSeen: new Date(),
      status: 'active',
    },
    {
      id: 'simplefin',
      name: 'SimpleFIN Bridge',
      type: 'rest',
      baseUrl: 'https://beta-bridge.simplefin.org/simplefin',
      authType: 'basic',
      discoveredAt: new Date(),
      lastSeen: new Date(),
      status: 'active',
    },
  ];

  const sampleEndpoints: DiscoveredEndpoint[] = [
    {
      id: 'qbo-company-info',
      serviceId: 'qbo-api',
      path: '/company/{realmId}/companyinfo/{companyId}',
      method: 'GET',
      description: 'Get company information',
      parameters: [
        { name: 'realmId', in: 'path', required: true, type: 'string' },
        { name: 'companyId', in: 'path', required: true, type: 'string' },
      ],
      discoveredAt: new Date(),
      callCount: 0,
    },
    {
      id: 'qbo-accounts',
      serviceId: 'qbo-api',
      path: '/company/{realmId}/query',
      method: 'GET',
      description: 'Query accounts',
      parameters: [
        { name: 'realmId', in: 'path', required: true, type: 'string' },
        { name: 'query', in: 'query', required: true, type: 'string' },
      ],
      discoveredAt: new Date(),
      callCount: 0,
    },
    {
      id: 'msgraph-me',
      serviceId: 'ms-graph',
      path: '/me',
      method: 'GET',
      description: 'Get current user profile',
      parameters: [],
      discoveredAt: new Date(),
      callCount: 0,
    },
    {
      id: 'msgraph-messages',
      serviceId: 'ms-graph',
      path: '/users/{userId}/messages',
      method: 'GET',
      description: 'List user messages',
      parameters: [
        { name: 'userId', in: 'path', required: true, type: 'string' },
        { name: '$top', in: 'query', required: false, type: 'integer' },
        { name: '$filter', in: 'query', required: false, type: 'string' },
      ],
      discoveredAt: new Date(),
      callCount: 0,
    },
    {
      id: 'simplefin-accounts',
      serviceId: 'simplefin',
      path: '/accounts',
      method: 'GET',
      description: 'List all connected bank accounts',
      parameters: [],
      discoveredAt: new Date(),
      callCount: 0,
    },
  ];

  // Simulate delay
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Store discovered data
  for (const service of sampleServices) {
    services.set(service.id, service);
  }

  for (const endpoint of sampleEndpoints) {
    endpoints.set(endpoint.id, endpoint);
  }
}

// Export for programmatic access
export { services, endpoints, discoveryStatus };
export default router;
