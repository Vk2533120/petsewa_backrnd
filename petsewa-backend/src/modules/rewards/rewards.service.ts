import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reward } from './entities/reward.entity';

@Injectable()
export class RewardsService {
  constructor(
    @InjectRepository(Reward)
    private readonly rewardRepository: Repository<Reward>,
  ) {}

  async getRewardStatus(userId: number): Promise<Reward> {
    let reward = await this.rewardRepository.findOne({ where: { userId } });
    if (!reward) {
      reward = this.rewardRepository.create({ userId, points: 0, level: 'Bronze', referralsCount: 0 });
      await this.rewardRepository.save(reward);
    }
    return reward;
  }

  async addPoints(userId: number, pointsToAdd: number): Promise<Reward> {
    const reward = await this.getRewardStatus(userId);
    reward.points = Number(reward.points) + pointsToAdd;
    
    // Level progression validation logic based on target limits (Page 15)
    if (reward.points >= 1000) {
      reward.level = 'Platinum';
    } else if (reward.points >= 500) {
      reward.level = 'Gold';
    } else if (reward.points >= 200) {
      reward.level = 'Silver';
    } else {
      reward.level = 'Bronze';
    }
    
    return this.rewardRepository.save(reward);
  }

  async registerReferral(referrerId: number): Promise<Reward> {
    const reward = await this.getRewardStatus(referrerId);
    reward.referralsCount += 1;
    // Award 50 points per referral activity
    return this.addPoints(referrerId, 50);
  }
}
