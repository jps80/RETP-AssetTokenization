# I-03 — ERC-3643 deployment lab baseline

## Purpose

I-03 establishes a reproducible local deployment of the official ERC-3643/T-REX reference implementation on the RETP Anvil chain (chain ID 31337). It is the first blockchain implementation increment. It is not a production issuance and does not create legal rights in a Spanish SL.

## Upstream source baseline

| Attribute | Selected baseline |
|---|---|
| Upstream repository | https://github.com/ERC-3643/ERC-3643 |
| Upstream commit | `2f0704dee9658ad9cd5b6ed82e7427da74c28345` |
| Published npm package | `@erc3643org/erc-3643@4.1.3` |
| Solidity pragma observed in Token.sol | `0.8.17` |
| OpenZeppelin dependency observed upstream | `4.8.3` |
| ONCHAINID Solidity dependency observed upstream | `^2.0.0` |
| Upstream license | GPL-3.0 |

The upstream repository is the official ERC-3643 organisation's implementation. The older TokenySolutions/T-REX repository is archived and is not the selected source.

The commit SHA, rather than a moving branch or tag, is the immutable source reference for this lab. Any upgrade requires a separate review of source changes, dependencies, interfaces, tests, license obligations and deployed bytecode.

## Toolchain decision

Use the upstream Hardhat toolchain for compiling and deploying the official contracts, and use the existing Anvil service as the local EVM JSON-RPC node. Do not port the upstream contracts to Foundry or rewrite them for this exercise.

Reasons:
- the official repository itself uses Hardhat;
- this avoids changing the build system of the upstream Solidity suite;
- Anvil is an EVM node and does not require the deployment framework to be Foundry;
- the RETP application remains independent of the upstream build system and consumes deployment manifests and contract ABIs/addresses.

The exact Hardhat, Solidity compiler and Node dependency graph must be locked in the contract workspace lockfile. The upstream repository currently declares Hardhat 2.x and Solidity sources with pragma 0.8.17; the final compiler configuration must be verified against the pinned commit before deployment.

## Deployment scope

The local suite must include, at minimum, the components required by the official implementation:
- Token implementation/proxy;
- Identity Registry;
- Identity Registry Storage;
- Modular Compliance;
- Trusted Issuers Registry;
- Claim Topics Registry;
- ONCHAINID contracts and claim issuer test fixtures where required;
- TREX Factory and related implementation contracts when using the official suite deployment flow.

The lab must deploy its own factory/implementations on Anvil. It must not depend on production factory addresses, whitelisted deployment wallets, or external issuer infrastructure.

## RETP integration boundary

The contract workspace is responsible for:
1. compiling the pinned upstream suite;
2. deploying the suite to Anvil;
3. configuring the lab token and identity/compliance registries;
4. emitting a versioned deployment manifest containing chain ID, source commit, package/compiler versions, deployment transaction hashes, addresses and ABI references;
5. providing scripts and tests to verify deployed component relationships.

The NestJS API / Blockchain Adapter is responsible for consuming the manifest and persisting deployment metadata. It must not compile, mutate, or duplicate the ERC-3643 contracts.

## Important semantic verification: mint

The EIP-3643 specification text and a concrete reference implementation must not be treated as interchangeable evidence. In the pinned upstream `Token.sol` at the selected commit, `mint(address,uint256)` is `onlyAgent`, checks `IdentityRegistry.isVerified(to)`, checks `Compliance.canTransfer(address(0), to, amount)`, then calls `_mint` and `Compliance.created`.

This behavior is an explicit implementation detail to test against the exact pinned source. RETP must not assume that all ERC-3643 implementations have identical mint semantics. The application must independently enforce corporate authorization, shareholder-register evidence, approved allocation, maker-checker and idempotency before requesting a mint.

## Legal and accounting boundary

The ERC-3643 balance is an auxiliary technical record. For the Spanish SL laboratory model, it is not the Libro Registro de Socios and does not itself prove ownership of participaciones sociales. No on-chain mint may be treated as constitutive of the corporate allocation.

## Acceptance criteria for I-03

- Anvil is reachable at `http://127.0.0.1:8545` and reports chain ID 31337.
- The pinned official source compiles with a locked dependency graph.
- A complete local suite is deployed without production factory infrastructure.
- A manifest is generated and persisted in the repository as a sample with deterministic local addresses clearly marked as ephemeral.
- Tests verify token ↔ identity registry and token ↔ compliance bindings.
- Tests verify a verified identity can receive an authorized mint and an unverified identity is rejected.
- Tests verify a transfer is rejected when identity verification or compliance fails.
- Tests verify pause/freeze behavior relevant to the configured suite.
- Tests verify deployment is repeatable from a clean Anvil state.
- No production private key, wallet seed or real investor personal data is committed.

## Non-goals

- Sepolia deployment.
- Production custody or HSM integration.
- Real KYC/AML claims or real investor identity data.
- Legal issuance or transfer of Spanish SL participations.
- Minting the 14,000 scenario units before Corporate Registry and Token Management workflows are implemented.
