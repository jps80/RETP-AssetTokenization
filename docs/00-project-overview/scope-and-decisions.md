---
id: RETP-SCOPE
version: 0.1
status: DRAFT
date: 2026-11-13
---

# Alcance y decisiones vigentes

## Configuración del vehículo

| Dimensión | Decisión |
|---|---|
| Activo | Un inmueble por SPV |
| Vehículo inicial | SL española |
| Clases | Una clase ordinaria |
| Financiación | Mixta: equity + deuda bancaria |
| Token | ERC-3643, espejo técnico auxiliar |
| Decimales | 0 en el laboratorio |
| Red inicial | Anvil |
| Red de integración | Sepolia |

La plataforma podrá gestionar varias SPV independientes.

## Financiación

El equity y la deuda son componentes distintos. El equity puede dar lugar a participaciones mediante los actos societarios correspondientes. La deuda es un pasivo frente al prestamista y no genera participaciones ni tokens de equity.

El agregado `DebtFacility` se mantiene separado del cap table.

## Escenario didáctico

| Parámetro | Valor |
|---|---:|
| Precio de adquisición | 1.000.000 € |
| Deuda bancaria | 300.000 € |
| Equity | 700.000 € |
| LTV inicial simplificado | 30 % |
| Participaciones | 14.000 |
| Nominal unitario | 50 € |
| Capital nominal | 700.000 € |

Distribución ilustrativa: A 30 %, B 25 %, C 20 %, D 15 % y E 10 %. Estos importes son supuestos de aprendizaje, no parámetros jurídicos definitivos ni recomendación financiera.

El modelo de datos mantendrá separados nominal, prima de asunción y precio de suscripción. En una SL, el nominal debe estar íntegramente asumido y desembolsado conforme a la LSC; no modelaremos desembolsos parciales del nominal como modalidad válida.

## Separación societaria y técnica

- Una suscripción pagada no se convierte automáticamente en participación.
- Una asignación societaria aprobada puede originar una instrucción de tokenización.
- Un mint no determina por sí solo la titularidad jurídica.
- Un fallo blockchain no revierte automáticamente un acto societario perfeccionado.
- Un movimiento on-chain sin soporte societario es una incidencia que requiere investigación y tratamiento controlado.

## Verificaciones pendientes

- Fijar versión/commit de T-REX y verificar compilador, dependencias y licencia.
- Probar compatibilidad de SoftHSM2/PKCS#11 con firma EVM secp256k1.
- Verificar interfaces y roles de los contratos de la versión concreta de T-REX.
- Revisar el perímetro regulatorio de un caso real, incluido posible análisis AIFMD/IIC y normativa de mercados.
