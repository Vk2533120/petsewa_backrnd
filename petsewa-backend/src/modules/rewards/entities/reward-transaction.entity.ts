import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('reward_transactions')
export class RewardTransaction {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  type: string; // 'BOOKING' | 'PURCHASE' | 'REFERRAL_BONUS' | 'REFERRAL_WELCOME' | 'DAILY_CHECKIN' | 'ADOPTION' | 'SOCIAL_ACTIVITY' | 'REDEMPTION'

  @Column()
  title: string;

  @Column({ nullable: true })
  description: string;

  @Column()
  points: number; // positive for earned, negative for spent

  @CreateDateColumn()
  createdAt: Date;
}
