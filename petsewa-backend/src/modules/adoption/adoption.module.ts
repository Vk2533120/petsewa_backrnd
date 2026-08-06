import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdoptionService } from './adoption.service';
import { AdoptionController } from './adoption.controller';
import { Adoption } from './entities/adoption.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Adoption])],
  providers: [AdoptionService],
  controllers: [AdoptionController],
  exports: [AdoptionService],
})
export class AdoptionModule {}
