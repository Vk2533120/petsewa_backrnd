import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  async validateUser(email: string, pass: string): Promise<any> {
    // TODO: Hash verify logic here
    if (email === 'admin@petsewa.com' && pass === 'password') {
      const { password, ...result } = { id: 1, email, name: 'Admin User', role: 'admin', password: 'password' };
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
    };
  }
}
