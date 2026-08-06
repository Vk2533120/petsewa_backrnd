import { Controller, Get, Post, Body, Param, Query, ParseIntPipe, ParseFloatPipe } from '@nestjs/common';
import { VendorsService } from './vendors.service';

@Controller('vendors')
export class VendorsController {
  constructor(private readonly vendorsService: VendorsService) {}

  @Post()
  async registerVendor(@Body() createVendorDto: any) {
    return this.vendorsService.create(createVendorDto);
  }

  @Get()
  async getAllActiveVendors() {
    return this.vendorsService.findAll();
  }

  // API Route for Hyperlocal Locations Search
  // e.g. GET /vendors/search/nearby?lat=28.6139&lon=77.2090&radius=15&category=vet
  @Get('search/nearby')
  async searchNearby(
    @Query('lat', ParseFloatPipe) lat: number,
    @Query('lon', ParseFloatPipe) lon: number,
    @Query('radius') radius?: number,
    @Query('category') category?: string,
  ) {
    return this.vendorsService.findNearby(lat, lon, radius || 10, category);
  }

  @Get(':id')
  async getVendorProfile(@Param('id', ParseIntPipe) id: number) {
    return this.vendorsService.findOne(id);
  }
}
