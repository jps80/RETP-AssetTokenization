# RETP API — I-01

NestJS + Prisma implementation of the first executable Capital Management slice.

## Implemented

- PostgreSQL persistence through Prisma.
- `GET /api/health`.
- `POST /api/spvs`: atomically creates a Spanish SL laboratory SPV, its capital structure, one ordinary capital class and an initial capital event.
- `GET /api/spvs` and `GET /api/spvs/:id`.
- DTO validation and duplicate SPV-code handling.
- Unit tests for the creation transaction and positive nominal value.

## Domain boundaries

This endpoint records a **laboratory configuration**. It does not create or certify a real Spanish company, prove corporate formalities, register shareholders, accept subscriptions, or authorize token minting. `legallyCreatedUnits` is an input representing the units already created by the simulated corporate act; later iterations will replace direct operator input with explicit evidence and Corporate Registry workflows.

A Spanish SL's participations are not securities represented by this database or by ERC-3643. This API is an educational operational model only.

## Run locally

Requirements: Node.js 20+, npm, and the PostgreSQL service from the RETP infrastructure bootstrap.

1. Copy `.env.example` to `.env` and adjust the PostgreSQL credentials/host.
2. From this directory:

```bash
npm install
npm run prisma:generate
npm run prisma:migrate -- --name init_capital_core
npm run build
npm test
npm run start:dev
```

The API listens on port 3000 by default.

## Create the first SPV

```bash
curl -X POST http://localhost:3000/api/spvs \
  -H 'Content-Type: application/json' \
  -d '{
    "code": "RETP001",
    "name": "RETP Laboratory SPV",
    "jurisdiction": "ES",
    "legalForm": "SL",
    "capitalClassCode": "ORDINARY",
    "capitalClassName": "Participaciones ordinarias",
    "nominalValue": "50.00",
    "legallyCreatedUnits": "14000"
  }'
```

Then inspect it:

```bash
curl http://localhost:3000/api/spvs
curl http://localhost:3000/api/health
```

## Important implementation notes

- Money is Prisma Decimal, never JavaScript floating point.
- Participation units are PostgreSQL BIGINT / Prisma BigInt.
- The API serializes BigInt fields as strings in JSON; do not coerce them to JS Number.
- SPV, capital structure, class and initial capital event are committed in one database transaction.
- This slice deliberately does not yet expose subscription, allocation, Corporate Registry or blockchain endpoints.
