# RETP contract workspace — Foundry

This workspace compiles and deploys the **official ERC-3643 source** pinned by ADR-012. RETP does not fork, rewrite or reimplement the upstream contracts.

## Pinned build inputs

- ERC-3643 source commit: `2f0704dee9658ad9cd5b6ed82e7427da74c28345`
- Solidity compiler: `0.8.17`
- Optimizer: enabled, 200 runs
- ONCHAINID Solidity package: `2.2.1`
- OpenZeppelin Contracts and Contracts Upgradeable: `4.9.6`

The OpenZeppelin and ONCHAINID versions above are the versions resolved by the pinned upstream `package-lock.json`; they are more precise than the semver ranges in upstream `package.json`. `package-lock.json` for this workspace must be generated and committed before calling the build reproducible.

## 1. Install tools (Ubuntu)

Install Foundry using the official installer:

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
forge --version
anvil --version
cast --version
```

Install Node.js/npm using the version manager or runtime already used by the RETP API.

## 2. Fetch the pinned upstream source

From the repository root:

```bash
git submodule add https://github.com/ERC-3643/ERC-3643.git apps/contracts/lib/erc3643
git -C apps/contracts/lib/erc3643 checkout 2f0704dee9658ad9cd5b6ed82e7427da74c28345
```

Do not edit files under `apps/contracts/lib/erc3643`. Preserve the upstream license and notices.

Install the Foundry test library:

```bash
cd apps/contracts
forge install foundry-rs/forge-std@v1.9.6
```

Generate and commit the npm lockfile, then install exactly from it:

```bash
npm install --package-lock-only
npm ci
```

Add the submodule metadata, gitlinks and lockfiles to the feature branch. These steps make the external source and dependencies reproducible for every clone.

## 3. Compile

From `apps/contracts`:

```bash
forge clean
forge build
```

The Foundry configuration deliberately matches the upstream compiler version and optimizer settings. A successful build has not yet been claimed: the first local build is an explicit acceptance gate.

## 4. Start Anvil

In terminal 1:

```bash
anvil --host 127.0.0.1 --port 8545 --chain-id 31337
```

In terminal 2, confirm the endpoint and chain ID:

```bash
cast chain-id --rpc-url http://127.0.0.1:8545
```

Expected chain ID: `31337`.

Use only a private key printed by this disposable local Anvil instance. Never reuse a wallet, seed or key from another environment, and never commit the key.

```bash
export ANVIL_PRIVATE_KEY=0x<PRIVATE_KEY_FROM_LOCAL_ANVIL>
```

## 5. Deploy the core ERC-3643 suite

```bash
forge script script/DeployERC3643.s.sol:DeployERC3643 \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

The first deployment script deploys the implementation authority, official implementation contracts, registry/compliance proxies and token proxy directly. It does **not** call a production factory or depend on whitelisted production wallets. It writes a local manifest to `deployments/anvil-31337.json`.

This first deployment is a technical smoke deployment only:
- the token starts paused, following the upstream Token initialization behavior;
- no investor identity, KYC claim or investor balance is created;
- no RETP corporate allocation is minted;
- no Spanish SL ownership or shareholder-register entry is created;
- local addresses are ephemeral and must not be reused as deployment identifiers outside this Anvil state.

## 6. Acceptance gates

1. `forge build` succeeds against the pinned upstream commit.
2. Anvil reports chain ID 31337.
3. The deployment script completes and emits non-zero addresses for the implementation authority, registries, compliance and token.
4. Read-only calls confirm that the token points to the deployed Identity Registry and Compliance proxy.
5. The deployment manifest records source commit, compiler settings, chain ID and addresses.

Verify the token's registry and compliance bindings using the generated manifest:

```bash
TOKEN=$(jq -r '.token' deployments/anvil-31337.json)
EXPECTED_IR=$(jq -r '.identityRegistry' deployments/anvil-31337.json)
EXPECTED_COMPLIANCE=$(jq -r '.compliance' deployments/anvil-31337.json)

ACTUAL_IR=$(cast call "$TOKEN" 'identityRegistry()(address)' --rpc-url http://127.0.0.1:8545)
ACTUAL_COMPLIANCE=$(cast call "$TOKEN" 'compliance()(address)' --rpc-url http://127.0.0.1:8545)
PAUSED=$(cast call "$TOKEN" 'paused()(bool)' --rpc-url http://127.0.0.1:8545)

test "${ACTUAL_IR,,}" = "${EXPECTED_IR,,}"
test "${ACTUAL_COMPLIANCE,,}" = "${EXPECTED_COMPLIANCE,,}"
test "$PAUSED" = "true"
```

The first two returned addresses must match `EXPECTED_IR` and `EXPECTED_COMPLIANCE`; `paused()` should initially return `true`. These are read-only checks and do not unpause the token.

The next iteration adds Foundry tests for identity eligibility, mint authorization, transfer restrictions, pause/freeze and invariant properties. Minting the 14,000 scenario units remains prohibited until RETP's Corporate Registry and Token Management authorization workflow exists.

## 7. License boundary

The ERC-3643 source repository declares GPL-3.0 and remains a separately identifiable Git submodule. Note that the ONCHAINID GitHub repository declares GPL-3.0 while its npm package 2.2.1 metadata declares ISC; preserve the notices from the exact package/source actually used and have this discrepancy reviewed. RETP integration code in this workspace is Apache-2.0. Obtain legal review before distributing a combined work or compiled artifacts.
