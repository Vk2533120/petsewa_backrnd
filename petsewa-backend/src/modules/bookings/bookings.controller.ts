import { Controller, Post, Get, Body, Param, Patch, ParseIntPipe, Query } from '@nestjs/common';
import { BookingsService } from './bookings.service';

@Controller('bookings')
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  async createNewBooking(@Body() createBookingDto: any) {
    return this.bookingsService.createBooking(createBookingDto);
  }

  @Get('user/:userId')
  async getBookingsForUser(@Param('userId', ParseIntPipe) userId: number) {
    return this.bookingsService.getBookingsByUser(userId);
  }

  @Get('vendor/:vendorId')
  async getBookingsForVendor(@Param('vendorId', ParseIntPipe) vendorId: number) {
    return this.bookingsService.getBookingsByVendor(vendorId);
  }

  @Patch(':id/status')
  async updateStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: string,
  ) {
    return this.bookingsService.updateBookingStatus(id, status);
  }

  @Patch(':id/payment')
  async updatePayment(
    @Param('id', ParseIntPipe) id: number,
    @Body('paymentStatus') paymentStatus: string,
  ) {
    return this.bookingsService.updatePaymentStatus(id, paymentStatus);
  }
}
