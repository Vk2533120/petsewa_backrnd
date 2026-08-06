import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity('rewards')
export class Reward {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  userId: number;

  @Column({ default: 0 })
  points: number;

  @Column({ default: 'Bronze' })
  level: string; // 'Bronze' | 'Silver' | 'Gold' | 'Platinum'

  @Column({ default: 0 })
  referralsCount: number;

  @UpdateDateColumn()
  updatedAt: Date;
}
