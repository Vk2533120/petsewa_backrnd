import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn, CreateDateColumn } from 'typeorm';

@Entity('rewards')
export class Reward {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  userId: number;

  @Column({ unique: true, nullable: true })
  referralCode: string;

  @Column({ nullable: true })
  referredByCode: string;

  @Column({ default: 0 })
  points: number;

  @Column({ default: 0 })
  totalEarnedPoints: number;

  @Column({ default: 'Bronze' })
  level: string; // 'Bronze' | 'Silver' | 'Gold' | 'Platinum'

  @Column({ default: 0 })
  referralsCount: number;

  @Column({ nullable: true })
  lastCheckInDate: string; // YYYY-MM-DD string format

  @Column({ default: 0 })
  streakDays: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

