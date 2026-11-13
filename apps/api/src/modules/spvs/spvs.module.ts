import { Module } from '@nestjs/common';
import { SpvsController } from './spvs.controller';
import { SpvsService } from './spvs.service';

@Module({ controllers: [SpvsController], providers: [SpvsService] })
export class SpvsModule {}