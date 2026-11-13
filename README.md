# RETP — Real Estate Tokenization Platform

Plataforma de laboratorio para aprender y practicar la tokenización financiera mediante el diseño y construcción incremental de una aplicación funcional.

> **Uso exclusivamente educativo.** No es una oferta de inversión, servicio de custodia ni infraestructura de emisión productiva. Se utilizarán datos, identidades y redes de prueba.

## Objetivo

Aprender el ecosistema desde los fundamentos financieros, jurídicos y operativos hasta su materialización técnica. La prioridad es el diseño financiero y de dominio; la ingeniería de software permite implementar y validar esos modelos.

## Baseline de diseño

- Una sociedad limitada española (SL) por inmueble; la plataforma podrá gestionar múltiples SPV.
- Una única clase ordinaria de participaciones por SPV en la primera versión.
- Financiación mixta: equity y deuda bancaria, modelados separadamente.
- ERC-3643 como espejo técnico auxiliar, no como representación jurídica de las participaciones de SL.
- PostgreSQL como fuente operacional; blockchain registra la ejecución técnica.
- Primera emisión integrada en v0.3.
- Anvil primero; Sepolia para integración posterior.
- React + TypeScript, NestJS, PostgreSQL/Prisma, RabbitMQ y Docker Compose.
- Firma aislada de laboratorio con SoftHSM2/PKCS#11, policy engine y maker-checker.

## Estado

| Elemento | Estado |
|---|---|
| Infraestructura Docker base | Entregada; contenedores confirmados operativos por el usuario |
| Backend Foundation | Entregada; validación local pendiente |
| Diseño de Capital Management | Diseñado |
| Diseño de emisión ERC-3643 v0.3 | Especificado |
| Evaluación documental T-REX | Realizada; versión candidata 4.1.3 |
| Compilación y tests T-REX | Pendientes |
| Implementación integrada | Pendiente |
| Despliegue T-REX en Anvil | Pendiente |
| Firma SoftHSM2/PKCS#11 | Pendiente de prueba de compatibilidad |
| Conciliación | Diseñada; implementación pendiente |

## Documentación

- [Alcance y decisiones](docs/00-project-overview/scope-and-decisions.md)
- [Visión de dominio](docs/01-domain/domain-overview.md)
- [Modelo financiero](docs/01-domain/financial-model.md)
- [Especificación v0.3](docs/02-specifications/retp-v0.3-capital-token-issuance.md)
- [Modelo de datos v0.3](docs/02-specifications/data-model-v0.3.md)
- [Arquitectura](docs/03-architecture/architecture-overview.md)
- [Frontera de integración contractual](docs/03-architecture/contract-integration-boundary.md)
- [Registro ADR](docs/04-adr/README.md)
- [ADR-011: T-REX](docs/04-adr/ADR-011-trex-version-and-integration.md)
- [Evaluación técnica de T-REX](docs/05-tokenization/trex-technical-assessment.md)
- [Semántica de emisión y pruebas](docs/05-tokenization/issuance-semantics-and-test-matrix.md)
- [Roadmap de aprendizaje](docs/08-learning/learning-roadmap.md)

## Método SDD

1. Fundamento financiero, jurídico y operativo.
2. Análisis de dominio e invariantes.
3. Requisitos, escenarios y criterios de aceptación.
4. Diseño de arquitectura, datos, API e interfaz.
5. Implementación.
6. Pruebas y validación.
7. Revisión de decisiones y aprendizajes.

## Cautela jurídica y de licencias

El artículo 92.2 de la Ley de Sociedades de Capital establece que las participaciones sociales de SL no tienen carácter de valores y no pueden representarse mediante títulos ni anotaciones en cuenta. Por ello, el token se diseña como espejo técnico auxiliar. La titularidad y transmisión se determinan conforme a la documentación y registros societarios aplicables, no por el mero saldo de `balanceOf`.

La licencia Apache-2.0 del repositorio no sustituye la revisión de las licencias de T-REX y de cada dependencia de terceros. La suite ERC-3643 consultada declara GPL-3.0; su integración y distribución se mantienen sujetas a revisión específica.
