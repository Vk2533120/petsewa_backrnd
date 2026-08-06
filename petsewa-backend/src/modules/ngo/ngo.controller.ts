import { Controller, Get, Post, Body, Param, Patch, ParseIntPipe, ParseFloatPipe } from '@nestjs/common';
import { NgoService } from './ngo.service';

@Controller('ngo')
export class NgoController {
  constructor(private readonly ngoService: NgoService) {}

  @Post('campaigns')
  async createCampaign(@Body() dto: any) {
    return this.ngoService.createCampaign(dto);
  }

  @Get('campaigns')
  async getCampaigns() {
    return this.ngoService.getActiveCampaigns();
  }

  @Patch('campaigns/:id/donate')
  async donate(
    @Param('id', ParseIntPipe) id: number,
    @Body('amount', ParseFloatPipe) amount: number,
  ) {
    return this.ngoService.processDonation(id, amount);
  }
}
