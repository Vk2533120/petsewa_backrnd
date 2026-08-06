import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reward } from './entities/reward.entity';
import { RewardTransaction } from './entities/reward-transaction.entity';
import { Coupon } from './entities/coupon.entity';

@Injectable()
export class RewardsService {
  constructor(
    @InjectRepository(Reward)
    private readonly rewardRepository: Repository<Reward>,
    @InjectRepository(RewardTransaction)
    private readonly transactionRepository: Repository<RewardTransaction>,
    @InjectRepository(Coupon)
    private readonly couponRepository: Repository<Coupon>,
  ) {}

  private generateReferralCode(userId: number): string {
    const randomStr = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `PET-${userId}-${randomStr}`;
  }

  async getRewardStatus(userId: number): Promise<Reward> {
    let reward = await this.rewardRepository.findOne({ where: { userId } });
    if (!reward) {
      const code = this.generateReferralCode(userId);
      reward = this.rewardRepository.create({
        userId,
        points: 0,
        totalEarnedPoints: 0,
        level: 'Bronze',
        referralsCount: 0,
        referralCode: code,
        streakDays: 0,
      });
      await this.rewardRepository.save(reward);
    } else if (!reward.referralCode) {
      reward.referralCode = this.generateReferralCode(userId);
      await this.rewardRepository.save(reward);
    }
    return reward;
  }

  async addPoints(
    userId: number,
    pointsToAdd: number,
    type: string = 'BONUS',
    title: string = 'Points Awarded',
    description: string = 'Reward points earned',
  ): Promise<Reward> {
    const reward = await this.getRewardStatus(userId);
    reward.points = Number(reward.points) + pointsToAdd;
    if (pointsToAdd > 0) {
      reward.totalEarnedPoints = Number(reward.totalEarnedPoints || 0) + pointsToAdd;
    }

    // Level progression rules (Page 15)
    if (reward.points >= 1000) {
      reward.level = 'Platinum';
    } else if (reward.points >= 500) {
      reward.level = 'Gold';
    } else if (reward.points >= 200) {
      reward.level = 'Silver';
    } else {
      reward.level = 'Bronze';
    }

    const savedReward = await this.rewardRepository.save(reward);

    // Log transaction
    const tx = this.transactionRepository.create({
      userId,
      type,
      title,
      description,
      points: pointsToAdd,
    });
    await this.transactionRepository.save(tx);

    return savedReward;
  }

  async claimDailyCheckIn(userId: number): Promise<{ reward: Reward; message: string; pointsEarned: number }> {
    const reward = await this.getRewardStatus(userId);
    const todayStr = new Date().toISOString().split('T')[0];

    if (reward.lastCheckInDate === todayStr) {
      throw new BadRequestException('You have already claimed your daily check-in reward today! Come back tomorrow.');
    }

    // Calculate streak
    let streak = reward.streakDays || 0;
    if (reward.lastCheckInDate) {
      const lastDate = new Date(reward.lastCheckInDate);
      const today = new Date(todayStr);
      const diffTime = Math.abs(today.getTime() - lastDate.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        streak += 1;
      } else {
        streak = 1; // reset streak if missed a day
      }
    } else {
      streak = 1;
    }

    // Point calculation based on streak: Day 1=10, Day 2=15, Day 3=20, Day 4=25, Day 5=30, Day 6=40, Day 7+=50
    const pointsTable = [10, 15, 20, 25, 30, 40, 50];
    const pointsEarned = pointsTable[Math.min(streak - 1, pointsTable.length - 1)];

    reward.lastCheckInDate = todayStr;
    reward.streakDays = streak;
    await this.rewardRepository.save(reward);

    const updatedReward = await this.addPoints(
      userId,
      pointsEarned,
      'DAILY_CHECKIN',
      `Daily Check-In (Day ${streak})`,
      `Claimed daily streak bonus of +${pointsEarned} Pet Points!`,
    );

    return {
      reward: updatedReward,
      message: `Awesome! You earned +${pointsEarned} points for Day ${streak} streak! 🐾`,
      pointsEarned,
    };
  }

  async applyReferralCode(
    refereeUserId: number,
    referralCode: string,
  ): Promise<{ success: boolean; message: string; pointsEarned: number }> {
    const cleanCode = referralCode.trim().toUpperCase();
    const refereeReward = await this.getRewardStatus(refereeUserId);

    if (refereeReward.referredByCode) {
      throw new BadRequestException('You have already redeemed a referral code.');
    }

    if (refereeReward.referralCode === cleanCode) {
      throw new BadRequestException('You cannot use your own referral code.');
    }

    const referrerReward = await this.rewardRepository.findOne({
      where: { referralCode: cleanCode },
    });

    if (!referrerReward) {
      throw new NotFoundException('Invalid referral code provided. Please check the code and try again.');
    }

    // Set referredByCode
    refereeReward.referredByCode = cleanCode;
    await this.rewardRepository.save(refereeReward);

    // Award Referrer (+100 Points)
    referrerReward.referralsCount += 1;
    await this.rewardRepository.save(referrerReward);
    await this.addPoints(
      referrerReward.userId,
      100,
      'REFERRAL_BONUS',
      'Referral Reward',
      `Earned +100 points for inviting a friend!`,
    );

    // Award Referee (+50 Welcome Bonus)
    await this.addPoints(
      refereeUserId,
      50,
      'REFERRAL_WELCOME',
      'Referral Welcome Bonus',
      `Earned +50 points using referral code ${cleanCode}`,
    );

    return {
      success: true,
      message: 'Referral code applied successfully! You earned +50 bonus points. 🎉',
      pointsEarned: 50,
    };
  }

  async getTransactions(userId: number): Promise<RewardTransaction[]> {
    return this.transactionRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async redeemCoupon(
    userId: number,
    pointsToRedeem: number,
    discountAmount: number,
    description: string,
  ): Promise<{ coupon: Coupon; message: string }> {
    const reward = await this.getRewardStatus(userId);

    if (reward.points < pointsToRedeem) {
      throw new BadRequestException(`Insufficient Pet Points. You need ${pointsToRedeem} points to redeem this voucher.`);
    }

    // Deduct points
    reward.points -= pointsToRedeem;
    await this.rewardRepository.save(reward);

    // Log negative point transaction
    const tx = this.transactionRepository.create({
      userId,
      type: 'REDEMPTION',
      title: 'Voucher Redemption',
      description: `Redeemed ${pointsToRedeem} points for ₹${discountAmount} voucher`,
      points: -pointsToRedeem,
    });
    await this.transactionRepository.save(tx);

    // Create coupon code
    const code = `PET-VO-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
    const coupon = this.couponRepository.create({
      userId,
      code,
      discountAmount,
      pointsSpent: pointsToRedeem,
      description,
      isUsed: false,
    });
    await this.couponRepository.save(coupon);

    return {
      coupon,
      message: `Successfully redeemed ${pointsToRedeem} points for voucher code ${code}! 🎟️`,
    };
  }

  async getUserCoupons(userId: number): Promise<Coupon[]> {
    return this.couponRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async getReferralStats(userId: number): Promise<any> {
    const reward = await this.getRewardStatus(userId);
    const referralTransactions = await this.transactionRepository.find({
      where: { userId, type: 'REFERRAL_BONUS' },
      order: { createdAt: 'DESC' },
    });

    return {
      referralCode: reward.referralCode,
      referralsCount: reward.referralsCount,
      totalEarnedFromReferrals: referralTransactions.reduce((sum, t) => sum + t.points, 0),
      history: referralTransactions,
    };
  }
}
