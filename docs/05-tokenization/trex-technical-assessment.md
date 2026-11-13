---
id: RETP-TECH-TREX-001
version: 0.1
status: REVIEWED
date: 2026-11-13
scope: Technical due diligence; not a compilation or security audit
---

# Evaluación técnica de T-REX / ERC-3643 para RETP

## 1. Objetivo y conclusión ejecutiva

Este documento registra la revisión preliminar de la implementación de referencia de ERC-3643 que utilizaremos para la primera emisión de RETP.

**Conclusión:** el candidato de evaluación será el repositorio oficial de la organización ERC-3643, `ERC-3643/ERC-3643`, paquete npm `@erc3643org/erc-3643` versión `4.1.3`. No se adopta el antiguo repositorio `TokenySolutions/T-REX`, que aparece archivado y remite al repositorio actual.

La versión 4.1.3 es una **versión candidata identificada**, no una dependencia aprobada para producción ni una versión ya compilada en nuestro entorno. Antes de fijarla como baseline ejecutable debemos:
- identificar el commit/tag exacto asociado al paquete;
- verificar el contenido del tarball y su correspondencia con el repositorio;
- resolver y congelar dependencias;
- compilar con la toolchain del proyecto;
- ejecutar la suite de tests original;
- desplegar en Anvil y verificar configuración, roles y bytecode.

## 2. Fuentes revisadas

| Fuente | Observación |
|---|---|
| [Repositorio oficial ERC-3643/ERC-3643](https://github.com/ERC-3643/ERC-3643) | Repositorio público actual; declara ser la suite oficial ERC-3643 |
| [Repositorio histórico TokenySolutions/T-REX](https://github.com/TokenySolutions/T-REX) | Archivado; remite al repositorio de ERC-3643 |
| [package.json del repositorio](https://raw.githubusercontent.com/ERC-3643/ERC-3643/main/package.json) | Declara paquete `@erc3643org/erc-3643`, versión 4.1.3 |
| [hardhat.config.ts](https://raw.githubusercontent.com/ERC-3643/ERC-3643/main/hardhat.config.ts) | Solidity 0.8.17; optimizador activado con 200 runs |
| [Token.sol](https://github.com/ERC-3643/ERC-3643/blob/main/contracts/token/Token.sol) | Implementación concreta de mint, transfer y roles |
| [EIP-3643](https://eips.ethereum.org/EIPS/eip-3643) | Interfaces y comportamiento definido por la especificación |
| [Licencia GPL-3.0](https://github.com/ERC-3643/ERC-3643/blob/main/LICENSE.md) | Licencia declarada en el repositorio |

Las observaciones de repositorio y package metadata son una fotografía de las fuentes consultadas el 13-11-2026. Los datos de rama `main` pueden cambiar; por ello no sustituyen a un commit inmutable.

## 3. Estado del repositorio y procedencia

El repositorio antiguo `TokenySolutions/T-REX` está archivado. La organización ERC-3643 mantiene una suite que se presenta como implementación oficial del estándar y que declara ser fork de la implementación histórica.

No debemos:
- iniciar una integración nueva contra el repositorio archivado;
- asumir que la rama `main` es reproducible por sí sola;
- usar un rango semver abierto como mecanismo de fijación;
- mezclar artefactos ABI de distintas versiones.

**Acción pendiente:** obtener el commit exacto, tag (si existe) y tarball npm de 4.1.3; calcular SHA-256 de los artefactos descargados y guardar el lockfile de dependencias. La versión de paquete no se considerará por sí sola un pin suficiente del código fuente.

## 4. Toolchain observada

| Elemento | Valor observado | Consecuencia |
|---|---|---|
| Paquete | `@erc3643org/erc-3643` | Candidato para integrar artefactos/contratos |
| Versión | `4.1.3` | Versión candidata |
| Framework | Hardhat | Mantener entorno EVM de desarrollo |
| Solidity | `0.8.17` | Compilador inicial a reproducir |
| Optimizer | enabled | Configuración de bytecode debe conservarse |
| Optimizer runs | 200 | Registrar en build metadata |
| OpenZeppelin Contracts | `^4.8.3` | Resolver versión exacta desde lockfile |
| OpenZeppelin Upgradeable | `^4.8.3` | Resolver versión exacta |
| ONCHAINID Solidity | `^2.0.0` | Verificar interfaces y versión resuelta |
| Hardhat | `^2.14.0` | Versión efectiva pendiente de lockfile |
| Hardhat Toolbox | `^2.0.2` | Versión efectiva pendiente de lockfile |

Los rangos `^` del package manifest no constituyen versiones reproducibles. La versión realmente usada será la resuelta por el lockfile correspondiente al paquete/tag fijado.

## 5. Licencia y separación de componentes

El repositorio de RETP declara Apache-2.0. La suite ERC-3643 declara GPL-3.0. El repositorio histórico también indica GPL-3.0.

No se copiará código fuente de T-REX dentro del repositorio RETP hasta documentar:
- qué archivos se incorporan y bajo qué licencia;
- si se usa el paquete publicado, un submódulo Git o una dependencia externa;
- obligaciones de conservación de avisos, entrega de código fuente y distribución;
- compatibilidad de la combinación con el modelo de distribución previsto.

La licencia del proyecto RETP no relicencia automáticamente los componentes de terceros. Esta nota no es una opinión jurídica sobre compatibilidad de licencias; es un bloqueo de gobernanza para cualquier redistribución.

## 6. Arquitectura contractual que debe verificarse

La especificación ERC-3643 define, entre otras, estas interfaces:
- Token;
- Identity Registry;
- Identity Registry Storage;
- Compliance;
- Trusted Issuers Registry;
- Claim Topics Registry.

ONCHAINID proporciona el mecanismo de identidad y claims. La verificación de elegibilidad relaciona wallet, identidad, topics requeridos y emisores de confianza.

En RETP mantendremos separadas tres decisiones:
1. **Elegibilidad para mantener el token:** Identity Registry y claims.
2. **Admisibilidad de una operación en el contrato:** reglas de Compliance configuradas para ese token.
3. **Autorización societaria y operacional para emitir:** reglas de Capital Management, Corporate Registry, workflow, policy engine y maker-checker de RETP.

La tercera capa no se sustituye por las dos primeras.

## 7. Semántica observada de las operaciones

La especificación EIP y la implementación deben leerse conjuntamente, pero no confundirse.

### 7.1 Transfer ordinaria

En la implementación consultada, `transfer` y `transferFrom`:
- comprueban restricciones de congelación y saldo disponible;
- consultan `IdentityRegistry.isVerified(to)`;
- consultan `Compliance.canTransfer(from, to, amount)`;
- actualizan el estado de compliance tras transferir.

### 7.2 Mint

En el código `Token.sol` consultado, `mint(to, amount)`:
- está restringido a un agente;
- exige que el destinatario esté verificado;
- consulta `Compliance.canTransfer(address(0), to, amount)`;
- acuña;
- notifica a Compliance mediante `created(to, amount)`.

Esto difiere de la descripción general histórica de EIP-3643 que presenta el mint como bypass de las reglas de compliance ordinarias. RETP debe probar la semántica de la versión exacta que se integre, no codificar una suposición basada únicamente en una descripción genérica.

### 7.3 Forced transfer

La implementación consultada aplica control de agente y verificación del destinatario, pero no sigue exactamente el mismo precheck `canTransfer` de la transferencia ordinaria. Por su capacidad de intervención privilegiada, RETP no expondrá forced transfer como operación ordinaria de usuario. Quedará fuera del alcance funcional de v0.3 salvo pruebas técnicas controladas.

### 7.4 Consecuencia de diseño

Antes de cada mint, RETP verificará en su backend:
- asignación societaria aprobada y evidencia asociada;
- cantidad pendiente de acuñar;
- wallet e identidad vinculadas;
- identidad verificada on-chain;
- emisión y deployment correctos;
- límites y policy aplicables;
- maker-checker y autorización de firma;
- idempotency key y ausencia de ejecución previa.

La comprobación on-chain de Identity/Compliance añade una segunda barrera; no constituye la autorización corporativa de la emisión.

## 8. Estrategia de despliegue para RETP

Para el laboratorio utilizaremos **despliegue local de la suite desde fuente en Anvil**, no dependeremos de las factories oficiales públicas.

La documentación de las factories oficiales indica que el despliegue está restringido a wallets autorizadas de miembros de la asociación. Por ello no asumiremos que una wallet local de Anvil o una wallet de Sepolia puede utilizarlas sin autorización.

El despliegue local nos permite:
- aprender el orden de despliegue y las relaciones entre contratos;
- inspeccionar direcciones y roles;
- reproducir tests;
- reiniciar la red y repetir escenarios;
- no depender de una factory con permisos de acceso externos.

Sepolia será una fase posterior de integración, no el primer entorno de compilación.

## 9. Riesgos y controles

| Riesgo | Control |
|---|---|
| Código cambia en main | Fijar commit y hash de artefactos |
| Diferencia entre package y Git source | Comparar tarball, commit y contenido |
| Dependencias transitivas cambian | Lockfile reproducible y CI |
| Incompatibilidad de Solidity | Compilación aislada antes de integrar |
| Licencia GPL-3.0 | Revisión jurídica de distribución y estrategia de dependencia |
| Roles mal configurados | Tests de permisos negativos |
| Mint no refleja autorización societaria | Policy y evidencia en RETP antes de firmar |
| Diferencias EIP/implementación | Tests de comportamiento sobre versión fijada |
| Factory oficial no accesible | Despliegue local desde fuente en Anvil |

## 10. Gate de aceptación técnica

No se marcará I-03 como completado hasta que existan evidencias de:
- [ ] commit/tag y tarball identificados;
- [ ] SHA-256 registrado;
- [ ] licencia y obligaciones documentadas;
- [ ] lockfile reproducible;
- [ ] compilación limpia con Solidity 0.8.17;
- [ ] tests originales ejecutados;
- [ ] despliegue local completo en Anvil;
- [ ] direcciones de todos los contratos persistidas;
- [ ] roles owner/agent comprobados;
- [ ] configuración de registries y compliance comprobada;
- [ ] tests positivos y negativos de identidad, mint y transfer;
- [ ] artefactos ABI y metadata archivados.

**Estado actual:** evaluación documental realizada; compilación, tests y despliegue no ejecutados. No se declara integración técnica completada.
