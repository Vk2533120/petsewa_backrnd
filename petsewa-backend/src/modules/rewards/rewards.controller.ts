import { Controller, Get, Post, Body, Param, ParseIntPipe } from '@nestjs/common';
import { RewardsService } from './rewards.service';

@Controller('rewards')
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get('user/:userId')
  async getStatus(@Param('userId', ParseIntPipe) userId: number) {
    return this.rewardsService.getRewardStatus(userId);
  }

  @Post('user/:userId/points')
  async awardPoints(
    @Param('userId', ParseIntPipe) userId: number,
    @Body('points', ParseIntPipe) points: number,
  ) {
    return this.rewardsService.addPoints(userId, points);
  }

  @Post('referral')
  async referral(@Body('referrerId', ParseIntPipe) referrerId: number) {
    return this.rewardsService.registerReferral(referrerId);
  }
}
