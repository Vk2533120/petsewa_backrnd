import { Controller, Get, Post, Patch, Delete, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('user/:userId')
  async getUserNotifications(
    @Param('userId', ParseIntPipe) userId: number,
    @Query('category') category?: string,
  ) {
    return this.notificationsService.getUserNotifications(userId, category);
  }

  @Get('user/:userId/unread-count')
  async getUnreadCount(@Param('userId', ParseIntPipe) userId: number) {
    return this.notificationsService.getUnreadCount(userId);
  }

  @Post('user/:userId/send')
  async sendNotification(
    @Param('userId', ParseIntPipe) userId: number,
    @Body('type') type: string,
    @Body('title') title: string,
    @Body('body') body: string,
    @Body('deepLink') deepLink?: string,
  ) {
    return this.notificationsService.sendNotification(userId, type || 'SYSTEM', title, body, deepLink);
  }

  @Patch(':id/read')
  async markAsRead(
    @Param('id', ParseIntPipe) id: number,
    @Body('userId', ParseIntPipe) userId: number,
  ) {
    return this.notificationsService.markAsRead(id, userId);
  }

  @Patch('user/:userId/read-all')
  async markAllAsRead(@Param('userId', ParseIntPipe) userId: number) {
    return this.notificationsService.markAllAsRead(userId);
  }

  @Delete(':id')
  async deleteNotification(
    @Param('id', ParseIntPipe) id: number,
    @Query('userId', ParseIntPipe) userId: number,
  ) {
    return this.notificationsService.deleteNotification(id, userId);
  }

  @Delete('user/:userId/clear-all')
  async clearAll(@Param('userId', ParseIntPipe) userId: number) {
    return this.notificationsService.clearAll(userId);
  }
}
