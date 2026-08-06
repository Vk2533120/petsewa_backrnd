import { Controller, Get, Post, Body, Param, Patch, ParseIntPipe } from '@nestjs/common';
import { EmergencyService } from './emergency.service';

@Controller('emergency')
export class EmergencyController {
  constructor(private readonly emergencyService: EmergencyService) {}

  @Post('sos')
  async triggerSOS(@Body() dto: any) {
    return this.emergencyService.createSOS(dto);
  }

  @Get('active')
  async getActive() {
    return this.emergencyService.getActiveEmergencies();
  }

  @Patch(':id/assign')
  async assign(
    @Param('id', ParseIntPipe) id: number,
    @Body('doctorId', ParseIntPipe) doctorId: number,
  ) {
    return this.emergencyService.assignDoctor(id, doctorId);
  }

  @Patch(':id/resolve')
  async resolve(@Param('id', ParseIntPipe) id: number) {
    return this.emergencyService.resolveSOS(id);
  }
}
