import { Controller, Get, Post, Body, Param, Patch, ParseIntPipe } from '@nestjs/common';
import { AdoptionService } from './adoption.service';

@Controller('adoptions')
export class AdoptionController {
  constructor(private readonly adoptionService: AdoptionService) {}

  @Post()
  async createAdoptionListing(@Body() dto: any) {
    return this.adoptionService.create(dto);
  }

  @Get()
  async getAdoptions() {
    return this.adoptionService.findAll();
  }

  @Patch(':id/apply')
  async applyForAdoption(@Param('id', ParseIntPipe) id: number) {
    return this.adoptionService.apply(id);
  }
}
