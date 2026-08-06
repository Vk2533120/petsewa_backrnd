import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('adoption_requests')
export class AdoptionRequest {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  petId: number;

  @Column()
  ngoId: number;

  // Supabase UUID string from user auth
  @Column()
  userId: string;

  @Column()
  userName: string;

  @Column()
  userEmail: string;

  @Column({ nullable: true })
  userPhone: string;

  @Column({ type: 'text', nullable: true })
  message: string;

  @Column({ default: 'pending' })
  status: string; // 'pending' | 'accepted' | 'rejected' | 'adopted'

  @Column({ nullable: true })
  meetScheduledAt: string;

  @Column({ nullable: true })
  rejectionReason: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
