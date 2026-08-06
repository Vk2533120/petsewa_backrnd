import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LostFound } from './entities/lostfound.entity';

@Injectable()
export class LostFoundService {
  constructor(
    @InjectRepository(LostFound)
    private readonly lostFoundRepository: Repository<LostFound>,
  ) {}

  async create(dto: any): Promise<LostFound> {
    const report = this.lostFoundRepository.create(dto);
    return this.lostFoundRepository.save(report);
  }

  async findAll(): Promise<LostFound[]> {
    return this.lostFoundRepository.find({ where: { status: 'Open' } });
  }

  async resolve(id: number): Promise<LostFound> {
    const report = await this.lostFoundRepository.findOne({ where: { id } });
    if (report) {
      report.status = 'Resolved';
      return this.lostFoundRepository.save(report);
    }
    return null;
  }
}
