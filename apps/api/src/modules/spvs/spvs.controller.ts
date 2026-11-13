import { Body, Controller, Get, NotFoundException, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import { CreateSpvDto } from './dto/create-spv.dto';
import { SpvsService } from './spvs.service';

@Controller('spvs')
export class SpvsController {
  constructor(private readonly service: SpvsService) {}

  @Post()
  create(@Body() dto: CreateSpvDto) {
    return this.service.create(dto);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':id')
  async findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    const spv = await this.service.findOne(id);
    if (!spv) throw new NotFoundException('SPV not found');
    return spv;
  }
}