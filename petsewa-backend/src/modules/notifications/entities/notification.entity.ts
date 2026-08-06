import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column({ default: 'SYSTEM' })
  type: string; // 'BOOKING' | 'REWARD' | 'ORDER' | 'EMERGENCY' | 'SYSTEM' | 'COMMUNITY'

  @Column()
  title: string;

  @Column()
  body: string;

  @Column({ default: false })
  isRead: boolean;

  @Column({ nullable: true })
  deepLink: string;

  @CreateDateColumn()
  createdAt: Date;
}
