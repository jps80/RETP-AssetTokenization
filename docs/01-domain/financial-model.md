---
id: RETP-FINANCIAL-MODEL
version: 0.1
status: DRAFT
date: 2026-11-13
---

# Modelo financiero

## Conceptos diferenciados

| Concepto | Naturaleza | Efecto en cap table |
|---|---|---|
| Valor del inmueble | Valoración/precio del activo | No directamente |
| Equity | Financiación propia | Sí, tras instrumentación societaria |
| Capital nominal | Cifra jurídica de capital | Sí |
| Prima de asunción | Aportación sobre nominal | No aumenta unidades |
| Precio de suscripción | Importe económico por unidad | Incluye nominal y, en su caso, prima |
| Deuda bancaria | Pasivo financiero | No |
| Valor económico del equity | Residual económico | No altera automáticamente nominal |

No debe inferirse el valor económico de una participación a partir de su nominal.

## Escenario de financiación

Fuentes simplificadas: 700.000 € de equity y 300.000 € de deuda para una adquisición de 1.000.000 €, antes de costes.

`LTV = Deuda / Valor del activo = 300.000 / 1.000.000 = 30 %`.

No se incluyen impuestos, gastos de adquisición, costes financieros, reservas ni working capital.

## Capital social de laboratorio

- 14.000 participaciones.
- Nominal unitario: 50 €.
- Capital nominal: 700.000 €.
- Una clase ordinaria.
- Cantidades enteras.
- Token con `decimals = 0`.

La LSC exige la íntegra asunción y desembolso del nominal de las participaciones de SL en los términos legales. No se modelarán desembolsos parciales del nominal.

## Cap table ilustrativo

| Inversor | Unidades | % | Importe |
|---|---:|---:|---:|
| A | 4.200 | 30 % | 210.000 € |
| B | 3.500 | 25 % | 175.000 € |
| C | 2.800 | 20 % | 140.000 € |
| D | 2.100 | 15 % | 105.000 € |
| E | 1.400 | 10 % | 70.000 € |
| **Total** | **14.000** | **100 %** | **700.000 €** |

Supuesto simplificador: nominal y precio de suscripción coinciden y no hay prima.

## Deuda

`DebtFacility` contendrá prestamista, principal inicial, saldo vivo, tipo fijo/variable, índice y margen, fechas de disposición y vencimiento, amortización, intereses, garantías, covenants y estado.

`Equity Value (simplificado) = Asset Value + Other Assets - Debt - Other Liabilities`.

La deuda afecta al valor residual económico, pero no concede participaciones ni tokens.
