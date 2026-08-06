import { Controller, Get, Post, Body, Param, Patch, ParseIntPipe } from '@nestjs/common';
import { LostFoundService } from './lostfound.service';

@Controller('lost-found')
export class LostFoundController {
  constructor(private readonly lostFoundService: LostFoundService) {}

  @Post()
  async createReport(@Body() dto: any) {
    return this.lostFoundService.create(dto);
  }

  @Get()
  async getReports() {
    return this.lostFoundService.findAll();
  }

  @Patch(':id/resolve')
  async resolveReport(@Param('id', ParseIntPipe) id: number) {
    return this.lostFoundService.resolve(id);
  }
}
