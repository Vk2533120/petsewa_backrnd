import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Campaign } from './entities/campaign.entity';
import { Ngo } from './entities/ngo.entity';
import { NgoPet } from './entities/ngo-pet.entity';
import { AdoptionRequest } from './entities/adoption-request.entity';

@Injectable()
export class NgoService {
  constructor(
    @InjectRepository(Campaign)
    private readonly campaignRepository: Repository<Campaign>,

    @InjectRepository(Ngo)
    private readonly ngoRepository: Repository<Ngo>,

    @InjectRepository(NgoPet)
    private readonly ngoPetRepository: Repository<NgoPet>,

    @InjectRepository(AdoptionRequest)
    private readonly adoptionRequestRepository: Repository<AdoptionRequest>,
  ) {}

  // ─── NGO REGISTRATION & PROFILE ───────────────────────────────────────────

  async registerNgo(dto: {
    name: string;
    email: string;
    password: string;
    registrationNumber: string;
    contactPhone?: string;
    location?: string;
    description?: string;
    imageUrl?: string;
  }): Promise<Ngo> {
    const existing = await this.ngoRepository.findOne({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException('An NGO with this email already exists.');
    }
    const regExists = await this.ngoRepository.findOne({
      where: { registrationNumber: dto.registrationNumber },
    });
    if (regExists) {
      throw new ConflictException('An NGO with this registration number already exists.');
    }
    // NOTE: In production, hash the password with bcrypt before storing
    const ngo = this.ngoRepository.create({
      ...dto,
      passwordHash: dto.password, // TODO: Replace with bcrypt.hash(dto.password, 10)
      status: 'pending',
    });
    return this.ngoRepository.save(ngo);
  }

  async ngoLogin(email: string, password: string): Promise<Ngo> {
    const ngo = await this.ngoRepository.findOne({ where: { email } });
    if (!ngo) {
      throw new NotFoundException('No NGO account found with this email.');
    }
    // NOTE: In production, use bcrypt.compare(password, ngo.passwordHash)
    if (ngo.passwordHash !== password) {
      throw new BadRequestException('Invalid credentials. Please check your password.');
    }
    if (ngo.status === 'rejected') {
      throw new BadRequestException(`Your NGO registration was rejected. Reason: ${ngo.rejectionReason || 'N/A'}`);
    }
    if (ngo.status === 'pending') {
      throw new BadRequestException('Your NGO registration is pending admin approval.');
    }
    return ngo;
  }

  async getNgoById(id: number): Promise<Ngo> {
    const ngo = await this.ngoRepository.findOne({ where: { id } });
    if (!ngo) {
      throw new NotFoundException(`NGO with ID ${id} not found.`);
    }
    return ngo;
  }

  async getAllApprovedNgos(): Promise<Ngo[]> {
    return this.ngoRepository.find({ where: { status: 'approved' } });
  }

  async getAllPendingNgos(): Promise<Ngo[]> {
    return this.ngoRepository.find({ where: { status: 'pending' } });
  }

  async updateNgoProfile(id: number, dto: Partial<Ngo>): Promise<Ngo> {
    const ngo = await this.getNgoById(id);
    Object.assign(ngo, dto);
    return this.ngoRepository.save(ngo);
  }

  // ─── ADMIN VERIFICATION ────────────────────────────────────────────────────

  async approveNgo(id: number): Promise<Ngo> {
    const ngo = await this.getNgoById(id);
    ngo.status = 'approved';
    return this.ngoRepository.save(ngo);
  }

  async rejectNgo(id: number, reason?: string): Promise<Ngo> {
    const ngo = await this.getNgoById(id);
    ngo.status = 'rejected';
    ngo.rejectionReason = reason || 'Did not meet verification requirements.';
    return this.ngoRepository.save(ngo);
  }

  // ─── NGO PET MANAGEMENT ────────────────────────────────────────────────────

  async addPet(ngoId: number, dto: {
    petName: string;
    breed?: string;
    age?: string;
    gender?: string;
    description?: string;
    imageUrl?: string;
    isVaccinated?: boolean;
    healthNotes?: string;
  }): Promise<NgoPet> {
    // Verify NGO is approved
    const ngo = await this.getNgoById(ngoId);
    if (ngo.status !== 'approved') {
      throw new BadRequestException('Only approved NGOs can add pet listings.');
    }
    const pet = this.ngoPetRepository.create({ ...dto, ngoId, adoptionStatus: 'available' });
    return this.ngoPetRepository.save(pet);
  }

  async getNgoPets(ngoId: number): Promise<NgoPet[]> {
    return this.ngoPetRepository.find({ where: { ngoId } });
  }

  async getAllAvailablePets(): Promise<NgoPet[]> {
    return this.ngoPetRepository.find({ where: { adoptionStatus: 'available' } });
  }

  async getPetById(petId: number): Promise<NgoPet> {
    const pet = await this.ngoPetRepository.findOne({ where: { id: petId } });
    if (!pet) {
      throw new NotFoundException(`Pet with ID ${petId} not found.`);
    }
    return pet;
  }

  async deletePet(petId: number, ngoId: number): Promise<{ message: string }> {
    const pet = await this.getPetById(petId);
    if (pet.ngoId !== ngoId) {
      throw new BadRequestException('You can only delete pets belonging to your NGO.');
    }
    await this.ngoPetRepository.delete(petId);
    return { message: 'Pet listing removed successfully.' };
  }

  // ─── ADOPTION REQUESTS ─────────────────────────────────────────────────────

  async sendAdoptionRequest(dto: {
    petId: number;
    ngoId: number;
    userId: string;
    userName: string;
    userEmail: string;
    userPhone?: string;
    message?: string;
  }): Promise<AdoptionRequest> {
    // Check if pet is still available
    const pet = await this.getPetById(dto.petId);
    if (pet.adoptionStatus !== 'available') {
      throw new BadRequestException('This pet is no longer available for adoption.');
    }
    // Check if user already sent a request for this pet
    const existing = await this.adoptionRequestRepository.findOne({
      where: { petId: dto.petId, userId: dto.userId },
    });
    if (existing) {
      throw new ConflictException('You have already submitted an adoption request for this pet.');
    }
    // Mark pet as requested
    pet.adoptionStatus = 'requested';
    await this.ngoPetRepository.save(pet);

    const request = this.adoptionRequestRepository.create({ ...dto, status: 'pending' });
    return this.adoptionRequestRepository.save(request);
  }

  async getNgoRequests(ngoId: number): Promise<AdoptionRequest[]> {
    return this.adoptionRequestRepository.find({
      where: { ngoId },
      order: { createdAt: 'DESC' },
    });
  }

  async getUserRequests(userId: string): Promise<AdoptionRequest[]> {
    return this.adoptionRequestRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async acceptRequest(requestId: number): Promise<AdoptionRequest> {
    const request = await this.adoptionRequestRepository.findOne({ where: { id: requestId } });
    if (!request) {
      throw new NotFoundException(`Adoption request with ID ${requestId} not found.`);
    }
    if (request.status !== 'pending') {
      throw new BadRequestException('Only pending requests can be accepted.');
    }
    request.status = 'accepted';
    return this.adoptionRequestRepository.save(request);
  }

  async rejectRequest(requestId: number, reason?: string): Promise<AdoptionRequest> {
    const request = await this.adoptionRequestRepository.findOne({ where: { id: requestId } });
    if (!request) {
      throw new NotFoundException(`Adoption request with ID ${requestId} not found.`);
    }
    if (request.status !== 'pending') {
      throw new BadRequestException('Only pending requests can be rejected.');
    }
    request.status = 'rejected';
    request.rejectionReason = reason || 'The NGO has declined your adoption request.';
    // Revert pet to available so others can apply
    const pet = await this.ngoPetRepository.findOne({ where: { id: request.petId } });
    if (pet) {
      pet.adoptionStatus = 'available';
      await this.ngoPetRepository.save(pet);
    }
    return this.adoptionRequestRepository.save(request);
  }

  async scheduleMeet(requestId: number, meetDateTime: string): Promise<AdoptionRequest> {
    const request = await this.adoptionRequestRepository.findOne({ where: { id: requestId } });
    if (!request) {
      throw new NotFoundException(`Adoption request with ID ${requestId} not found.`);
    }
    if (request.status !== 'accepted') {
      throw new BadRequestException('Can only schedule a meet for accepted requests.');
    }
    request.meetScheduledAt = meetDateTime;
    return this.adoptionRequestRepository.save(request);
  }

  async markAdopted(requestId: number): Promise<AdoptionRequest> {
    const request = await this.adoptionRequestRepository.findOne({ where: { id: requestId } });
    if (!request) {
      throw new NotFoundException(`Adoption request with ID ${requestId} not found.`);
    }
    if (request.status !== 'accepted') {
      throw new BadRequestException('Only accepted requests can be marked as adopted.');
    }
    request.status = 'adopted';

    // Update pet status to adopted
    const pet = await this.ngoPetRepository.findOne({ where: { id: request.petId } });
    if (pet) {
      pet.adoptionStatus = 'adopted';
      await this.ngoPetRepository.save(pet);
    }
    return this.adoptionRequestRepository.save(request);
  }

  // ─── DONATION CAMPAIGNS ────────────────────────────────────────────────────

  async createCampaign(dto: {
    title: string;
    ngoName: string;
    description: string;
    targetAmount: number;
  }): Promise<Campaign> {
    const campaign = this.campaignRepository.create({ ...dto, isActive: true });
    return this.campaignRepository.save(campaign);
  }

  async getActiveCampaigns(): Promise<Campaign[]> {
    return this.campaignRepository.find({ where: { isActive: true } });
  }

  async processDonation(id: number, amount: number): Promise<Campaign> {
    const campaign = await this.campaignRepository.findOne({ where: { id } });
    if (!campaign) {
      throw new NotFoundException(`Campaign with ID ${id} not found.`);
    }
    if (!campaign.isActive) {
      throw new BadRequestException('This campaign has already reached its target or is inactive.');
    }
    campaign.raisedAmount = Number(campaign.raisedAmount) + Number(amount);
    if (campaign.raisedAmount >= campaign.targetAmount) {
      campaign.isActive = false; // Mark completed campaign inactive
    }
    return this.campaignRepository.save(campaign);
  }
}
