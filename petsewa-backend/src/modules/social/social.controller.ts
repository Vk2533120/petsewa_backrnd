import { Controller, Get, Post, Body, Param, Patch, ParseIntPipe } from '@nestjs/common';
import { SocialService } from './social.service';

@Controller('social')
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Post('posts')
  async createPost(@Body() dto: any) {
    return this.socialService.createPost(dto);
  }

  @Get('feed')
  async getFeed() {
    return this.socialService.findFeed();
  }

  @Get('reels')
  async getReels() {
    return this.socialService.findReels();
  }

  @Patch('posts/:id/like')
  async like(@Param('id', ParseIntPipe) id: number) {
    return this.socialService.likePost(id);
  }

  @Patch('posts/:id/comment')
  async comment(@Param('id', ParseIntPipe) id: number) {
    return this.socialService.commentPost(id);
  }
}
