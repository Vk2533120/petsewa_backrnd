import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('ngo_pets')
export class NgoPet {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  ngoId: number;

  @Column()
  petName: string;

  @Column({ nullable: true })
  breed: string;

  @Column({ nullable: true })
  age: string; // e.g. '2 years', '6 months'

  @Column({ nullable: true })
  gender: string; // 'Male' | 'Female'

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  imageUrl: string;

  @Column({ default: 'available' })
  adoptionStatus: string; // 'available' | 'requested' | 'adopted'

  @Column({ default: false })
  isVaccinated: boolean;

  @Column({ nullable: true })
  healthNotes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
