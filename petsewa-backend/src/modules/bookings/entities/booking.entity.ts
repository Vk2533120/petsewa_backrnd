import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  vendorId: number;

  @Column()
  serviceType: string; // 'veterinarian' | 'grooming' | 'training' | 'walker'

  @Column({ type: 'timestamp' })
  bookingDate: Date;

  @Column({ default: 'pending' })
  status: string; // 'pending' | 'confirmed' | 'in-progress' | 'completed' | 'cancelled'

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ default: 'unpaid' })
  paymentStatus: string; // 'unpaid' | 'paid' | 'refunded'

  @Column({ nullable: true })
  additionalNotes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
