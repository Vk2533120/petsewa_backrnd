import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('lost_found')
export class LostFound {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  petName: string;

  @Column()
  reportType: string; // 'Lost' | 'Found'

  @Column()
  location: string;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude: number;

  @Column({ nullable: true })
  contactPhone: string;

  @Column({ default: 'Open' })
  status: string; // 'Open' | 'Resolved'

  @Column({ nullable: true })
  imageUrl: string;

  @CreateDateColumn()
  createdAt: Date;
}
