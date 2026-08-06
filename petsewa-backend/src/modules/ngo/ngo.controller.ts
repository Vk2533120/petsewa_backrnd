import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  ParseFloatPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { NgoService } from './ngo.service';

@Controller('ngo')
export class NgoController {
  constructor(private readonly ngoService: NgoService) {}

  // ─── NGO REGISTRATION & AUTH ──────────────────────────────────────────────

  /**
   * POST /ngo/register
   * Register a new NGO organization (status: pending admin approval)
   */
  @Post('register')
  async registerNgo(
    @Body()
    body: {
      name: string;
      email: string;
      password: string;
      registrationNumber: string;
      contactPhone?: string;
      location?: string;
      description?: string;
      imageUrl?: string;
    },
  ) {
    const ngo = await this.ngoService.registerNgo(body);
    return {
      message: 'NGO registration submitted. Pending admin approval.',
      data: { id: ngo.id, name: ngo.name, email: ngo.email, status: ngo.status },
    };
  }

  /**
   * POST /ngo/login
   * NGO login — returns NGO data if approved
   */
  @HttpCode(HttpStatus.OK)
  @Post('login')
  async ngoLogin(@Body() body: { email: string; password: string }) {
    const ngo = await this.ngoService.ngoLogin(body.email, body.password);
    return {
      message: 'Login successful.',
      data: ngo,
    };
  }

  // ─── ADMIN VERIFICATION ENDPOINTS ─────────────────────────────────────────

  /**
   * GET /ngo/admin/pending
   * Admin: get all pending NGO registrations
   */
  @Get('admin/pending')
  async getPendingNgos() {
    return this.ngoService.getAllPendingNgos();
  }

  /**
   * PATCH /ngo/:id/approve
   * Admin: approve an NGO registration
   */
  @Patch(':id/approve')
  async approveNgo(@Param('id', ParseIntPipe) id: number) {
    const ngo = await this.ngoService.approveNgo(id);
    return { message: `NGO "${ngo.name}" has been approved successfully.`, data: ngo };
  }

  /**
   * PATCH /ngo/:id/reject
   * Admin: reject an NGO registration with optional reason
   */
  @Patch(':id/reject')
  async rejectNgo(
    @Param('id', ParseIntPipe) id: number,
    @Body('reason') reason?: string,
  ) {
    const ngo = await this.ngoService.rejectNgo(id, reason);
    return { message: `NGO registration has been rejected.`, data: ngo };
  }

  // ─── NGO PROFILE ──────────────────────────────────────────────────────────

  /**
   * GET /ngo/all
   * Public: get all approved NGOs (user-facing browse)
   */
  @Get('all')
  async getAllApprovedNgos() {
    return this.ngoService.getAllApprovedNgos();
  }

  /**
   * GET /ngo/:id
   * Public: get NGO details by ID
   */
  @Get(':id')
  async getNgo(@Param('id', ParseIntPipe) id: number) {
    return this.ngoService.getNgoById(id);
  }

  /**
   * PATCH /ngo/:id/profile
   * NGO: update own profile
   */
  @Patch(':id/profile')
  async updateProfile(
    @Param('id', ParseIntPipe) id: number,
    @Body()
    body: {
      name?: string;
      contactPhone?: string;
      location?: string;
      description?: string;
      imageUrl?: string;
    },
  ) {
    return this.ngoService.updateNgoProfile(id, body);
  }

  // ─── PET MANAGEMENT ───────────────────────────────────────────────────────

  /**
   * GET /ngo/pets/all
   * Public: get all available pets across all NGOs
   */
  @Get('pets/all')
  async getAllAvailablePets() {
    return this.ngoService.getAllAvailablePets();
  }

  /**
   * GET /ngo/:id/pets
   * Public/NGO: get pets listed by a specific NGO
   */
  @Get(':id/pets')
  async getNgoPets(@Param('id', ParseIntPipe) id: number) {
    return this.ngoService.getNgoPets(id);
  }

  /**
   * POST /ngo/:id/pets
   * NGO: add a pet for adoption
   */
  @Post(':id/pets')
  async addPet(
    @Param('id', ParseIntPipe) ngoId: number,
    @Body()
    body: {
      petName: string;
      breed?: string;
      age?: string;
      gender?: string;
      description?: string;
      imageUrl?: string;
      isVaccinated?: boolean;
      healthNotes?: string;
    },
  ) {
    return this.ngoService.addPet(ngoId, body);
  }

  /**
   * DELETE /ngo/pets/:petId
   * NGO: remove a pet listing
   */
  @Delete('pets/:petId')
  async deletePet(
    @Param('petId', ParseIntPipe) petId: number,
    @Body('ngoId', ParseIntPipe) ngoId: number,
  ) {
    return this.ngoService.deletePet(petId, ngoId);
  }

  // ─── ADOPTION REQUESTS ────────────────────────────────────────────────────

  /**
   * POST /ngo/adoption-request
   * User: send an adoption request for a pet
   */
  @Post('adoption-request')
  async sendAdoptionRequest(
    @Body()
    body: {
      petId: number;
      ngoId: number;
      userId: string;
      userName: string;
      userEmail: string;
      userPhone?: string;
      message?: string;
    },
  ) {
    const request = await this.ngoService.sendAdoptionRequest(body);
    return {
      message: 'Adoption request submitted. The NGO will review and contact you.',
      data: request,
    };
  }

  /**
   * GET /ngo/:id/requests
   * NGO: view all incoming adoption requests
   */
  @Get(':id/requests')
  async getNgoRequests(@Param('id', ParseIntPipe) ngoId: number) {
    return this.ngoService.getNgoRequests(ngoId);
  }

  /**
   * GET /ngo/user-requests/:userId
   * User: view their own adoption requests
   */
  @Get('user-requests/:userId')
  async getUserRequests(@Param('userId') userId: string) {
    return this.ngoService.getUserRequests(userId);
  }

  /**
   * PATCH /ngo/requests/:id/accept
   * NGO: accept an adoption request → Contact User step
   */
  @Patch('requests/:id/accept')
  async acceptRequest(@Param('id', ParseIntPipe) requestId: number) {
    const request = await this.ngoService.acceptRequest(requestId);
    return {
      message: 'Adoption request accepted. Please contact the user to schedule a meet.',
      data: request,
    };
  }

  /**
   * PATCH /ngo/requests/:id/reject
   * NGO: reject an adoption request
   */
  @Patch('requests/:id/reject')
  async rejectRequest(
    @Param('id', ParseIntPipe) requestId: number,
    @Body('reason') reason?: string,
  ) {
    const request = await this.ngoService.rejectRequest(requestId, reason);
    return { message: 'Adoption request rejected.', data: request };
  }

  /**
   * PATCH /ngo/requests/:id/meet
   * NGO: schedule a meet & verification appointment
   */
  @Patch('requests/:id/meet')
  async scheduleMeet(
    @Param('id', ParseIntPipe) requestId: number,
    @Body('meetDateTime') meetDateTime: string,
  ) {
    const request = await this.ngoService.scheduleMeet(requestId, meetDateTime);
    return { message: 'Meet scheduled successfully.', data: request };
  }

  /**
   * PATCH /ngo/requests/:id/adopted
   * NGO: mark pet as adopted — final step
   */
  @Patch('requests/:id/adopted')
  async markAdopted(@Param('id', ParseIntPipe) requestId: number) {
    const request = await this.ngoService.markAdopted(requestId);
    return {
      message: 'Pet has been marked as adopted. Adoption status updated successfully!',
      data: request,
    };
  }

  // ─── DONATION CAMPAIGNS ───────────────────────────────────────────────────

  /**
   * POST /ngo/campaigns
   * NGO: create a fundraising campaign
   */
  @Post('campaigns')
  async createCampaign(
    @Body()
    body: {
      title: string;
      ngoName: string;
      description: string;
      targetAmount: number;
    },
  ) {
    return this.ngoService.createCampaign(body);
  }

  /**
   * GET /ngo/campaigns/active
   * Public: get all active fundraising campaigns
   */
  @Get('campaigns/active')
  async getCampaigns() {
    return this.ngoService.getActiveCampaigns();
  }

  /**
   * PATCH /ngo/campaigns/:id/donate
   * User: donate to a campaign
   */
  @Patch('campaigns/:id/donate')
  async donate(
    @Param('id', ParseIntPipe) id: number,
    @Body('amount', ParseFloatPipe) amount: number,
  ) {
    return this.ngoService.processDonation(id, amount);
  }
}
