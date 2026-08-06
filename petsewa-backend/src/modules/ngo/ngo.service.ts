import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Campaign } from './entities/campaign.entity';

@Injectable()
export class NgoService {
  constructor(
    @InjectRepository(Campaign)
    private readonly campaignRepository: Repository<Campaign>,
  ) {}

  async createCampaign(dto: any): Promise<Campaign> {
    const campaign = this.campaignRepository.create(dto as DeepPartial<Campaign>);
    return this.campaignRepository.save(campaign);
  }


  async getActiveCampaigns(): Promise<Campaign[]> {
    return this.campaignRepository.find({ where: { isActive: true } });
  }

  async processDonation(id: number, amount: number): Promise<Campaign> {
    const campaign = await this.campaignRepository.findOne({ where: { id } });
    if (campaign) {
      campaign.raisedAmount = Number(campaign.raisedAmount) + Number(amount);
      if (campaign.raisedAmount >= campaign.targetAmount) {
        campaign.isActive = false; // Mark completed campaign inactive
      }
      return this.campaignRepository.save(campaign);
    }
    return null;
  }
}
