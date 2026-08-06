import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { VendorsModule } from './modules/vendors/vendors.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { AdoptionModule } from './modules/adoption/adoption.module';
import { LostFoundModule } from './modules/lostfound/lostfound.module';
import { NgoModule } from './modules/ngo/ngo.module';
import { SocialModule } from './modules/social/social.module';
import { RewardsModule } from './modules/rewards/rewards.module';
import { EmergencyModule } from './modules/emergency/emergency.module';
import { EcommerceModule } from './modules/ecommerce/ecommerce.module';
import { NotificationsModule } from './modules/notifications/notifications.module';

@Module({
  imports: [
    // Dynamic Config validation environment configuration
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    
    // Database layer with PostgreSQL relational driver mapping
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get<string>('DB_USERNAME', 'postgres'),
        password: configService.get<string>('DB_PASSWORD', 'postgres'),
        database: configService.get<string>('DB_DATABASE', 'petsewa_db'),
        autoLoadEntities: true,
        synchronize: true, // true only for development setup mapping
      }),
    }),
    
    // Feature Modules imports config mapping
    AuthModule,
    VendorsModule,
    BookingsModule,
    AdoptionModule,
    LostFoundModule,
    NgoModule,
    SocialModule,
    RewardsModule,
    EmergencyModule,
    EcommerceModule,
    NotificationsModule,
  ],

  controllers: [],
  providers: [],
})
export class AppModule {}


