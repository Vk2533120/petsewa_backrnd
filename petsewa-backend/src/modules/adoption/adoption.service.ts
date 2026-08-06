import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Adoption } from './entities/adoption.entity';

@Injectable()
export class AdoptionService {
  constructor(
    @InjectRepository(Adoption)
    private readonly adoptionRepository: Repository<Adoption>,
  ) {}

  async create(dto: any): Promise<Adoption> {
    const adoption = this.adoptionRepository.create(dto as DeepPartial<Adoption>);
    return this.adoptionRepository.save(adoption);
  }


  async findAll(): Promise<Adoption[]> {
    return this.adoptionRepository.find({ where: { status: 'Available' } });
  }

  async apply(id: number): Promise<Adoption> {
    const adoption = await this.adoptionRepository.findOne({ where: { id } });
    if (adoption) {
      adoption.status = 'Applied';
      return this.adoptionRepository.save(adoption);
    }
    return null;
  }
}
