import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmergencyService } from './emergency.service';
import { EmergencyController } from './emergency.controller';
import { Emergency } from './entities/emergency.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Emergency])],
  providers: [EmergencyService],
  controllers: [EmergencyController],
  exports: [EmergencyService],
})
export class EmergencyModule {}
