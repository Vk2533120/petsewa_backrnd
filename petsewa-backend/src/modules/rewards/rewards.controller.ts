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
    @Body('type') type?: string,
    @Body('title') title?: string,
    @Body('description') description?: string,
  ) {
    return this.rewardsService.addPoints(userId, points, type, title, description);
  }

  @Post('user/:userId/daily-checkin')
  async dailyCheckIn(@Param('userId', ParseIntPipe) userId: number) {
    return this.rewardsService.claimDailyCheckIn(userId);
  }

  @Post('user/:userId/apply-referral')
  async applyReferral(
    @Param('userId', ParseIntPipe) userId: number,
    @Body('referralCode') referralCode: string,
  ) {
    return this.rewardsService.applyReferralCode(userId, referralCode);
  }

  @Get('user/:userId/transactions')
  async getTransactions(@Param('userId', ParseIntPipe) userId: number) {
    return this.rewardsService.getTransactions(userId);
  }

  @Post('user/:userId/redeem')
  async redeemCoupon(
    @Param('userId', ParseIntPipe) userId: number,
    @Body('pointsToRedeem', ParseIntPipe) pointsToRedeem: number,
    @Body('discountAmount') discountAmount: number,
    @Body('description') description: string,
  ) {
    return this.rewardsService.redeemCoupon(userId, pointsToRedeem, discountAmount, description);
  }

  @Get('user/:userId/coupons')
  async getCoupons(@Param('userId', ParseIntPipe) userId: number) {
    return this.rewardsService.getUserCoupons(userId);
  }

  @Get('user/:userId/referral-stats')
  async getReferralStats(@Param('userId', ParseIntPipe) userId: number) {
    return this.rewardsService.getReferralStats(userId);
  }
}
