import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Booking } from './entities/booking.entity';

@Injectable()
export class BookingsService {
  constructor(
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,
  ) {}

  async createBooking(createBookingDto: any): Promise<Booking> {
    const newBooking = this.bookingRepository.create(createBookingDto as DeepPartial<Booking>);
    return this.bookingRepository.save(newBooking);
  }


  async getBookingsByUser(userId: number): Promise<Booking[]> {
    return this.bookingRepository.find({ where: { userId } });
  }

  async getBookingsByVendor(vendorId: number): Promise<Booking[]> {
    return this.bookingRepository.find({ where: { vendorId } });
  }

  async updateBookingStatus(bookingId: number, status: string): Promise<Booking> {
    const booking = await this.bookingRepository.findOne({ where: { id: bookingId } });
    if (!booking) {
      throw new NotFoundException(`Booking verification failed for ID ${bookingId}`);
    }
    booking.status = status;
    return this.bookingRepository.save(booking);
  }

  async updatePaymentStatus(bookingId: number, paymentStatus: string): Promise<Booking> {
    const booking = await this.bookingRepository.findOne({ where: { id: bookingId } });
    if (!booking) {
      throw new NotFoundException(`Booking payment update failed for ID ${bookingId}`);
    }
    booking.paymentStatus = paymentStatus;
    return this.bookingRepository.save(booking);
  }
}
