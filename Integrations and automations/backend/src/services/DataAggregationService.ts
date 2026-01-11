import { EventEmitter } from 'events';
import { Repository, DataSource, Between, In, LessThan, MoreThan } from 'typeorm';
import { WebSocket, WebSocketServer } from 'ws';
import {
  FuelOperation,
  FuelOperationSummary,
  FuelTrendData,
  FuelType,
  TransactionType,
  PaymentMethod,
  TankLevelData,
  FuelInventorySnapshot,
} from '../models/FuelOperation';
import {
  AutoOperation,
  AutoOperationSummary,
  AutoTrendData,
  ServiceType,
  WorkOrderStatus,
  TechnicianPerformance,
  VehicleServiceHistory,
  CustomerProfile,
} from '../models/AutoOperation';
import {
  DiscoveredEndpoint,
  EndpointStatus,
  EndpointHealth,
  EndpointSummary,
  DataCategory,
} from '../models/DiscoveredEndpoint';

// Enterprise metrics interface
export interface EnterpriseMetrics {
  timestamp: Date;
  period: 'daily' | 'weekly' | 'monthly' | 'yearly';
  fuel: {
    totalGallons: number;
    totalRevenue: number;
    totalCost: number;
    grossMargin: number;
    averageMarginPerGallon: number;
    transactionCount: number;
    byFuelType: Record<FuelType, { gallons: number; revenue: number; margin: number }>;
  };
  auto: {
    workOrderCount: number;
    totalRevenue: number;
    laborRevenue: number;
    partsRevenue: number;
    grossProfit: number;
    profitMargin: number;
    averageTicket: number;
    laborHours: number;
    byServiceType: Record<ServiceType, { count: number; revenue: number }>;
  };
  combined: {
    totalRevenue: number;
    totalCost: number;
    grossProfit: number;
    profitMargin: number;
  };
  trends: {
    revenueChange: number;
    marginChange: number;
    volumeChange: number;
  };
}

// Real-time event types
export interface DataEvent {
  type: 'fuel_transaction' | 'auto_work_order' | 'endpoint_status' | 'metrics_update' | 'alert';
  timestamp: Date;
  siteId?: string;
  data: unknown;
}

// Alert configuration
export interface AlertConfig {
  id: string;
  name: string;
  condition: 'threshold' | 'change' | 'absence';
  metric: string;
  threshold?: number;
  changePercent?: number;
  absenceMinutes?: number;
  severity: 'info' | 'warning' | 'critical';
  enabled: boolean;
}

// WebSocket client tracking
interface WebSocketClient {
  ws: WebSocket;
  subscriptions: Set<string>;
  siteIds: Set<string>;
  lastPing: Date;
}

export class DataAggregationService extends EventEmitter {
  private dataSource: DataSource;
  private fuelRepo: Repository<FuelOperation>;
  private autoRepo: Repository<AutoOperation>;
  private endpointRepo: Repository<DiscoveredEndpoint>;
  private wsServer: WebSocketServer | null = null;
  private clients: Map<string, WebSocketClient> = new Map();
  private pollingIntervals: Map<string, NodeJS.Timeout> = new Map();
  private metricsCache: Map<string, { data: unknown; expiry: Date }> = new Map();
  private alerts: Map<string, AlertConfig> = new Map();
  private isRunning = false;

  constructor(dataSource: DataSource) {
    super();
    this.dataSource = dataSource;
    this.fuelRepo = dataSource.getRepository(FuelOperation);
    this.autoRepo = dataSource.getRepository(AutoOperation);
    this.endpointRepo = dataSource.getRepository(DiscoveredEndpoint);
  }

  // ============================================
  // Initialization and Connection
  // ============================================

  async initialize(): Promise<void> {
    console.log('[DataAggregationService] Initializing...');

    // Verify database connection
    if (!this.dataSource.isInitialized) {
      await this.dataSource.initialize();
    }

    // Load active endpoints
    const endpoints = await this.endpointRepo.find({
      where: { status: In([EndpointStatus.ACTIVE, EndpointStatus.VALIDATED]) },
    });

    console.log(`[DataAggregationService] Found ${endpoints.length} active endpoints`);

    // Start polling for each endpoint
    for (const endpoint of endpoints) {
      if (endpoint.pollingEnabled && endpoint.pollIntervalSeconds) {
        this.startPolling(endpoint);
      }
    }

    this.isRunning = true;
    this.emit('initialized');
  }

  async shutdown(): Promise<void> {
    console.log('[DataAggregationService] Shutting down...');
    this.isRunning = false;

    // Stop all polling
    for (const [id, interval] of this.pollingIntervals) {
      clearInterval(interval);
    }
    this.pollingIntervals.clear();

    // Close WebSocket server
    if (this.wsServer) {
      for (const client of this.clients.values()) {
        client.ws.close(1000, 'Server shutting down');
      }
      this.wsServer.close();
    }

    this.emit('shutdown');
  }

  // ============================================
  // WebSocket Streaming
  // ============================================

  initializeWebSocket(port: number = 8080): void {
    this.wsServer = new WebSocketServer({ port });

    this.wsServer.on('connection', (ws: WebSocket) => {
      const clientId = this.generateClientId();
      const client: WebSocketClient = {
        ws,
        subscriptions: new Set(['all']),
        siteIds: new Set(),
        lastPing: new Date(),
      };
      this.clients.set(clientId, client);

      console.log(`[WebSocket] Client connected: ${clientId}`);

      ws.on('message', (message: string) => {
        this.handleWebSocketMessage(clientId, message);
      });

      ws.on('close', () => {
        this.clients.delete(clientId);
        console.log(`[WebSocket] Client disconnected: ${clientId}`);
      });

      ws.on('pong', () => {
        client.lastPing = new Date();
      });

      // Send initial connection acknowledgment
      this.sendToClient(clientId, {
        type: 'connected',
        clientId,
        timestamp: new Date(),
      });
    });

    // Heartbeat interval
    setInterval(() => {
      const now = new Date();
      for (const [clientId, client] of this.clients) {
        const timeSinceLastPing = now.getTime() - client.lastPing.getTime();
        if (timeSinceLastPing > 60000) {
          client.ws.terminate();
          this.clients.delete(clientId);
        } else {
          client.ws.ping();
        }
      }
    }, 30000);

    console.log(`[WebSocket] Server started on port ${port}`);
  }

  private handleWebSocketMessage(clientId: string, message: string): void {
    const client = this.clients.get(clientId);
    if (!client) return;

    try {
      const parsed = JSON.parse(message);

      switch (parsed.action) {
        case 'subscribe':
          if (parsed.channels) {
            parsed.channels.forEach((ch: string) => client.subscriptions.add(ch));
          }
          if (parsed.siteIds) {
            parsed.siteIds.forEach((id: string) => client.siteIds.add(id));
          }
          break;

        case 'unsubscribe':
          if (parsed.channels) {
            parsed.channels.forEach((ch: string) => client.subscriptions.delete(ch));
          }
          if (parsed.siteIds) {
            parsed.siteIds.forEach((id: string) => client.siteIds.delete(id));
          }
          break;

        case 'request_metrics':
          this.sendMetricsToClient(clientId, parsed.period || 'daily');
          break;

        default:
          console.log(`[WebSocket] Unknown action: ${parsed.action}`);
      }
    } catch (err) {
      console.error('[WebSocket] Error parsing message:', err);
    }
  }

  private sendToClient(clientId: string, data: unknown): void {
    const client = this.clients.get(clientId);
    if (client && client.ws.readyState === WebSocket.OPEN) {
      client.ws.send(JSON.stringify(data));
    }
  }

  broadcast(event: DataEvent): void {
    const message = JSON.stringify(event);

    for (const [clientId, client] of this.clients) {
      // Check if client is subscribed to this event type
      if (!client.subscriptions.has('all') && !client.subscriptions.has(event.type)) {
        continue;
      }

      // Check site filter if applicable
      if (event.siteId && client.siteIds.size > 0 && !client.siteIds.has(event.siteId)) {
        continue;
      }

      if (client.ws.readyState === WebSocket.OPEN) {
        client.ws.send(message);
      }
    }
  }

  private async sendMetricsToClient(clientId: string, period: 'daily' | 'weekly' | 'monthly'): Promise<void> {
    const metrics = await this.getEnterpriseMetrics(period);
    this.sendToClient(clientId, {
      type: 'metrics_update',
      timestamp: new Date(),
      data: metrics,
    });
  }

  // ============================================
  // Endpoint Polling and Data Collection
  // ============================================

  private startPolling(endpoint: DiscoveredEndpoint): void {
    if (this.pollingIntervals.has(endpoint.id)) {
      return; // Already polling
    }

    const intervalMs = (endpoint.pollIntervalSeconds || 60) * 1000;

    const interval = setInterval(async () => {
      await this.pollEndpoint(endpoint);
    }, intervalMs);

    this.pollingIntervals.set(endpoint.id, interval);
    console.log(`[Polling] Started polling ${endpoint.name} every ${endpoint.pollIntervalSeconds}s`);
  }

  private stopPolling(endpointId: string): void {
    const interval = this.pollingIntervals.get(endpointId);
    if (interval) {
      clearInterval(interval);
      this.pollingIntervals.delete(endpointId);
    }
  }

  private async pollEndpoint(endpoint: DiscoveredEndpoint): Promise<void> {
    const startTime = Date.now();

    try {
      // Fetch data from endpoint
      const response = await this.fetchFromEndpoint(endpoint);

      // Update endpoint status
      const responseTime = Date.now() - startTime;
      await this.updateEndpointHealth(endpoint.id, {
        status: EndpointStatus.ACTIVE,
        responseTime,
        consecutiveFailures: 0,
      });

      // Process and store data based on category
      await this.processEndpointData(endpoint, response);

      // Emit real-time event
      this.emit('data_received', { endpoint, data: response });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      await this.updateEndpointHealth(endpoint.id, {
        status: endpoint.consecutiveFailures >= 2 ? EndpointStatus.ERROR : EndpointStatus.DEGRADED,
        consecutiveFailures: endpoint.consecutiveFailures + 1,
        errorMessage,
      });

      this.emit('endpoint_error', { endpoint, error: errorMessage });
    }
  }

  private async fetchFromEndpoint(endpoint: DiscoveredEndpoint): Promise<unknown> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    // Add authentication headers
    if (endpoint.authenticationConfig) {
      const auth = endpoint.authenticationConfig;
      if (auth.apiKeyHeader && auth.apiKeyValue) {
        headers[auth.apiKeyHeader] = auth.apiKeyValue;
      }
      if (auth.accessToken) {
        headers['Authorization'] = `Bearer ${auth.accessToken}`;
      }
      if (auth.customHeaders) {
        Object.assign(headers, auth.customHeaders);
      }
    }

    const response = await fetch(endpoint.fullUrl, {
      method: endpoint.httpMethod || 'GET',
      headers,
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return response.json();
  }

  private async updateEndpointHealth(
    endpointId: string,
    update: {
      status?: EndpointStatus;
      responseTime?: number;
      consecutiveFailures?: number;
      errorMessage?: string;
    }
  ): Promise<void> {
    await this.endpointRepo.update(endpointId, {
      status: update.status,
      lastHealthCheck: new Date(),
      lastResponseTimeMs: update.responseTime,
      consecutiveFailures: update.consecutiveFailures,
      lastErrorMessage: update.errorMessage,
      lastSuccessfulCall: update.status === EndpointStatus.ACTIVE ? new Date() : undefined,
    });
  }

  private async processEndpointData(endpoint: DiscoveredEndpoint, data: unknown): Promise<void> {
    switch (endpoint.dataCategory) {
      case DataCategory.FUEL_TRANSACTIONS:
        await this.processFuelTransactions(endpoint, data);
        break;
      case DataCategory.AUTO_WORK_ORDERS:
        await this.processAutoWorkOrders(endpoint, data);
        break;
      case DataCategory.FUEL_INVENTORY:
        await this.processFuelInventory(endpoint, data);
        break;
      default:
        console.log(`[DataAggregation] Unhandled category: ${endpoint.dataCategory}`);
    }
  }

  private async processFuelTransactions(endpoint: DiscoveredEndpoint, data: unknown): Promise<void> {
    const transactions = this.transformToFuelOperations(endpoint, data);

    for (const tx of transactions) {
      // Check for duplicates by transactionId
      const existing = await this.fuelRepo.findOne({ where: { transactionId: tx.transactionId } });
      if (!existing) {
        await this.fuelRepo.save(tx);

        // Broadcast real-time event
        this.broadcast({
          type: 'fuel_transaction',
          timestamp: new Date(),
          siteId: tx.siteId,
          data: tx,
        });
      }
    }
  }

  private async processAutoWorkOrders(endpoint: DiscoveredEndpoint, data: unknown): Promise<void> {
    const workOrders = this.transformToAutoOperations(endpoint, data);

    for (const wo of workOrders) {
      // Upsert by workOrderNumber
      const existing = await this.autoRepo.findOne({ where: { workOrderNumber: wo.workOrderNumber } });
      if (existing) {
        await this.autoRepo.update(existing.id, wo as any);
      } else {
        await this.autoRepo.save(wo as any);
      }

      // Broadcast real-time event
      this.broadcast({
        type: 'auto_work_order',
        timestamp: new Date(),
        siteId: wo.shopId,
        data: wo,
      });
    }
  }

  private async processFuelInventory(endpoint: DiscoveredEndpoint, data: unknown): Promise<void> {
    // Process tank level updates - implementation depends on data format
    console.log(`[DataAggregation] Processing fuel inventory from ${endpoint.name}`);
  }

  private transformToFuelOperations(endpoint: DiscoveredEndpoint, data: unknown): Partial<FuelOperation>[] {
    const results: Partial<FuelOperation>[] = [];
    const records = Array.isArray(data) ? data : [data];

    for (const record of records) {
      const mapped = this.applyFieldMappings(endpoint.fieldMappings || [], record as Record<string, unknown>);

      results.push({
        siteId: String(mapped.siteId || endpoint.siteId || 'unknown'),
        transactionId: String(mapped.transactionId || `${endpoint.id}-${Date.now()}`),
        transactionType: (mapped.transactionType as TransactionType) || TransactionType.SALE,
        transactionDate: mapped.transactionDate ? new Date(String(mapped.transactionDate)) : new Date(),
        fuelType: (mapped.fuelType as FuelType) || FuelType.REGULAR,
        gallons: Number(mapped.gallons) || 0,
        pricePerGallon: Number(mapped.pricePerGallon) || 0,
        costPerGallon: mapped.costPerGallon ? Number(mapped.costPerGallon) : undefined,
        totalAmount: Number(mapped.totalAmount) || 0,
        sourceSystem: endpoint.sourceSystem,
        sourceEndpointId: endpoint.id,
        rawData: record as Record<string, unknown>,
      });
    }

    return results;
  }

  private transformToAutoOperations(endpoint: DiscoveredEndpoint, data: unknown): Partial<AutoOperation>[] {
    const results: Partial<AutoOperation>[] = [];
    const records = Array.isArray(data) ? data : [data];

    for (const record of records) {
      const mapped = this.applyFieldMappings(endpoint.fieldMappings || [], record as Record<string, unknown>);

      results.push({
        shopId: String(mapped.shopId || endpoint.siteId || 'unknown'),
        workOrderNumber: String(mapped.workOrderNumber || `WO-${Date.now()}`),
        status: (mapped.status as WorkOrderStatus) || WorkOrderStatus.PENDING,
        serviceDate: mapped.serviceDate ? new Date(String(mapped.serviceDate)) : new Date(),
        customerName: String(mapped.customerName || 'Unknown'),
        primaryServiceType: (mapped.primaryServiceType as ServiceType) || ServiceType.OTHER,
        totalAmount: Number(mapped.totalAmount) || 0,
        sourceSystem: endpoint.sourceSystem,
        sourceEndpointId: endpoint.id,
        rawData: record as Record<string, unknown>,
      });
    }

    return results;
  }

  private applyFieldMappings(
    mappings: Array<{ sourceField: string; targetField: string; transformation?: string }>,
    data: Record<string, unknown>
  ): Record<string, unknown> {
    const result: Record<string, unknown> = { ...data };

    for (const mapping of mappings) {
      const sourceValue = this.getNestedValue(data, mapping.sourceField);
      if (sourceValue !== undefined) {
        result[mapping.targetField] = this.applyTransformation(sourceValue, mapping.transformation);
      }
    }

    return result;
  }

  private getNestedValue(obj: Record<string, unknown>, path: string): unknown {
    return path.split('.').reduce((curr, key) => {
      return curr && typeof curr === 'object' ? (curr as Record<string, unknown>)[key] : undefined;
    }, obj as unknown);
  }

  private applyTransformation(value: unknown, transformation?: string): unknown {
    if (!transformation || transformation === 'none') return value;

    switch (transformation) {
      case 'uppercase':
        return typeof value === 'string' ? value.toUpperCase() : value;
      case 'lowercase':
        return typeof value === 'string' ? value.toLowerCase() : value;
      case 'trim':
        return typeof value === 'string' ? value.trim() : value;
      case 'parse_date':
        return new Date(String(value));
      case 'parse_number':
        return Number(value);
      default:
        return value;
    }
  }

  // ============================================
  // Enterprise Metrics Calculation
  // ============================================

  async getEnterpriseMetrics(period: 'daily' | 'weekly' | 'monthly' | 'yearly' = 'daily'): Promise<EnterpriseMetrics> {
    const cacheKey = `metrics_${period}`;
    const cached = this.metricsCache.get(cacheKey);
    if (cached && cached.expiry > new Date()) {
      return cached.data as EnterpriseMetrics;
    }

    const { start, end, previousStart, previousEnd } = this.getPeriodDates(period);

    // Get current period metrics
    const [fuelMetrics, autoMetrics] = await Promise.all([
      this.calculateFuelMetrics(start, end),
      this.calculateAutoMetrics(start, end),
    ]);

    // Get previous period for trend calculation
    const [prevFuelMetrics, prevAutoMetrics] = await Promise.all([
      this.calculateFuelMetrics(previousStart, previousEnd),
      this.calculateAutoMetrics(previousStart, previousEnd),
    ]);

    const currentRevenue = fuelMetrics.totalRevenue + autoMetrics.totalRevenue;
    const previousRevenue = prevFuelMetrics.totalRevenue + prevAutoMetrics.totalRevenue;
    const currentMargin = fuelMetrics.grossMargin + autoMetrics.grossProfit;
    const previousMargin = prevFuelMetrics.grossMargin + prevAutoMetrics.grossProfit;

    const metrics: EnterpriseMetrics = {
      timestamp: new Date(),
      period,
      fuel: {
        totalGallons: fuelMetrics.totalGallons,
        totalRevenue: fuelMetrics.totalRevenue,
        totalCost: fuelMetrics.totalCost,
        grossMargin: fuelMetrics.grossMargin,
        averageMarginPerGallon: fuelMetrics.averageMarginPerGallon,
        transactionCount: fuelMetrics.transactionCount,
        byFuelType: fuelMetrics.byFuelType,
      },
      auto: {
        workOrderCount: autoMetrics.workOrderCount,
        totalRevenue: autoMetrics.totalRevenue,
        laborRevenue: autoMetrics.laborRevenue,
        partsRevenue: autoMetrics.partsRevenue,
        grossProfit: autoMetrics.grossProfit,
        profitMargin: autoMetrics.profitMargin,
        averageTicket: autoMetrics.averageTicket,
        laborHours: autoMetrics.totalLaborHours,
        byServiceType: autoMetrics.byServiceType,
      },
      combined: {
        totalRevenue: currentRevenue,
        totalCost: fuelMetrics.totalCost + (autoMetrics.totalRevenue - autoMetrics.grossProfit),
        grossProfit: currentMargin,
        profitMargin: currentRevenue > 0 ? (currentMargin / currentRevenue) * 100 : 0,
      },
      trends: {
        revenueChange: previousRevenue > 0 ? ((currentRevenue - previousRevenue) / previousRevenue) * 100 : 0,
        marginChange: previousMargin > 0 ? ((currentMargin - previousMargin) / previousMargin) * 100 : 0,
        volumeChange:
          prevFuelMetrics.totalGallons > 0
            ? ((fuelMetrics.totalGallons - prevFuelMetrics.totalGallons) / prevFuelMetrics.totalGallons) * 100
            : 0,
      },
    };

    // Cache for appropriate duration based on period
    const cacheDuration = period === 'daily' ? 5 * 60 * 1000 : 15 * 60 * 1000;
    this.metricsCache.set(cacheKey, {
      data: metrics,
      expiry: new Date(Date.now() + cacheDuration),
    });

    return metrics;
  }

  private getPeriodDates(period: 'daily' | 'weekly' | 'monthly' | 'yearly'): {
    start: Date;
    end: Date;
    previousStart: Date;
    previousEnd: Date;
  } {
    const now = new Date();
    const end = now;
    let start: Date;
    let previousStart: Date;
    let previousEnd: Date;

    switch (period) {
      case 'daily':
        start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        previousEnd = new Date(start.getTime() - 1);
        previousStart = new Date(previousEnd.getFullYear(), previousEnd.getMonth(), previousEnd.getDate());
        break;
      case 'weekly':
        const dayOfWeek = now.getDay();
        start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - dayOfWeek);
        previousEnd = new Date(start.getTime() - 1);
        previousStart = new Date(previousEnd.getFullYear(), previousEnd.getMonth(), previousEnd.getDate() - 6);
        break;
      case 'monthly':
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        previousEnd = new Date(start.getTime() - 1);
        previousStart = new Date(previousEnd.getFullYear(), previousEnd.getMonth(), 1);
        break;
      case 'yearly':
        start = new Date(now.getFullYear(), 0, 1);
        previousEnd = new Date(start.getTime() - 1);
        previousStart = new Date(previousEnd.getFullYear(), 0, 1);
        break;
    }

    return { start, end, previousStart, previousEnd };
  }

  private async calculateFuelMetrics(
    start: Date,
    end: Date
  ): Promise<{
    totalGallons: number;
    totalRevenue: number;
    totalCost: number;
    grossMargin: number;
    averageMarginPerGallon: number;
    transactionCount: number;
    byFuelType: Record<FuelType, { gallons: number; revenue: number; margin: number }>;
  }> {
    const transactions = await this.fuelRepo.find({
      where: {
        transactionDate: Between(start, end),
        transactionType: TransactionType.SALE,
      },
    });

    const byFuelType: Record<FuelType, { gallons: number; revenue: number; margin: number }> = {} as Record<
      FuelType,
      { gallons: number; revenue: number; margin: number }
    >;

    let totalGallons = 0;
    let totalRevenue = 0;
    let totalCost = 0;

    for (const tx of transactions) {
      const gallons = Number(tx.gallons);
      const revenue = Number(tx.totalAmount);
      const cost = Number(tx.totalCost) || 0;

      totalGallons += gallons;
      totalRevenue += revenue;
      totalCost += cost;

      if (!byFuelType[tx.fuelType]) {
        byFuelType[tx.fuelType] = { gallons: 0, revenue: 0, margin: 0 };
      }
      byFuelType[tx.fuelType].gallons += gallons;
      byFuelType[tx.fuelType].revenue += revenue;
      byFuelType[tx.fuelType].margin += revenue - cost;
    }

    const grossMargin = totalRevenue - totalCost;

    return {
      totalGallons,
      totalRevenue,
      totalCost,
      grossMargin,
      averageMarginPerGallon: totalGallons > 0 ? grossMargin / totalGallons : 0,
      transactionCount: transactions.length,
      byFuelType,
    };
  }

  private async calculateAutoMetrics(
    start: Date,
    end: Date
  ): Promise<{
    workOrderCount: number;
    totalRevenue: number;
    laborRevenue: number;
    partsRevenue: number;
    grossProfit: number;
    profitMargin: number;
    averageTicket: number;
    totalLaborHours: number;
    byServiceType: Record<ServiceType, { count: number; revenue: number }>;
  }> {
    const workOrders = await this.autoRepo.find({
      where: {
        serviceDate: Between(start, end),
        status: In([WorkOrderStatus.COMPLETED, WorkOrderStatus.INVOICED, WorkOrderStatus.PAID]),
      },
    });

    const byServiceType: Record<ServiceType, { count: number; revenue: number }> = {} as Record<
      ServiceType,
      { count: number; revenue: number }
    >;

    let totalRevenue = 0;
    let laborRevenue = 0;
    let partsRevenue = 0;
    let grossProfit = 0;
    let totalLaborHours = 0;

    for (const wo of workOrders) {
      const revenue = Number(wo.totalAmount);
      const labor = Number(wo.laborTotal);
      const parts = Number(wo.partsRetail);
      const profit = Number(wo.grossProfit);
      const hours = Number(wo.laborHours);

      totalRevenue += revenue;
      laborRevenue += labor;
      partsRevenue += parts;
      grossProfit += profit;
      totalLaborHours += hours;

      if (!byServiceType[wo.primaryServiceType]) {
        byServiceType[wo.primaryServiceType] = { count: 0, revenue: 0 };
      }
      byServiceType[wo.primaryServiceType].count += 1;
      byServiceType[wo.primaryServiceType].revenue += revenue;
    }

    return {
      workOrderCount: workOrders.length,
      totalRevenue,
      laborRevenue,
      partsRevenue,
      grossProfit,
      profitMargin: totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0,
      averageTicket: workOrders.length > 0 ? totalRevenue / workOrders.length : 0,
      totalLaborHours,
      byServiceType,
    };
  }

  // ============================================
  // Trend Analysis
  // ============================================

  async getFuelTrends(siteId: string, days: number = 30): Promise<FuelTrendData[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const transactions = await this.fuelRepo
      .createQueryBuilder('fuel')
      .select("DATE_TRUNC('day', fuel.transactionDate)", 'date')
      .addSelect('SUM(fuel.gallons)', 'gallons')
      .addSelect('SUM(fuel.totalAmount)', 'revenue')
      .addSelect('SUM(fuel.grossMargin)', 'margin')
      .addSelect('AVG(fuel.pricePerGallon)', 'averagePrice')
      .addSelect('COUNT(*)', 'transactionCount')
      .where('fuel.siteId = :siteId', { siteId })
      .andWhere('fuel.transactionDate >= :startDate', { startDate })
      .andWhere('fuel.transactionType = :type', { type: TransactionType.SALE })
      .groupBy("DATE_TRUNC('day', fuel.transactionDate)")
      .orderBy('date', 'ASC')
      .getRawMany();

    return transactions.map((t) => ({
      date: new Date(t.date),
      gallons: Number(t.gallons),
      revenue: Number(t.revenue),
      margin: Number(t.margin) || 0,
      averagePrice: Number(t.averagePrice),
      transactionCount: Number(t.transactionCount),
    }));
  }

  async getAutoTrends(shopId: string, days: number = 30): Promise<AutoTrendData[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const workOrders = await this.autoRepo
      .createQueryBuilder('auto')
      .select("DATE_TRUNC('day', auto.serviceDate)", 'date')
      .addSelect('COUNT(*)', 'workOrders')
      .addSelect('SUM(auto.totalAmount)', 'revenue')
      .addSelect('SUM(auto.laborTotal)', 'laborRevenue')
      .addSelect('SUM(auto.partsRetail)', 'partsRevenue')
      .addSelect('SUM(auto.grossProfit)', 'profit')
      .addSelect('SUM(auto.laborHours)', 'laborHours')
      .where('auto.shopId = :shopId', { shopId })
      .andWhere('auto.serviceDate >= :startDate', { startDate })
      .groupBy("DATE_TRUNC('day', auto.serviceDate)")
      .orderBy('date', 'ASC')
      .getRawMany();

    return workOrders.map((wo) => ({
      date: new Date(wo.date),
      workOrders: Number(wo.workOrders),
      revenue: Number(wo.revenue),
      laborRevenue: Number(wo.laborRevenue),
      partsRevenue: Number(wo.partsRevenue),
      profit: Number(wo.profit) || 0,
      laborHours: Number(wo.laborHours),
      averageTicket: Number(wo.workOrders) > 0 ? Number(wo.revenue) / Number(wo.workOrders) : 0,
    }));
  }

  // ============================================
  // Endpoint Health Monitoring
  // ============================================

  async getEndpointHealth(): Promise<EndpointHealth[]> {
    const endpoints = await this.endpointRepo.find({
      order: { lastHealthCheck: 'DESC' },
    });

    return endpoints.map((ep) => ({
      endpointId: ep.id,
      name: ep.name,
      status: ep.status,
      lastCheck: ep.lastHealthCheck,
      responseTime: ep.lastResponseTimeMs,
      uptime: Number(ep.uptimePercentage) || 0,
      consecutiveFailures: ep.consecutiveFailures,
      lastError: ep.lastErrorMessage,
    }));
  }

  async getEndpointSummary(): Promise<EndpointSummary> {
    const endpoints = await this.endpointRepo.find();

    const summary: EndpointSummary = {
      total: endpoints.length,
      byStatus: {},
      byType: {},
      byCategory: {},
      healthyPercentage: 0,
      averageResponseTime: 0,
    };

    let healthyCount = 0;
    let totalResponseTime = 0;
    let responseTimeCount = 0;

    for (const ep of endpoints) {
      // Count by status
      summary.byStatus[ep.status] = (summary.byStatus[ep.status] || 0) + 1;

      // Count by type
      summary.byType[ep.endpointType] = (summary.byType[ep.endpointType] || 0) + 1;

      // Count by category
      summary.byCategory[ep.dataCategory] = (summary.byCategory[ep.dataCategory] || 0) + 1;

      // Track healthy
      if (ep.status === EndpointStatus.ACTIVE) {
        healthyCount++;
      }

      // Track response time
      if (ep.lastResponseTimeMs) {
        totalResponseTime += ep.lastResponseTimeMs;
        responseTimeCount++;
      }
    }

    summary.healthyPercentage = endpoints.length > 0 ? (healthyCount / endpoints.length) * 100 : 0;
    summary.averageResponseTime = responseTimeCount > 0 ? totalResponseTime / responseTimeCount : 0;

    return summary;
  }

  // ============================================
  // Utility Methods
  // ============================================

  private generateClientId(): string {
    return `client_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  // Manual trigger for data refresh
  async refreshEndpoint(endpointId: string): Promise<void> {
    const endpoint = await this.endpointRepo.findOne({ where: { id: endpointId } });
    if (endpoint) {
      await this.pollEndpoint(endpoint);
    }
  }

  // Add new endpoint to polling
  async registerEndpoint(endpoint: DiscoveredEndpoint): Promise<void> {
    await this.endpointRepo.save(endpoint);
    if (endpoint.pollingEnabled && endpoint.pollIntervalSeconds) {
      this.startPolling(endpoint);
    }
  }

  // Remove endpoint from polling
  async unregisterEndpoint(endpointId: string): Promise<void> {
    this.stopPolling(endpointId);
    await this.endpointRepo.update(endpointId, { status: EndpointStatus.DEPRECATED });
  }
}

export default DataAggregationService;
