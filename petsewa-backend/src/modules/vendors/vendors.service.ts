import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Vendor } from './entities/vendor.entity';

@Injectable()
export class VendorsService {
  constructor(
    @InjectRepository(Vendor)
    private readonly vendorRepository: Repository<Vendor>,
  ) {}

  async create(createVendorDto: any): Promise<Vendor> {
    const newVendor = this.vendorRepository.create(createVendorDto as DeepPartial<Vendor>);
    return this.vendorRepository.save(newVendor);
  }


  async findAll(): Promise<Vendor[]> {
    return this.vendorRepository.find({ where: { isActive: true } });
  }

  async findOne(id: number): Promise<Vendor> {
    const vendor = await this.vendorRepository.findOne({ where: { id, isActive: true } });
    if (!vendor) {
      throw new NotFoundException(`Vendor profile with ID ${id} not found.`);
    }
    return vendor;
  }

  // Hyperlocal Search Engine Algorithm: Haversine Formula query mapping
  async findNearby(lat: number, lon: number, radiusInKms: number = 10, category?: string): Promise<any[]> {
    const queryBuilder = this.vendorRepository.createQueryBuilder('vendor')
      .where('vendor.isActive = :isActive', { isActive: true });

    if (category) {
      queryBuilder.andWhere('vendor.category = :category', { category });
    }

    // Distance calculation using SQL coordinates matching
    // 6371 is Earth's radius in kilometers
    queryBuilder.addSelect(
      `6371 * acos(
        cos(radians(:lat)) * cos(radians(vendor.latitude)) * 
        cos(radians(vendor.longitude) - radians(:lon)) + 
        sin(radians(:lat)) * sin(radians(vendor.latitude))
      )`,
      'distance',
    )
    .setParameter('lat', lat)
    .setParameter('lon', lon)
    .having('distance <= :radius', { radius: radiusInKms })
    .orderBy('distance', 'ASC');

    return queryBuilder.getRawMany();
  }
}
