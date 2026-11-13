-- CreateEnum
CREATE TYPE "SpvStatus" AS ENUM ('DRAFT', 'ACTIVE', 'BLOCKED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "CapitalEventType" AS ENUM ('INITIAL_ISSUANCE');

-- CreateEnum
CREATE TYPE "CapitalEventStatus" AS ENUM ('DRAFT', 'VALIDATED', 'APPROVED', 'EXECUTED', 'CANCELLED');

-- CreateTable
CREATE TABLE "property_spvs" (
    "id" UUID NOT NULL,
    "code" VARCHAR(32) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "jurisdiction" VARCHAR(2) NOT NULL DEFAULT 'ES',
    "legalForm" VARCHAR(16) NOT NULL DEFAULT 'SL',
    "status" "SpvStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "property_spvs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "capital_structures" (
    "id" UUID NOT NULL,
    "spvId" UUID NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'EUR',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "capital_structures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "capital_classes" (
    "id" UUID NOT NULL,
    "capitalStructureId" UUID NOT NULL,
    "code" VARCHAR(24) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "nominalValue" DECIMAL(20,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'EUR',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "capital_classes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "capital_events" (
    "id" UUID NOT NULL,
    "spvId" UUID NOT NULL,
    "capitalClassId" UUID NOT NULL,
    "eventType" "CapitalEventType" NOT NULL DEFAULT 'INITIAL_ISSUANCE',
    "legallyCreatedUnits" BIGINT NOT NULL,
    "status" "CapitalEventStatus" NOT NULL DEFAULT 'DRAFT',
    "effectiveDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "capital_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "property_spvs_code_key" ON "property_spvs"("code");

-- CreateIndex
CREATE UNIQUE INDEX "capital_structures_spvId_key" ON "capital_structures"("spvId");

-- CreateIndex
CREATE INDEX "capital_classes_capitalStructureId_idx" ON "capital_classes"("capitalStructureId");

-- CreateIndex
CREATE UNIQUE INDEX "capital_classes_capitalStructureId_code_key" ON "capital_classes"("capitalStructureId", "code");

-- CreateIndex
CREATE INDEX "capital_events_spvId_status_idx" ON "capital_events"("spvId", "status");

-- AddForeignKey
ALTER TABLE "capital_structures" ADD CONSTRAINT "capital_structures_spvId_fkey" FOREIGN KEY ("spvId") REFERENCES "property_spvs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_classes" ADD CONSTRAINT "capital_classes_capitalStructureId_fkey" FOREIGN KEY ("capitalStructureId") REFERENCES "capital_structures"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_events" ADD CONSTRAINT "capital_events_spvId_fkey" FOREIGN KEY ("spvId") REFERENCES "property_spvs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_events" ADD CONSTRAINT "capital_events_capitalClassId_fkey" FOREIGN KEY ("capitalClassId") REFERENCES "capital_classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
