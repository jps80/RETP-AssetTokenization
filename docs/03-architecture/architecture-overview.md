---
id: RETP-ARCH
version: 0.1
status: DRAFT
date: 2026-11-13
---

# Arquitectura de solución

## Vista lógica

React + TypeScript consume una API NestJS modular. El backend integra PostgreSQL/Prisma, Outbox/RabbitMQ, Blockchain Adapter y un servicio de firma aislado.

El servicio de firma incorpora policy engine, maker-checker y SoftHSM2/PKCS#11 para el laboratorio. El Blockchain Adapter interactúa con Anvil y posteriormente Sepolia.

## Fuentes de verdad

| Información | Autoridad |
|---|---|
| Estado operacional de SPV y workflows | PostgreSQL |
| Titularidad jurídica | Documentación y registros societarios aplicables |
| Ejecución técnica de token | Red EVM |
| Transporte asíncrono | RabbitMQ |
| Resultado comparativo | Reconciliation |

RabbitMQ no es base de datos. Blockchain no sustituye registros societarios.

## Estilo

Monolito modular NestJS con límites explícitos. Procesos auxiliares separados cuando la frontera de seguridad lo exige, especialmente firma. No se crearán microservicios prematuramente.

## Integración y resiliencia

Transactional Outbox, consumidores idempotentes, DLQ, eventos versionados y correlation IDs. No hay atomicidad distribuida PostgreSQL/EVM: persistir intención, autorizar, firmar, enviar, registrar hash, confirmar, aplicar resultado y conciliar. Un timeout requiere consultar la red antes de reintentar.

## Seguridad

El backend no accede a claves privadas. La solicitud de firma debe validar política, rol, chain ID, destino, método, parámetros y aprobaciones. SoftHSM2 no equivale a HSM certificado; la compatibilidad de PKCS#11 y secp256k1 debe probarse.

## Despliegue

Docker Compose inicialmente; k3d/Kubernetes local como evolución. PostgreSQL, RabbitMQ, Anvil y SoftHSM2 en componentes/perfiles separados. Secretos fuera del repositorio.
