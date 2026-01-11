import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

export enum FuelType {
  REGULAR = 'regular',
  MIDGRADE = 'midgrade',
  PREMIUM = 'premium',
  DIESEL = 'diesel',
  E85 = 'e85',
}

export enum TransactionType {
  SALE = 'sale',
  DELIVERY = 'delivery',
  ADJUSTMENT = 'adjustment',
  RETURN = 'return',
}

export enum PaymentMethod {
  CASH = 'cash',
  CREDIT = 'credit',
  DEBIT = 'debit',
  FLEET = 'fleet',
  LOYALTY = 'loyalty',
  VOYAGER = 'voyager',
  WEX = 'wex',
  EBT = 'ebt',
}

export enum TransactionStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
  FAILED = 'failed',
}

@Entity('fuel_operations')
@Index(['siteId', 'transactionDate'])
@Index(['transactionType', 'status'])
@Index(['fuelType', 'transactionDate'])
export class FuelOperation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Site identification
  @Column({ type: 'varchar', length: 50 })
  @Index()
  siteId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  siteName: string;

  // Transaction details
  @Column({ type: 'varchar', length: 100, unique: true })
  transactionId: string;

  @Column({ type: 'enum', enum: TransactionType, default: TransactionType.SALE })
  transactionType: TransactionType;

  @Column({ type: 'enum', enum: TransactionStatus, default: TransactionStatus.COMPLETED })
  status: TransactionStatus;

  @Column({ type: 'timestamp with time zone' })
  @Index()
  transactionDate: Date;

  // Fuel information
  @Column({ type: 'enum', enum: FuelType })
  fuelType: FuelType;

  @Column({ type: 'decimal', precision: 10, scale: 3 })
  gallons: number;

  @Column({ type: 'decimal', precision: 10, scale: 4 })
  pricePerGallon: number;

  @Column({ type: 'decimal', precision: 10, scale: 4, nullable: true })
  costPerGallon: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  totalAmount: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  totalCost: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  grossMargin: number;

  // Pump/Dispenser info
  @Column({ type: 'int', nullable: true })
  pumpNumber: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  dispenserId: string;

  // Tank information
  @Column({ type: 'int', nullable: true })
  tankNumber: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  tankLevelBefore: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  tankLevelAfter: number;

  // Payment information
  @Column({ type: 'enum', enum: PaymentMethod, nullable: true })
  paymentMethod: PaymentMethod;

  @Column({ type: 'varchar', length: 50, nullable: true })
  cardLastFour: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  authorizationCode: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  processingFee: number;

  // Loyalty/Fleet
  @Column({ type: 'varchar', length: 100, nullable: true })
  loyaltyCardNumber: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  discountAmount: number;

  @Column({ type: 'varchar', length: 100, nullable: true })
  fleetCardNumber: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  vehicleId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  driverId: string;

  // Delivery specific fields
  @Column({ type: 'varchar', length: 100, nullable: true })
  deliveryTicketNumber: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  supplierName: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  carrierName: string;

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

  @Column({ type: 'varchar', length: 50, nullable: true })
  shiftId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  employeeId: string;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Calculated properties
  get marginPerGallon(): number | null {
    if (this.pricePerGallon && this.costPerGallon) {
      return Number(this.pricePerGallon) - Number(this.costPerGallon);
    }
    return null;
  }

  get marginPercentage(): number | null {
    if (this.totalAmount && this.totalCost) {
      return ((Number(this.totalAmount) - Number(this.totalCost)) / Number(this.totalAmount)) * 100;
    }
    return null;
  }
}

// DTOs for API responses
export interface FuelOperationSummary {
  siteId: string;
  siteName: string;
  period: {
    start: Date;
    end: Date;
  };
  totalGallons: number;
  totalRevenue: number;
  totalCost: number;
  grossMargin: number;
  averageMarginPerGallon: number;
  transactionCount: number;
  byFuelType: {
    [key in FuelType]?: {
      gallons: number;
      revenue: number;
      cost: number;
      margin: number;
      avgPrice: number;
      transactionCount: number;
    };
  };
  byPaymentMethod: {
    [key in PaymentMethod]?: {
      amount: number;
      transactionCount: number;
      processingFees: number;
    };
  };
}

export interface FuelTrendData {
  date: Date;
  gallons: number;
  revenue: number;
  margin: number;
  averagePrice: number;
  transactionCount: number;
}

export interface TankLevelData {
  tankNumber: number;
  fuelType: FuelType;
  currentLevel: number;
  capacity: number;
  percentFull: number;
  lastDelivery: Date | null;
  projectedEmptyDate: Date | null;
  averageDailyUsage: number;
}

export interface FuelInventorySnapshot {
  siteId: string;
  timestamp: Date;
  tanks: TankLevelData[];
  totalInventoryValue: number;
}
