---
id: ADR-011
title: Selección de implementación ERC-3643 y estrategia de integración
status: Accepted-with-validation-gates
date: 2026-11-13
decision_owner: RETP Architecture
related: [RETP-SDD-0.3, ADR-003, ADR-007, ADR-008, ADR-009, ADR-010]
---

# ADR-011 — Selección de implementación ERC-3643 y estrategia de integración

## Contexto

RETP necesita una implementación real del estándar ERC-3643 para su flujo de emisión v0.3. No se desarrollará un token propio simplificado y se presentará como ERC-3643.

La implementación histórica `TokenySolutions/T-REX` está archivada. La organización ERC-3643 mantiene el repositorio `ERC-3643/ERC-3643`, que declara ser la suite oficial del estándar. El package manifest consultado declara `@erc3643org/erc-3643@4.1.3`.

## Decisión

1. Usar `ERC-3643/ERC-3643` como repositorio fuente candidato y evaluar `@erc3643org/erc-3643@4.1.3`.
2. Reproducir inicialmente la configuración Solidity 0.8.17 y optimizer 200 runs observada en el repositorio.
3. Desplegar la suite desde fuente en Anvil para el laboratorio.
4. Mantener los contratos de terceros aislados de los módulos de negocio RETP.
5. No copiar ni modificar código T-REX en RETP hasta completar la evaluación de licencia GPL-3.0.
6. No fijar el pin final de código hasta verificar tag/commit, tarball, hash y compilación reproducible.

## Alternativas consideradas

| Alternativa | Motivo de no selección |
|---|---|
| Repositorio histórico TokenySolutions/T-REX | Archivado; no es la línea activa de referencia |
| Implementación ERC-3643 propia | Riesgo de desviarse del estándar y duplicar lógica compleja |
| Factory oficial compartida | Despliegue restringido a wallets autorizadas; no es adecuado como dependencia inicial del laboratorio |
| Consumir solo ABI de terceros | Insuficiente para reproducir y probar el despliegue completo desde Anvil |

## Consecuencias

- El entorno de contratos tendrá toolchain propia y versionada.
- Los artefactos de compilación se vincularán al commit, lockfile y configuración del compilador.
- El backend RETP consumirá contratos a través de un Blockchain Adapter y ABI versionadas.
- La licencia de T-REX se tratará como una dependencia jurídica diferenciada de la licencia Apache-2.0 de RETP.
- La semántica de mint, transfer y funciones privilegiadas se probará sobre la versión exacta.

## Validaciones obligatorias antes de aprobar el pin final

- Correspondencia entre paquete npm 4.1.3 y commit de fuente.
- SHA-256 del tarball.
- Resolución exacta de dependencias.
- Compilación y tests originales.
- Despliegue Anvil y pruebas de roles.
- Revisión de licencia y estrategia de distribución.

## Estado

Decisión de candidato aceptada. La fijación inmutable de versión y la integración ejecutable quedan condicionadas a los gates anteriores.
