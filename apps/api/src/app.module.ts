import { Module } from '@nestjs/common';
import { PrismaModule } from './infrastructure/prisma/prisma.module';
import { HealthModule } from './modules/health/health.module';
import { SpvsModule } from './modules/spvs/spvs.module';

@Module({
  imports: [PrismaModule, HealthModule, SpvsModule],
})
export class AppModule {}