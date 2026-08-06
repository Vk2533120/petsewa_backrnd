import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DeepPartial } from 'typeorm';
import { Product } from './entities/product.entity';

@Injectable()
export class EcommerceService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async addProduct(dto: any): Promise<Product> {
    const product = this.productRepository.create(dto as DeepPartial<Product>);
    return this.productRepository.save(product);
  }


  async getProducts(): Promise<Product[]> {
    return this.productRepository.find({ where: { isActive: true } });
  }

  async processCheckout(productId: number, quantity: number): Promise<any> {
    const product = await this.productRepository.findOne({ where: { id: productId } });
    if (!product) {
      throw new NotFoundException(`Product with ID ${productId} not found.`);
    }

    if (product.stock < quantity) {
      throw new BadRequestException(`Insufficient stock. Only ${product.stock} items left.`);
    }

    product.stock -= quantity;
    await this.productRepository.save(product);

    return {
      success: true,
      message: 'Checkout processed successfully.',
      totalAmount: Number(product.price) * quantity,
      remainingStock: product.stock,
    };
  }
}
