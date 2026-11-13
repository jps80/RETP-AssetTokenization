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
| 003 | Historial de movimientos para posiciones de capital |
| 004 | Separación Capital Management / Token Management |
| 005 | RabbitMQ + Transactional Outbox |
| 006 | DebtFacility separado del cap table |
| 007 | ERC-3643 como estándar objetivo |
| 008 | Token como espejo técnico auxiliar |
| 009 | Firma aislada, policy engine y maker-checker |
| 010 | Anvil primero, Sepolia después |
| 011 | Suite oficial ERC-3643/ERC-3643; candidato 4.1.3, sujeto a gates técnicos y de licencia |

## Arquitectura lógica

Módulos: Investor Management, Compliance Management, Capital Management, Corporate Registry, Token Management, Identity Management, Blockchain Adapter, Custody/Signing, Reconciliation y Audit.

El backend de negocio no accede directamente a claves privadas. El servicio aislado aplica policy engine, maker-checker y autorización explícita. SoftHSM2 es herramienta de laboratorio, no HSM certificado ni custodia productiva.

## Componentes ERC-3643

La implementación candidata es la suite del repositorio oficial `ERC-3643/ERC-3643`, paquete `@erc3643org/erc-3643@4.1.3`. El repositorio histórico `TokenySolutions/T-REX` está archivado. La configuración observada declara Solidity 0.8.17 y optimizer 200 runs. La compilación, tests, pin de commit y lockfile aún están pendientes.

Se verificarán Token, Identity Registry, Identity Registry Storage, Trusted Issuers Registry, Claim Topics Registry, Compliance y ONCHAINID, junto con los mecanismos concretos de despliegue y roles de la versión fijada.

Los topics KYC/AML usados en pruebas serán convenciones internas del laboratorio, no códigos regulatorios universales. No se almacenarán documentos ni datos personales en blockchain.

La suite consultada declara GPL-3.0, frente a Apache-2.0 en RETP. No se copiará código ni se decidirá una forma de distribución hasta completar la revisión de licencias.

## Semántica de operaciones: verificación por versión

En el `Token.sol` consultado de la suite actual, `mint` exige rol Agent, verifica al destinatario con Identity Registry y llama a `Compliance.canTransfer(address(0), to, amount)` antes de acuñar y notificar `created`. La transferencia ordinaria también verifica identidad y Compliance. La función privilegiada `forcedTransfer` tiene una semántica diferente.

La documentación general histórica de EIP-3643 no describe exactamente la misma ruta para mint. Por tanto, el comportamiento deberá probarse sobre el commit fijado, sin extrapolar de documentación de otra versión.

En cualquier caso, las reglas societarias, la asignación autorizada, el control maker-checker y la idempotencia se validan en RETP antes de solicitar la firma. Los checks on-chain son una capa adicional, no sustituyen el workflow de negocio.

## Workflow de emisión

1. Crear SPV y estructura de capital.
2. Crear evento de capital y registrar suscripciones.
3. Validar unidades, importes y límites.
4. Registrar pago de laboratorio.
5. Registrar aprobación societaria simulada y evidencia.
6. Completar las formalidades societarias simuladas y registrar la actualización del Libro Registro de Socios en Corporate Registry.
7. Aprobar/cerrar las asignaciones que reflejan el registro actualizado.
8. Validar identidad y elegibilidad.
9. Desplegar/configurar T-REX.
10. Vincular ONCHAINID y wallet.
11. Emitir claims sintéticos desde Trusted Issuer.
12. Preparar mint y someterlo a policy.
13. Obtener maker-checker.
14. Firmar y enviar transacción.
15. Confirmar y registrar receipt/eventos.
16. Conciliar asignaciones y saldos.
17. Cerrar técnicamente solo si se cumplen los criterios.

## Reglas

- Una suscripción pagada no crea automáticamente una participación.
- Una asignación sin evidencia/aprobación y sin constancia de actualización del Libro Registro de Socios no inicia mint.
- Una TokenAllocation debe referenciar Allocation aprobada y actualizada en Corporate Registry.
- Solo identidades elegibles reciben tokens.
- El total acuñado no supera las participaciones legalmente creadas y registradas.
- La idempotency key impide mint duplicado.
- Timeout exige consulta de red antes de reintento.
- La deuda no forma parte del cap table.
- El token no determina titularidad jurídica.
- La llamada de mint debe superar la comprobación de identidad y Compliance de la implementación fijada.
- Las funciones privilegiadas de agente no se expondrán como operaciones ordinarias de usuario.

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
- AC-013 mint rechazado cuando el módulo de Compliance bloquea `canTransfer(address(0), to, amount)`.
- AC-014 mint rechazado cuando el actor no es Agent.
- AC-015 forced transfer no está disponible en la API ordinaria de v0.3.
- AC-016 mint bloqueado si Corporate Registry no acredita la actualización del Libro Registro de Socios.

## Persistencia y API

Entidades candidatas: PropertySPV, CapitalStructure, CapitalClass, CapitalEvent, Investor, Wallet, Subscription, Allocation, LegalEvidence, CorporateRegisterUpdate, DebtFacility, TokenIssuance, TokenAllocation, TokenDeployment, TokenContract, OnchainIdentity, Claim, BlockchainTransaction, Reconciliation y AuditEvent.

Endpoints orientativos: `POST /spvs`, `GET /spvs/:id`, `POST /spvs/:id/capital-classes`, `POST /spvs/:id/capital-events`, `POST /subscriptions`, `POST /subscriptions/:id/submit`, `POST /subscriptions/:id/payment-confirmation`, `POST /subscriptions/:id/approve-allocation`, `GET /spvs/:id/capitalization-table`, `POST /spvs/:id/token-deployments`, `POST /token-issuances`, `POST /token-issuances/:id/validate`, `POST /token-issuances/:id/approve`, `POST /token-issuances/:id/execute`, `GET /token-issuances/:id` y `POST /token-issuances/:id/reconcile`.

Son propuestas, no APIs implementadas.

## Riesgos y verificaciones

- Correspondencia paquete 4.1.3 / commit de fuente.
- Compilación reproducible, lockfile y tests.
- Licencia GPL-3.0 y forma de distribución.
- Roles administrativos y claves.
- SoftHSM2/PKCS#11 con secp256k1.
- Reorgs y confirmaciones.
- Trusted Issuer, revocación y expiración de claims.
- Consistencia entre estados societarios y técnicos.
- Perímetro jurídico/regulatorio de un caso real.

## Estado

Esta especificación describe diseño. No declara implementados módulos, contratos, APIs, migraciones o pruebas. El estado cambiará únicamente con evidencia verificable de código y tests.
