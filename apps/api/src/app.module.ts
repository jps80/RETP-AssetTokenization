import { Module } from '@nestjs/common';
import { PrismaModule } from './infrastructure/prisma/prisma.module';
import { BigIntSerializationInterceptor } from './infrastructure/http/bigint-serialization.interceptor';
import { HealthModule } from './modules/health/health.module';
import { SpvsModule } from './modules/spvs/spvs.module';

@Module({
  imports: [PrismaModule, HealthModule, SpvsModule],
  providers: [BigIntSerializationInterceptor],
})
export class AppModule {}