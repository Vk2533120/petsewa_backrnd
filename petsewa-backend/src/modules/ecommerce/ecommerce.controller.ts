import { Controller, Get, Post, Body, Param, ParseIntPipe } from '@nestjs/common';
import { EcommerceService } from './ecommerce.service';

@Controller('ecommerce')
export class EcommerceController {
  constructor(private readonly ecommerceService: EcommerceService) {}

  @Post('products')
  async addProduct(@Body() dto: any) {
    return this.ecommerceService.addProduct(dto);
  }

  @Get('products')
  async getProducts() {
    return this.ecommerceService.getProducts();
  }

  @Post('checkout')
  async checkout(
    @Body('productId', ParseIntPipe) productId: number,
    @Body('quantity', ParseIntPipe) quantity: number,
  ) {
    return this.ecommerceService.processCheckout(productId, quantity);
  }
}
