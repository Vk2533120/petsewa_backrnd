import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NgoService } from './ngo.service';
import { NgoController } from './ngo.controller';
import { Campaign } from './entities/campaign.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Campaign])],
  providers: [NgoService],
  controllers: [NgoController],
  exports: [NgoService],
})
export class NgoModule {}
