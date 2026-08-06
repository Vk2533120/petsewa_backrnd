import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LostFoundService } from './lostfound.service';
import { LostFoundController } from './lostfound.controller';
import { LostFound } from './entities/lostfound.entity';

@Module({
  imports: [TypeOrmModule.forFeature([LostFound])],
  providers: [LostFoundService],
  controllers: [LostFoundController],
  exports: [LostFoundService],
})
export class LostFoundModule {}
