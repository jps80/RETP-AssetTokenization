---
id: RETP-CONTRACT-BOUNDARY
version: 0.1
status: DRAFT
date: 2026-11-13
related: [ADR-004, ADR-007, ADR-008, ADR-011]
---

# Frontera de integración con contratos inteligentes

## 1. Objetivo

Evitar que los módulos financieros de RETP dependan directamente de detalles de contratos, librerías EVM o proveedores RPC. La integración se concentra en Token Management y Blockchain Adapter.

## 2. Componentes

- **Token Management:** crea deployments, token issuances y mint commands; aplica reglas de dominio.
- **Blockchain Adapter:** traduce comandos a llamadas EVM; conoce ABI, direcciones, chain ID, receipts y logs.
- **Signing Service:** valida policy, maker-checker y firma; no contiene reglas financieras de titularidad.
- **Contract Registry:** persiste la identidad de cada deployment, sus direcciones, chain ID, versión de implementación y metadata de compilación.
- **Reconciliation:** compara asignaciones RETP con lecturas on-chain.

## 3. Interfaz de proveedor

El dominio debe depender de una interfaz equivalente a:

```ts
export interface TokenProtocolProvider {
  deployTokenSuite(command: DeployTokenSuiteCommand): Promise<DeploymentSubmission>;
  getDeployment(deploymentId: string): Promise<TokenSuiteDeployment>;
  isVerified(identityRegistry: string, wallet: string): Promise<boolean>;
  mint(command: MintCommand): Promise<TransactionSubmission>;
  getTransaction(transactionHash: string): Promise<TransactionObservation>;
  getBalance(tokenAddress: string, wallet: string): Promise<bigint>;
  getTotalSupply(tokenAddress: string): Promise<bigint>;
}
```

La interfaz es un contrato interno propuesto. No afirma que la suite T-REX exponga exactamente estos métodos con esos nombres.

## 4. Datos mínimos del deployment

- provider/protocol;
- package version y source commit;
- compiler version y optimizer settings;
- chain ID y RPC profile;
- factory/deployer strategy;
- token address;
- identity registry address;
- trusted issuers registry address;
- claim topics registry address;
- identity registry storage address;
- compliance address;
- implementation/proxy addresses cuando correspondan;
- deployment transaction hashes y block numbers;
- ABI/artifact version y content hash;
- owner y agents configurados.

No se debe inferir una dirección de contrato a partir de un nombre o símbolo. Todas las direcciones se obtienen del receipt/eventos de despliegue y se verifican con llamadas de lectura.

## 5. Modelo de transacción

Estados sugeridos:
`CREATED → POLICY_PENDING → APPROVED → SIGNING → SIGNED → SUBMITTED → CONFIRMED`.

Estados alternativos:
`REJECTED`, `SIGNING_FAILED`, `SUBMISSION_UNKNOWN`, `REVERTED`, `DROPPED`, `REORGED`.

Una transacción `SUBMITTED` no está confirmada. Timeout tras envío se modela como resultado indeterminado y se resuelve consultando hash, nonce, receipt y estado del contrato.

## 6. Límites de responsabilidad

- El frontend no construye calldata arbitraria ni determina el importe autorizado.
- Capital Management no llama RPC ni conoce ABI.
- Token Management no accede a claves privadas.
- Signing Service no decide si una persona es socio: valida autorización y política de ejecución.
- Blockchain Adapter no determina titularidad jurídica.
- Reconciliation detecta diferencias; no corrige posiciones societarias silenciosamente.

## 7. Pruebas de contrato

Las pruebas del adapter deben usar un deployment local real de la versión T-REX fijada. Mocks solo se utilizarán en pruebas unitarias del dominio, nunca como evidencia de integración ERC-3643.
