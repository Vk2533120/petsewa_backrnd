import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Post } from './entities/post.entity';

@Injectable()
export class SocialService {
  constructor(
    @InjectRepository(Post)
    private readonly postRepository: Repository<Post>,
  ) {}

  async createPost(dto: any): Promise<Post> {
    const post = this.postRepository.create(dto as DeepPartial<Post>);
    return this.postRepository.save(post);
  }


  async findReels(): Promise<Post[]> {
    return this.postRepository.find({ where: { type: 'reel' }, order: { createdAt: 'DESC' } });
  }

  async findFeed(): Promise<Post[]> {
    return this.postRepository.find({ order: { createdAt: 'DESC' } });
  }

  async likePost(id: number): Promise<Post> {
    const post = await this.postRepository.findOne({ where: { id } });
    if (post) {
      post.likesCount += 1;
      return this.postRepository.save(post);
    }
    return null;
  }

  async commentPost(id: number): Promise<Post> {
    const post = await this.postRepository.findOne({ where: { id } });
    if (post) {
      post.commentsCount += 1;
      return this.postRepository.save(post);
    }
    return null;
  }
}
