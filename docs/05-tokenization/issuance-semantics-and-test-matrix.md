---
id: RETP-ERC3643-SEMANTICS
version: 0.1
status: DRAFT
date: 2026-11-13
related: [ADR-011, RETP-SDD-0.3]
---

# Semántica de emisión ERC-3643 y matriz de pruebas

## 1. Tres capas de control

| Capa | Pregunta | Autoridad |
|---|---|---|
| Societaria | ¿Existe una asignación válida que pueda reflejarse? | Evidencia y workflow de Capital/Corporate Registry |
| Identidad | ¿Puede esta wallet mantener el token? | ONCHAINID + Identity Registry |
| Operación | ¿Permite el contrato esta operación? | Token + Compliance |

El motor de autorización RETP añade una cuarta comprobación: ¿está autorizado el actor y aprobada la orden concreta para su ejecución?

## 2. Semántica de mint observada en Token.sol

En el código consultado del repositorio oficial actual, la función `mint` sigue esta secuencia lógica:

1. exige el rol `Agent`;
2. verifica `IdentityRegistry.isVerified(to)`;
3. consulta `Compliance.canTransfer(address(0), to, amount)`;
4. ejecuta `_mint`;
5. notifica `Compliance.created(to, amount)`.

Por tanto, para esta implementación el mint sí pasa por una comprobación de Compliance con dirección de origen cero. No debe confundirse con el bypass que describe la documentación histórica general de la EIP.

La semántica final se confirmará con un test de integración sobre el commit fijado para RETP.

## 3. Semántica de transfer y forced transfer

Transfer ordinaria:
- requiere token no pausado;
- comprueba wallets congeladas y saldo disponible;
- verifica la identidad del destinatario;
- consulta `canTransfer(from, to, amount)`;
- notifica `transferred` tras la transferencia.

Forced transfer:
- es una función privilegiada de agente;
- requiere verificación del destinatario;
- puede modificar tokens congelados para completar la operación;
- no sigue el mismo precheck de Compliance que la transferencia ordinaria en el código consultado.

RETP no expondrá forced transfer como operación ordinaria en v0.3. La función se documentará como capacidad privilegiada del protocolo y quedará sometida a controles extraordinarios en una iteración posterior.

## 4. Reglas de aplicación RETP antes de mint

Antes de solicitar una firma, el backend deberá validar:
- estado de emisión aprobado;
- referencia a evento de capital y asignación aprobados;
- evidencia societaria registrada;
- cantidad solicitada menor o igual a unidades autorizadas menos unidades ya acuñadas;
- wallet vinculada al inversor y a la red correcta;
- ONCHAINID registrada y `isVerified(wallet) = true`;
- token desplegado, activo y con chain ID esperado;
- agente de emisión correctamente configurado;
- política de firma y maker-checker satisfechos;
- idempotency key no consumida;
- ausencia de transacción previa en estado indeterminado para esa orden.

La llamada a Compliance del contrato es un control adicional, no reemplaza estas reglas.

## 5. Matriz mínima de pruebas de integración

| ID | Preparación | Operación | Resultado esperado |
|---|---|---|---|
| TKN-001 | Destinatario con identidad verificada; agente autorizado | mint | Éxito |
| TKN-002 | Destinatario sin Identity Registry entry | mint | Revert |
| TKN-003 | Destinatario con claims requeridos ausentes | mint | Revert por no verificado |
| TKN-004 | Destinatario con issuer no confiable | mint | Revert por no verificado |
| TKN-005 | Compliance module que rechaza `from=0x0` o cantidad | mint | Revert |
| TKN-006 | Cuenta sin rol Agent | mint | Revert por permisos |
| TKN-007 | Token pausado | transfer | Revert |
| TKN-008 | Destinatario no verificado | transfer | Revert |
| TKN-009 | Compliance rechaza operación | transfer | Revert |
| TKN-010 | Wallet origen/destino congelada | transfer | Revert |
| TKN-011 | Agente intenta forced transfer a destinatario no verificado | forcedTransfer | Revert |
| TKN-012 | RETP no tiene asignación societaria aprobada | Solicitud de mint vía API | Bloqueo antes de firmar |
| TKN-013 | Maker intenta aprobar su propia orden | aprobación | Bloqueo |
| TKN-014 | Misma idempotency key y mismo comando | reintento | No se produce segundo mint |
| TKN-015 | Timeout después del envío | recuperación | Consultar hash/receipt; no reenviar ciegamente |

## 6. Nota de precisión

La EIP define interfaces y requisitos generales. Una versión concreta de T-REX implementa esos requisitos mediante código y módulos específicos. Las diferencias entre documentación, interfaces y comportamiento ejecutable deben registrarse como hallazgos versionados, no resolverse mediante suposiciones.

La matriz anterior es un plan de pruebas; no constituye evidencia de que los tests hayan sido ejecutados.
