import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Notification } from './entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
  ) {}

  async getUserNotifications(userId: number, category?: string): Promise<Notification[]> {
    const where: any = { userId };
    if (category && category.trim().toUpperCase() !== 'ALL') {
      where.type = category.trim().toUpperCase();
    }
    return this.notificationRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async getUnreadCount(userId: number): Promise<{ unreadCount: number }> {
    const count = await this.notificationRepository.count({
      where: { userId, isRead: false },
    });
    return { unreadCount: count };
  }

  async sendNotification(
    userId: number,
    type: string,
    title: string,
    body: string,
    deepLink?: string,
  ): Promise<Notification> {
    const notifData = {
      userId,
      type: type.toUpperCase(),
      title,
      body,
      isRead: false,
      deepLink,
    };
    const notif = this.notificationRepository.create(notifData as DeepPartial<Notification>);
    return this.notificationRepository.save(notif);
  }

  async markAsRead(id: number, userId: number): Promise<Notification> {
    const notif = await this.notificationRepository.findOne({ where: { id, userId } });
    if (!notif) {
      throw new NotFoundException(`Notification #${id} not found.`);
    }
    notif.isRead = true;
    return this.notificationRepository.save(notif);
  }

  async markAllAsRead(userId: number): Promise<{ success: boolean; message: string }> {
    await this.notificationRepository.update({ userId, isRead: false }, { isRead: true });
    return { success: true, message: 'All notifications marked as read.' };
  }

  async deleteNotification(id: number, userId: number): Promise<{ success: boolean; message: string }> {
    const notif = await this.notificationRepository.findOne({ where: { id, userId } });
    if (!notif) {
      throw new NotFoundException(`Notification #${id} not found.`);
    }
    await this.notificationRepository.remove(notif);
    return { success: true, message: 'Notification deleted successfully.' };
  }

  async clearAll(userId: number): Promise<{ success: boolean; message: string }> {
    await this.notificationRepository.delete({ userId });
    return { success: true, message: 'All notifications cleared.' };
  }
}
