import { ConflictException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { SpvsService } from './spvs.service';

describe('SpvsService', () => {
  const tx = {
    propertySPV: { create: jest.fn() },
    capitalEvent: { create: jest.fn() },
  };
  const prisma = { $transaction: jest.fn() };
  let service: SpvsService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SpvsService(prisma as never);
  });

  it('creates SPV, single ordinary class and initial capital event atomically', async () => {
    const spv = {
      id: 'spv-id',
      capitalStructure: { classes: [{ id: 'class-id' }] },
    };
    tx.propertySPV.create.mockResolvedValue(spv);
    tx.capitalEvent.create.mockResolvedValue({ id: 'event-id' });
    prisma.$transaction.mockImplementation((callback: (client: typeof tx) => unknown) => callback(tx));

    const result = await service.create({
      code: 'RETP001',
      name: 'RETP Laboratory SPV',
      jurisdiction: 'ES',
      legalForm: 'SL',
      capitalClassCode: 'ORDINARY',
      capitalClassName: 'Participaciones ordinarias',
      nominalValue: '50.00',
      legallyCreatedUnits: '14000',
    });

    expect(tx.propertySPV.create).toHaveBeenCalledTimes(1);
    expect(tx.capitalEvent.create).toHaveBeenCalledWith(expect.objectContaining({
      data: expect.objectContaining({ spvId: 'spv-id', capitalClassId: 'class-id', legallyCreatedUnits: 14000n }),
    }));
    expect(result.capitalEvents).toHaveLength(1);
  });

  it('rejects zero nominal value before persistence', async () => {
    await expect(service.create({
      code: 'RETP001', name: 'Test', jurisdiction: 'ES', legalForm: 'SL',
      capitalClassCode: 'ORDINARY', capitalClassName: 'Ordinary',
      nominalValue: '0', legallyCreatedUnits: '100',
    })).rejects.toBeInstanceOf(ConflictException);
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });
});