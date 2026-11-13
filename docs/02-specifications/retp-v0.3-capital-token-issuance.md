---
id: RETP-SDD-0.3
version: 0.3
status: DRAFT
date: 2026-11-13
---

# RETP — SDD v0.3: Capital Management & Token Issuance

## Objetivo

v0.3 será la primera versión funcional vertical que conecte configuración de SPV y capital con despliegue ERC-3643, preparación de identidades, mint autorizado y conciliación inicial. La emisión blockchain forma parte del alcance de v0.3.

## Alcance

- Alta de SPV y clase ordinaria.
- Inversores y wallets sintéticos.
- Eventos de capital, suscripciones y asignaciones.
- Evidencia y aprobación societaria simuladas.
- Elegibilidad mediante claims sintéticos.
- Despliegue de T-REX/ERC-3643 en Anvil.
- ONCHAINID y claims de laboratorio.
- Mint gobernado por workflow y firma.
- Seguimiento de transacciones y conciliación inicial.

Fuera de alcance: mercado secundario, KYC real, custodia productiva, despliegue productivo, automatización jurídica vinculante y contabilidad completa.

## Decisiones

| ADR | Decisión |
|---|---|
| 001 | Monolito modular NestJS |
| 002 | PostgreSQL + Prisma como persistencia operacional |
| 003 | ERC-3643 como estándar objetivo |
| 004 | Suite T-REX de referencia; versión exacta por fijar |
| 005 | `decimals = 0` |
| 006 | Token como espejo técnico auxiliar |
| 007 | Mint solo mediante workflow autorizado |
| 008 | Servicio de firma aislado |
| 009 | Transactional Outbox + RabbitMQ |
| 010 | Anvil primero, Sepolia después |

## Arquitectura lógica

Módulos: Investor Management, Compliance Management, Capital Management, Corporate Registry, Token Management, Identity Management, Blockchain Adapter, Custody/Signing, Reconciliation y Audit.

El backend de negocio no accede directamente a claves privadas. El servicio aislado aplica policy engine, maker-checker y autorización explícita. SoftHSM2 es herramienta de laboratorio, no HSM certificado ni custodia productiva.

## Componentes ERC-3643

La implementación partirá de la suite T-REX compatible con ERC-3643. Se fijarán tag/commit, compilador Solidity, dependencias, licencia y despliegue antes de programar. Se verificarán Token, Identity Registry, Trusted Issuers Registry, Claim Topics Registry, Compliance, ONCHAINID y factory/deployer según la versión concreta.

Los topics KYC/AML usados en pruebas serán convenciones internas del laboratorio, no códigos regulatorios universales. No se almacenarán documentos ni datos personales en blockchain.

## Workflow de emisión

1. Crear SPV y estructura de capital.
2. Crear evento de capital y registrar suscripciones.
3. Validar unidades, importes y límites.
4. Registrar pago de laboratorio.
5. Registrar aprobación societaria simulada y evidencia.
6. Aprobar asignaciones.
7. Validar identidad y elegibilidad.
8. Desplegar/configurar T-REX.
9. Vincular ONCHAINID y wallet.
10. Emitir claims sintéticos desde Trusted Issuer.
11. Preparar mint y someterlo a política.
12. Obtener maker-checker.
13. Firmar y enviar transacción.
14. Confirmar y registrar receipt/eventos.
15. Conciliar asignaciones y saldos.
16. Cerrar técnicamente solo si se cumplen los criterios.

## Reglas

- Una suscripción pagada no crea automáticamente una participación.
- Una asignación sin evidencia/aprobación no inicia mint.
- Una TokenAllocation debe referenciar Allocation aprobada.
- Solo identidades elegibles reciben tokens.
- El total acuñado no supera el autorizado.
- La idempotency key impide mint duplicado.
- Timeout exige consulta de red antes de reintento.
- La deuda no forma parte del cap table.
- El token no determina titularidad jurídica.

## Requisitos funcionales

FR-001 crear SPV; FR-002 configurar clase; FR-003 registrar inversores/wallets; FR-004 crear evento y suscripciones; FR-005 validar importes y unidades; FR-006 registrar evidencia/aprobación; FR-007 aprobar asignaciones; FR-008 desplegar token; FR-009 vincular ONCHAINID; FR-010 emitir claims; FR-011 preparar/aprobar mint; FR-012 firmar y enviar; FR-013 consultar transacciones; FR-014 conciliar; FR-015 consultar auditoría.

## Criterios de aceptación

- AC-001 creación de SPV con una clase ordinaria.
- AC-002 rechazo de asignaciones superiores al límite autorizado.
- AC-003 bloqueo de mint sin evidencia/aprobación.
- AC-004 rechazo de inversor no elegible.
- AC-005 registro de chain ID y direcciones desplegadas.
- AC-006 asociación de mint con Allocation e idempotency key.
- AC-007 reintento sin segunda acuñación.
- AC-008 timeout no se trata como fallo definitivo.
- AC-009 persistencia de hash, receipt, bloque y estado.
- AC-010 conciliación detecta diferencias.
- AC-011 deuda no altera cap table.
- AC-012 UI separa estado societario y estado técnico.

## Persistencia y API

Entidades candidatas: PropertySPV, CapitalStructure, CapitalClass, CapitalEvent, Investor, Wallet, Subscription, Allocation, LegalEvidence, DebtFacility, TokenIssuance, TokenAllocation, TokenDeployment, TokenContract, OnchainIdentity, Claim, TokenTransaction, Reconciliation y AuditEvent.

Endpoints orientativos: `POST /spvs`, `GET /spvs/:id`, `POST /spvs/:id/capital-classes`, `POST /spvs/:id/capital-events`, `POST /subscriptions`, `POST /subscriptions/:id/submit`, `POST /subscriptions/:id/payment-confirmation`, `POST /subscriptions/:id/approve-allocation`, `GET /spvs/:id/capitalization-table`, `POST /spvs/:id/token-deployments`, `POST /token-issuances`, `POST /token-issuances/:id/validate`, `POST /token-issuances/:id/approve`, `POST /token-issuances/:id/execute`, `GET /token-issuances/:id` y `POST /token-issuances/:id/reconcile`.

Son propuestas, no APIs implementadas.

## Riesgos y verificaciones

- Compatibilidad T-REX/toolchain y licencias.
- Roles administrativos y claves.
- SoftHSM2/PKCS#11 con secp256k1.
- Reorgs y confirmaciones.
- Trusted Issuer, revocación y expiración de claims.
- Consistencia entre estados societarios y técnicos.
- Perímetro jurídico/regulatorio de un caso real.

## Estado

Esta especificación describe diseño. No declara implementados módulos, contratos, APIs, migraciones o pruebas. El estado cambiará únicamente con evidencia verificable de código y tests.
