import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';

@Module({
  imports: [ConfigModule],
})
export class BaseController {

  constructor(private configService: ConfigService) {}

  protected getUserIdFromToken(authorization) {
    if (!authorization) return null;

    const token = authorization.split(' ')[1];
    const decoded: any = jwt.verify(token, this.configService.get<string>('secretKey'));
    return decoded.id;
  }
}