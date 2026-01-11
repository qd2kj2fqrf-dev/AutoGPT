import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  OneToMany,
} from 'typeorm';

export enum ServiceType {
  OIL_CHANGE = 'oil_change',
  BRAKE_SERVICE = 'brake_service',
  TIRE_SERVICE = 'tire_service',
  ALIGNMENT = 'alignment',
  INSPECTION = 'inspection',
  DIAGNOSTIC = 'diagnostic',
  ENGINE_REPAIR = 'engine_repair',
  TRANSMISSION = 'transmission',
  ELECTRICAL = 'electrical',
  AC_SERVICE = 'ac_service',
  SUSPENSION = 'suspension',
  EXHAUST = 'exhaust',
  GENERAL_MAINTENANCE = 'general_maintenance',
  BODY_WORK = 'body_work',
  OTHER = 'other',
}

export enum WorkOrderStatus {
  ESTIMATE = 'estimate',
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  WAITING_PARTS = 'waiting_parts',
  WAITING_APPROVAL = 'waiting_approval',
  COMPLETED = 'completed',
  INVOICED = 'invoiced',
  PAID = 'paid',
  CANCELLED = 'cancelled',
}

export enum PaymentStatus {
  UNPAID = 'unpaid',
  PARTIAL = 'partial',
  PAID = 'paid',
  REFUNDED = 'refunded',
}

export enum VehicleType {
  SEDAN = 'sedan',
  SUV = 'suv',
  TRUCK = 'truck',
  VAN = 'van',
  MOTORCYCLE = 'motorcycle',
  COMMERCIAL = 'commercial',
  FLEET = 'fleet',
  OTHER = 'other',
}

@Entity('auto_operations')
@Index(['shopId', 'serviceDate'])
@Index(['status', 'serviceDate'])
@Index(['customerId'])
@Index(['vehicleVin'])
export class AutoOperation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Shop identification
  @Column({ type: 'varchar', length: 50 })
  @Index()
  shopId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  shopName: string;

  // Work order details
  @Column({ type: 'varchar', length: 100, unique: true })
  workOrderNumber: string;

  @Column({ type: 'enum', enum: WorkOrderStatus, default: WorkOrderStatus.PENDING })
  status: WorkOrderStatus;

  @Column({ type: 'timestamp with time zone' })
  @Index()
  serviceDate: Date;

  @Column({ type: 'timestamp with time zone', nullable: true })
  completedDate: Date;

  @Column({ type: 'timestamp with time zone', nullable: true })
  promisedDate: Date;

  // Customer information
  @Column({ type: 'varchar', length: 100, nullable: true })
  customerId: string;

  @Column({ type: 'varchar', length: 100 })
  customerName: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  customerEmail: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  customerPhone: string;

  @Column({ type: 'text', nullable: true })
  customerAddress: string;

  @Column({ type: 'boolean', default: false })
  isFleetCustomer: boolean;

  @Column({ type: 'varchar', length: 100, nullable: true })
  fleetAccountId: string;

  // Vehicle information
  @Column({ type: 'varchar', length: 17, nullable: true })
  @Index()
  vehicleVin: string;

  @Column({ type: 'int', nullable: true })
  vehicleYear: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  vehicleMake: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  vehicleModel: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  vehicleTrim: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  vehicleEngine: string;

  @Column({ type: 'enum', enum: VehicleType, nullable: true })
  vehicleType: VehicleType;

  @Column({ type: 'varchar', length: 20, nullable: true })
  vehicleLicensePlate: string;

  @Column({ type: 'varchar', length: 30, nullable: true })
  vehicleColor: string;

  @Column({ type: 'int', nullable: true })
  mileageIn: number;

  @Column({ type: 'int', nullable: true })
  mileageOut: number;

  // Service details
  @Column({ type: 'enum', enum: ServiceType })
  primaryServiceType: ServiceType;

  @Column({ type: 'simple-array', nullable: true })
  additionalServiceTypes: ServiceType[];

  @Column({ type: 'text', nullable: true })
  customerConcern: string;

  @Column({ type: 'text', nullable: true })
  technicianNotes: string;

  @Column({ type: 'text', nullable: true })
  serviceDescription: string;

  @Column({ type: 'text', nullable: true })
  recommendation: string;

  // Labor and parts
  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  laborHours: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  laborRate: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  laborTotal: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  partsCost: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  partsRetail: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  partsMargin: number;

  @Column({ type: 'jsonb', nullable: true })
  partsUsed: PartLineItem[];

  // Sublet work
  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  subletCost: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  subletRetail: number;

  @Column({ type: 'varchar', length: 100, nullable: true })
  subletVendor: string;

  // Fees and totals
  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  shopSuppliesFee: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  environmentalFee: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  miscFees: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  discountAmount: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  discountReason: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  subtotal: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  taxRate: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  taxAmount: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  totalAmount: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  grossProfit: number;

  // Payment information
  @Column({ type: 'enum', enum: PaymentStatus, default: PaymentStatus.UNPAID })
  paymentStatus: PaymentStatus;

  @Column({ type: 'varchar', length: 50, nullable: true })
  paymentMethod: string;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  amountPaid: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  balanceDue: number;

  @Column({ type: 'timestamp with time zone', nullable: true })
  paymentDate: Date;

  @Column({ type: 'varchar', length: 100, nullable: true })
  invoiceNumber: string;

  // Technician assignment
  @Column({ type: 'varchar', length: 100, nullable: true })
  technicianId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  technicianName: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  serviceAdvisorId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  serviceAdvisorName: string;

  // Warranty
  @Column({ type: 'boolean', default: false })
  isWarrantyWork: boolean;

  @Column({ type: 'varchar', length: 100, nullable: true })
  warrantyClaimNumber: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  warrantyVendor: string;

  // Source tracking
  @Column({ type: 'varchar', length: 50 })
  sourceSystem: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  sourceEndpointId: string;

  @Column({ type: 'jsonb', nullable: true })
  rawData: Record<string, unknown>;

  // Metadata
  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, unknown>;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Calculated properties
  get effectiveLaborRate(): number | null {
    if (this.laborHours && this.laborTotal) {
      return Number(this.laborTotal) / Number(this.laborHours);
    }
    return null;
  }

  get partsMarkupPercentage(): number | null {
    if (this.partsCost && this.partsRetail) {
      return ((Number(this.partsRetail) - Number(this.partsCost)) / Number(this.partsCost)) * 100;
    }
    return null;
  }

  get profitMarginPercentage(): number | null {
    if (this.totalAmount && this.grossProfit) {
      return (Number(this.grossProfit) / Number(this.totalAmount)) * 100;
    }
    return null;
  }
}

// Part line item interface
export interface PartLineItem {
  partNumber: string;
  description: string;
  quantity: number;
  cost: number;
  retail: number;
  vendor?: string;
  isSpecialOrder?: boolean;
  coreCharge?: number;
  warrantyMonths?: number;
}

// DTOs for API responses
export interface AutoOperationSummary {
  shopId: string;
  shopName: string;
  period: {
    start: Date;
    end: Date;
  };
  workOrderCount: number;
  totalRevenue: number;
  laborRevenue: number;
  partsRevenue: number;
  subletRevenue: number;
  totalCost: number;
  grossProfit: number;
  profitMargin: number;
  averageTicket: number;
  totalLaborHours: number;
  effectiveLaborRate: number;
  partsMarkup: number;
  byServiceType: {
    [key in ServiceType]?: {
      count: number;
      revenue: number;
      profit: number;
      avgTicket: number;
    };
  };
  byTechnician: {
    [technicianId: string]: {
      name: string;
      workOrders: number;
      laborHours: number;
      revenue: number;
      efficiency: number;
    };
  };
  byStatus: {
    [key in WorkOrderStatus]?: number;
  };
}

export interface AutoTrendData {
  date: Date;
  workOrders: number;
  revenue: number;
  laborRevenue: number;
  partsRevenue: number;
  profit: number;
  laborHours: number;
  averageTicket: number;
}

export interface TechnicianPerformance {
  technicianId: string;
  technicianName: string;
  workOrdersCompleted: number;
  totalLaborHours: number;
  billedHours: number;
  efficiency: number;
  revenueGenerated: number;
  averageTicket: number;
  comebackRate: number;
  customerRating: number | null;
}

export interface VehicleServiceHistory {
  vehicleVin: string;
  vehicleInfo: {
    year: number;
    make: string;
    model: string;
    engine: string;
  };
  totalVisits: number;
  totalSpent: number;
  lastVisit: Date;
  services: Array<{
    workOrderNumber: string;
    date: Date;
    serviceType: ServiceType;
    mileage: number;
    total: number;
    description: string;
  }>;
  upcomingRecommendations: Array<{
    service: string;
    estimatedMileage: number;
    priority: 'low' | 'medium' | 'high';
  }>;
}

export interface CustomerProfile {
  customerId: string;
  name: string;
  email: string;
  phone: string;
  isFleet: boolean;
  vehicles: Array<{
    vin: string;
    year: number;
    make: string;
    model: string;
    lastService: Date;
  }>;
  lifetime: {
    visits: number;
    spent: number;
    avgTicket: number;
    firstVisit: Date;
  };
  recentActivity: AutoOperation[];
}
