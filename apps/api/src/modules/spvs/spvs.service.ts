import { ConflictException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../infrastructure/prisma/prisma.service';
import { CreateSpvDto } from './dto/create-spv.dto';

@Injectable()
export class SpvsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateSpvDto) {
    const nominalValue = new Prisma.Decimal(dto.nominalValue);
    const units = BigInt(dto.legallyCreatedUnits);

    if (!nominalValue.isFinite() || nominalValue.lte(0)) {
      throw new ConflictException('nominalValue must be greater than zero');
    }
    if (units <= 0n) {
      throw new ConflictException('legallyCreatedUnits must be greater than zero');
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const spv = await tx.propertySPV.create({
          data: {
            code: dto.code,
            name: dto.name,
            jurisdiction: dto.jurisdiction,
            legalForm: dto.legalForm,
            capitalStructure: {
              create: {
                currency: 'EUR',
                classes: {
                  create: {
                    code: dto.capitalClassCode,
                    name: dto.capitalClassName,
                    nominalValue,
                    currency: 'EUR',
                  },
                },
              },
            },
          },
          include: {
            capitalStructure: { include: { classes: true } },
          },
        });

        const capitalClass = spv.capitalStructure!.classes[0];
        const capitalEvent = await tx.capitalEvent.create({
          data: {
            spvId: spv.id,
            capitalClassId: capitalClass.id,
            eventType: 'INITIAL_ISSUANCE',
            legallyCreatedUnits: units,
            effectiveDate: dto.effectiveDate ? new Date(dto.effectiveDate) : undefined,
          },
        });

        return { ...spv, capitalEvents: [capitalEvent] };
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw new ConflictException('An SPV with this code already exists');
      }
      throw error;
    }
  }

  findOne(id: string) {
    return this.prisma.propertySPV.findUnique({
      where: { id },
      include: {
        capitalStructure: { include: { classes: true } },
        capitalEvents: true,
      },
    });
  }

  findAll() {
    return this.prisma.propertySPV.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        capitalStructure: { include: { classes: true } },
        capitalEvents: true,
      },
    });
  }
}