// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";

import {ClaimTopicsRegistry} from "ERC3643/contracts/registry/implementation/ClaimTopicsRegistry.sol";
import {TrustedIssuersRegistry} from "ERC3643/contracts/registry/implementation/TrustedIssuersRegistry.sol";
import {IdentityRegistryStorage} from "ERC3643/contracts/registry/implementation/IdentityRegistryStorage.sol";
import {IdentityRegistry} from "ERC3643/contracts/registry/implementation/IdentityRegistry.sol";
import {ModularCompliance} from "ERC3643/contracts/compliance/modular/ModularCompliance.sol";
import {Token} from "ERC3643/contracts/token/Token.sol";

import {TREXImplementationAuthority} from "ERC3643/contracts/proxy/authority/TREXImplementationAuthority.sol";
import {ITREXImplementationAuthority} from "ERC3643/contracts/proxy/authority/ITREXImplementationAuthority.sol";

import {ClaimTopicsRegistryProxy} from "ERC3643/contracts/proxy/ClaimTopicsRegistryProxy.sol";
import {TrustedIssuersRegistryProxy} from "ERC3643/contracts/proxy/TrustedIssuersRegistryProxy.sol";
import {IdentityRegistryStorageProxy} from "ERC3643/contracts/proxy/IdentityRegistryStorageProxy.sol";
import {IdentityRegistryProxy} from "ERC3643/contracts/proxy/IdentityRegistryProxy.sol";
import {ModularComplianceProxy} from "ERC3643/contracts/proxy/ModularComplianceProxy.sol";
import {TokenProxy} from "ERC3643/contracts/proxy/TokenProxy.sol";

/// @notice Deploys the official ERC-3643 implementation suite to a local Anvil chain.
/// @dev Direct proxy deployment is used in this first lab increment; no production factory is called.
contract DeployERC3643 is Script {
    string private constant SOURCE_COMMIT = "2f0704dee9658ad9cd5b6ed82e7427da74c28345";

    function run() external {
        uint256 deployerKey = vm.envUint("ANVIL_PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        ClaimTopicsRegistry ctrImplementation = new ClaimTopicsRegistry();
        TrustedIssuersRegistry tirImplementation = new TrustedIssuersRegistry();
        IdentityRegistryStorage irsImplementation = new IdentityRegistryStorage();
        IdentityRegistry irImplementation = new IdentityRegistry();
        ModularCompliance mcImplementation = new ModularCompliance();
        Token tokenImplementation = new Token();

        TREXImplementationAuthority implementationAuthority =
            new TREXImplementationAuthority(true, address(0), address(0));

        ITREXImplementationAuthority.Version memory version =
            ITREXImplementationAuthority.Version({major: 4, minor: 0, patch: 0});

        ITREXImplementationAuthority.TREXContracts memory implementations =
            ITREXImplementationAuthority.TREXContracts({
                tokenImplementation: address(tokenImplementation),
                ctrImplementation: address(ctrImplementation),
                irImplementation: address(irImplementation),
                irsImplementation: address(irsImplementation),
                tirImplementation: address(tirImplementation),
                mcImplementation: address(mcImplementation)
            });

        implementationAuthority.addAndUseTREXVersion(version, implementations);

        ClaimTopicsRegistryProxy ctr = new ClaimTopicsRegistryProxy(address(implementationAuthority));
        TrustedIssuersRegistryProxy tir = new TrustedIssuersRegistryProxy(address(implementationAuthority));
        IdentityRegistryStorageProxy irs = new IdentityRegistryStorageProxy(address(implementationAuthority));
        IdentityRegistryProxy ir = new IdentityRegistryProxy(
            address(implementationAuthority), address(tir), address(ctr), address(irs)
        );
        ModularComplianceProxy compliance = new ModularComplianceProxy(address(implementationAuthority));
        TokenProxy token = new TokenProxy(
            address(implementationAuthority),
            address(ir),
            address(compliance),
            "RETP Lab Participation",
            "RETP",
            0,
            address(0)
        );

        vm.stopBroadcast();

        string memory json = vm.serializeUint("retpDeployment", "chainId", block.chainid);
        json = vm.serializeString("retpDeployment", "sourceCommit", SOURCE_COMMIT);
        json = vm.serializeString("retpDeployment", "compiler", "solc 0.8.17");
        json = vm.serializeUint("retpDeployment", "optimizerRuns", 200);
        json = vm.serializeAddress("retpDeployment", "implementationAuthority", address(implementationAuthority));
        json = vm.serializeAddress("retpDeployment", "claimTopicsRegistry", address(ctr));
        json = vm.serializeAddress("retpDeployment", "trustedIssuersRegistry", address(tir));
        json = vm.serializeAddress("retpDeployment", "identityRegistryStorage", address(irs));
        json = vm.serializeAddress("retpDeployment", "identityRegistry", address(ir));
        json = vm.serializeAddress("retpDeployment", "compliance", address(compliance));
        json = vm.serializeAddress("retpDeployment", "token", address(token));
        vm.writeJson(json, "deployments/anvil-31337.json");
    }
}
