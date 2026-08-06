import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('adoptions')
export class Adoption {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  petName: string;

  @Column()
  breed: string;

  @Column()
  age: string;

  @Column()
  gender: string;

  @Column({ default: 'Available' })
  status: string; // 'Available' | 'Applied' | 'Adopted'

  @Column({ nullable: true })
  imageUrl: string;

  @Column({ nullable: true })
  description: string;

  @CreateDateColumn()
  createdAt: Date;
}
