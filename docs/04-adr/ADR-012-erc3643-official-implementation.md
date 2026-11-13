# ADR-012: Integración de la implementación oficial ERC-3643

- Estado: Aceptada para el laboratorio local; sujeta a revisión de licencias antes de cualquier distribución.
- Fecha: 2026-11-13
- Contexto: RETP necesita desplegar y probar ERC-3643 desde el primer ciclo blockchain, sin implementar un token propio ni depender de factories productivas.

## Decisión

1. Usar como referencia la implementación oficial de https://github.com/ERC-3643/ERC-3643, fijada en el commit `2f0704dee9658ad9cd5b6ed82e7427da74c28345` (publicación npm observada: `@erc3643org/erc-3643@4.1.3`).
2. Compilar y desplegar la fuente upstream mediante Foundry (Forge) contra el nodo Anvil local (chain ID 31337). Foundry es tooling de RETP; no se modifica ni se porta el código upstream.
3. Desplegar localmente factory, implementaciones y suite ERC-3643; no utilizar direcciones de factory productivas ni wallets whitelisted de producción.
4. Mantener el código de integración RETP (deployment orchestration, manifest, adapter, persistencia y tests de aceptación) separado de los contratos upstream.
5. No modificar ni copiar selectivamente contratos upstream sin revisión técnica y jurídica específica.
6. Tratar el balance on-chain como espejo técnico auxiliar; no sustituye el Libro Registro de Socios ni formalidades societarias españolas.

## Razones

- La implementación upstream proporciona el comportamiento concreto que debe probarse; una implementación propia introduciría riesgos de divergencia con el estándar.
- Foundry permite pruebas Solidity nativas, fuzzing e invariant testing. La compatibilidad de compilación con el commit upstream se validará sin modificar sus fuentes.
- Anvil permite un ciclo EVM local reproducible sin depender de una red pública.
- Un manifest de despliegue desacopla el proceso de despliegue de contratos del backend NestJS.

## Licencias y propiedad intelectual

El repositorio oficial consultado declara GPL-3.0. RETP tiene licencia Apache-2.0. Esta diferencia no se debe ignorar ni resolver mediante una suposición de compatibilidad.

Para el laboratorio:
- conservar los avisos de copyright y licencia del upstream;
- registrar el commit exacto y la procedencia de cada dependencia;
- no relicenciar código GPL como Apache-2.0;
- mantener los artefactos y código upstream identificables y separados del código propio.

Antes de distribuir una combinación de código, artefactos compilados o producto que incorpore la implementación, realizar revisión jurídica de las obligaciones GPL-3.0 y de la forma concreta de integración. Esta ADR no constituye una opinión legal ni concluye que cualquier modalidad de linking/distribución sea compatible.

## Consecuencias

Positivas:
- menor riesgo de divergencia funcional;
- reproducibilidad por commit;
- despliegue local sin dependencias de producción;
- frontera clara entre suite de contratos y aplicación.

Costes y riesgos:
- dependencia del ciclo de releases upstream;
- complejidad de mantener el workspace Foundry y el backend NestJS;
- obligaciones GPL-3.0 que deben evaluarse antes de distribución;
- el despliegue local no equivale a auditoría ni certificación de seguridad.

## Verificación requerida

- fijar commit upstream, Foundry, solc 0.8.17, optimizer 200 runs y dependencias Solidity/npm exactas en lockfiles;
- compilar el commit fijado con Foundry y ejecutar tests de aceptación RETP; los tests upstream TypeScript/Hardhat podrán seguir ejecutándose en su entorno original;
- comprobar bindings entre Token, Identity Registry y Compliance;
- revisar semántica concreta de mint, freeze, pause, recovery y forced transfer;
- guardar manifest de despliegue con chain ID y source commit;
- no habilitar mint de participaciones RETP hasta que la capa corporativa lo autorice.
