---
id: RETP-DOMAIN
version: 0.1
status: DRAFT
date: 2026-11-13
---

# Visión del dominio RETP

## Problema

La emisión coordina hechos diferentes: económicos, societarios, de identidad/compliance, tecnológicos y de control. No deben colapsarse en una única entidad ni en un único estado.

Una suscripción, un pago, una asignación societaria, una actualización del registro de socios y un mint son hechos distintos.

## Bounded contexts

| Contexto | Responsabilidad |
|---|---|
| Investor Management | Inversores y wallets |
| Compliance Management | Elegibilidad, claims y restricciones |
| Capital Management | SPV, capital, eventos, suscripciones y asignaciones |
| Corporate Registry | Evidencia societaria y registro de socios |
| Token Management | Configuración, despliegue y emisión de tokens |
| Custody & Signing | Política de firma, autorizaciones y claves |
| Blockchain Adapter | RPC, envío, lectura y seguimiento EVM |
| Reconciliation | Comparación de posiciones |
| Financial Operations | Deuda y futuras distribuciones |

En v0.3 estos límites se implementarán principalmente como módulos de un monolito modular NestJS, no como microservicios independientes.

## Entidades principales

`PropertySPV`, `CapitalStructure`, `CapitalClass`, `CapitalEvent`, `Investor`, `Wallet`, `Subscription`, `Allocation`, `LegalEvidence`, `DebtFacility`, `TokenIssuance`, `TokenAllocation`, `TokenDeployment`, `OnchainIdentity`, `Claim`, `TokenTransaction`, `Reconciliation` y `AuditEvent`.

## Invariantes

1. Las asignaciones no superan las unidades autorizadas.
2. Una asignación requiere evidencia y aprobación conforme a la política societaria definida.
3. Antes de tokenizar, Corporate Registry debe registrar la formalización y actualización del Libro Registro de Socios.
4. Una TokenAllocation referencia una asignación societaria aprobada y registrada.
5. Solo inversores elegibles reciben tokens.
6. El total acuñado no supera las unidades societarias legalmente creadas y asignadas.
7. Los reintentos no duplican acuñaciones.
8. Los hechos blockchain confirmados se conservan en el historial.
9. La deuda no forma parte del cap table.
10. Las correcciones son auditables; no se borra el historial.
11. El saldo on-chain no sustituye el Libro Registro de Socios.

## Estados separados

Suscripción:
`DRAFT → SUBMITTED → COMPLIANCE_PENDING → COMPLIANCE_APPROVED → PAYMENT_PENDING → PAYMENT_CONFIRMED → CORPORATE_APPROVAL_PENDING → CORPORATE_APPROVED → ALLOCATION_PENDING → ALLOCATED → CORPORATE_REGISTER_UPDATE_PENDING → CORPORATE_REGISTER_UPDATED`.

Emisión:
`DRAFT → VALIDATED → APPROVED → DEPLOYMENT_PENDING → DEPLOYED → IDENTITY_SETUP_PENDING → IDENTITIES_READY → MINT_PENDING → MINT_SUBMITTED → MINT_CONFIRMED → RECONCILIATION_PENDING → RECONCILED`.

Son workflows relacionados, pero no una única máquina de estados.

## Consistencia

No existe atomicidad distribuida entre PostgreSQL y una red EVM. Persistir intención y autorización antes de enviar; registrar hash y nonce; tratar timeout como resultado indeterminado; consultar la red antes de reintentar; aplicar resultados idempotentemente y conciliar.
