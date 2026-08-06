import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Emergency } from './entities/emergency.entity';

@Injectable()
export class EmergencyService {
  constructor(
    @InjectRepository(Emergency)
    private readonly emergencyRepository: Repository<Emergency>,
  ) {}

  async createSOS(dto: any): Promise<Emergency> {
    const sos = this.emergencyRepository.create(dto as DeepPartial<Emergency>);
    return this.emergencyRepository.save(sos);
  }


  async getActiveEmergencies(): Promise<Emergency[]> {
    return this.emergencyRepository.find({ where: { status: 'Active' } });
  }

  async assignDoctor(id: number, doctorId: number): Promise<Emergency> {
    const sos = await this.emergencyRepository.findOne({ where: { id } });
    if (sos) {
      sos.assignedDoctorId = doctorId;
      sos.status = 'Assigned';
      return this.emergencyRepository.save(sos);
    }
    return null;
  }

  async resolveSOS(id: number): Promise<Emergency> {
    const sos = await this.emergencyRepository.findOne({ where: { id } });
    if (sos) {
      sos.status = 'Resolved';
      return this.emergencyRepository.save(sos);
    }
    return null;
  }
}
