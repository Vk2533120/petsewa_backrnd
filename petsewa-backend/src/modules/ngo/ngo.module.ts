import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NgoService } from './ngo.service';
import { NgoController } from './ngo.controller';
import { Campaign } from './entities/campaign.entity';
import { Ngo } from './entities/ngo.entity';
import { NgoPet } from './entities/ngo-pet.entity';
import { AdoptionRequest } from './entities/adoption-request.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Campaign, Ngo, NgoPet, AdoptionRequest])],
  providers: [NgoService],
  controllers: [NgoController],
  exports: [NgoService],
})
export class NgoModule {}
