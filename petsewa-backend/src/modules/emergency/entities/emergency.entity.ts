import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('emergencies')
export class Emergency {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  petType: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  longitude: number;

  @Column({ default: 'Active' })
  status: string; // 'Active' | 'Assigned' | 'Resolved'

  @Column({ nullable: true })
  assignedDoctorId: number;

  @CreateDateColumn()
  createdAt: Date;
}
