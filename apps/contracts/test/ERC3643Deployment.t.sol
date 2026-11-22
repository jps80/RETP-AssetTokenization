// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";

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
import {IIdentity} from "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import {Identity} from "@onchain-id/solidity/contracts/Identity.sol";
import {ClaimIssuer} from "@onchain-id/solidity/contracts/ClaimIssuer.sol";
import {IClaimIssuer} from "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import {IIdentityRegistryStorage} from "ERC3643/contracts/registry/interface/IIdentityRegistryStorage.sol";
import {IClaimTopicsRegistry} from "ERC3643/contracts/registry/interface/IClaimTopicsRegistry.sol";
import {ITrustedIssuersRegistry} from "ERC3643/contracts/registry/interface/ITrustedIssuersRegistry.sol";

/// @notice Integration smoke tests against the pinned official ERC-3643 proxy suite.
/// @dev The empty claim-topic registry makes any registered non-zero identity eligible.
///      This is a test fixture only, not an acceptable production compliance policy.
contract ERC3643DeploymentTest is Test {
    Token internal token;
    IdentityRegistry internal identityRegistry;
    ModularCompliance internal compliance;
    IClaimTopicsRegistry internal claimTopicsRegistry;
    ITrustedIssuersRegistry internal trustedIssuersRegistry;

    uint256 internal constant KYC_CLAIM_TOPIC = 1;
    uint256 internal constant ISSUER_SIGNER_PRIVATE_KEY = 0xA11CE;

    address internal investor = address(0xA11CE);
    address internal unverifiedInvestor = address(0xB0B);

    function setUp() public {
        ClaimTopicsRegistry ctrImplementation = new ClaimTopicsRegistry();
        TrustedIssuersRegistry tirImplementation = new TrustedIssuersRegistry();
        IdentityRegistryStorage irsImplementation = new IdentityRegistryStorage();
        IdentityRegistry irImplementation = new IdentityRegistry();
        ModularCompliance mcImplementation = new ModularCompliance();
        Token tokenImplementation = new Token();

        TREXImplementationAuthority authority =
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

        authority.addAndUseTREXVersion(version, implementations);

        ClaimTopicsRegistryProxy ctr = new ClaimTopicsRegistryProxy(address(authority));
        TrustedIssuersRegistryProxy tir = new TrustedIssuersRegistryProxy(address(authority));
        IdentityRegistryStorageProxy irs = new IdentityRegistryStorageProxy(address(authority));
        IdentityRegistryProxy ir = new IdentityRegistryProxy(
            address(authority), address(tir), address(ctr), address(irs)
        );
        ModularComplianceProxy mc = new ModularComplianceProxy(address(authority));
        TokenProxy tokenProxy = new TokenProxy(
            address(authority),
            address(ir),
            address(mc),
            "RETP Lab Participation",
            "RETP",
            0,
            address(0)
        );

        identityRegistry = IdentityRegistry(address(ir));
        compliance = ModularCompliance(address(mc));
        token = Token(address(tokenProxy));
        claimTopicsRegistry = IClaimTopicsRegistry(address(ctr));
        trustedIssuersRegistry = ITrustedIssuersRegistry(address(tir));

        // The Identity Registry must be bound as an agent of its storage.
        // Otherwise registerIdentity() reaches IdentityRegistryStorage.addIdentityToStorage()
        // and reverts with AgentRole: caller does not have the Agent role.
        IIdentityRegistryStorage(address(irs)).bindIdentityRegistry(address(ir));

        // The test contract owns the proxies because it deployed them.
        identityRegistry.addAgent(address(this));
        token.addAgent(address(this));
    }

    function testDeploymentStartsPausedWithZeroSupplyAndCorrectBindings() public view {
        assertTrue(token.paused());
        assertEq(token.totalSupply(), 0);
        assertEq(address(token.identityRegistry()), address(identityRegistry));
        assertEq(address(token.compliance()), address(compliance));
        assertEq(compliance.getTokenBound(), address(token));
    }

    function testMintRejectsUnregisteredInvestor() public {
        vm.expectRevert(bytes("Identity is not verified."));
        token.mint(unverifiedInvestor, 1);
    }

    function testMintRejectsCallerWithoutAgentRole() public {
        vm.prank(address(0xBAD));
        vm.expectRevert(bytes("AgentRole: caller does not have the Agent role"));
        token.mint(investor, 1);
    }

    function testRegisteredInvestorCanReceiveMintInEmptyTopicFixture() public {
        identityRegistry.registerIdentity(investor, IIdentity(address(0x1234)), 724);

        assertTrue(identityRegistry.isVerified(investor));
        token.mint(investor, 14_000);

        assertEq(token.balanceOf(investor), 14_000);
        assertEq(token.totalSupply(), 14_000);
    }

    function testTransferIsBlockedWhileTokenIsPaused() public {
        identityRegistry.registerIdentity(address(this), IIdentity(address(0x1234)), 724);
        identityRegistry.registerIdentity(investor, IIdentity(address(0x5678)), 724);
        token.mint(address(this), 100);

        vm.expectRevert(bytes("Pausable: paused"));
        token.transfer(investor, 1);
    }


    function testRequiredKycClaimRejectsIdentityWithoutClaim() public {
        (ClaimIssuer issuer,) = _configureKycClaim();
        Identity investorIdentity = new Identity(investor, false);
        identityRegistry.registerIdentity(investor, IIdentity(address(investorIdentity)), 724);

        assertFalse(identityRegistry.isVerified(investor));
        vm.expectRevert(bytes("Identity is not verified."));
        token.mint(investor, 1);

        // Keep the issuer referenced so the setup is explicit and not optimized away conceptually.
        assertTrue(trustedIssuersRegistry.isTrustedIssuer(address(issuer)));
    }

    function testValidKycClaimMakesIdentityEligibleForMint() public {
        (ClaimIssuer issuer, uint256 issuerSignerKey) = _configureKycClaim();
        Identity investorIdentity = _createIdentityWithKycClaim(issuer, issuerSignerKey);
        identityRegistry.registerIdentity(investor, IIdentity(address(investorIdentity)), 724);

        assertTrue(identityRegistry.isVerified(investor));
        token.mint(investor, 14_000);

        assertEq(token.balanceOf(investor), 14_000);
        assertEq(token.totalSupply(), 14_000);
    }

    function testRevokedKycClaimMakesIdentityIneligible() public {
        (ClaimIssuer issuer, uint256 issuerSignerKey) = _configureKycClaim();
        Identity investorIdentity = _createIdentityWithKycClaim(issuer, issuerSignerKey);
        identityRegistry.registerIdentity(investor, IIdentity(address(investorIdentity)), 724);

        assertTrue(identityRegistry.isVerified(investor));

        bytes memory data = abi.encode("KYC_APPROVED");
        bytes32 dataHash = keccak256(abi.encode(IIdentity(address(investorIdentity)), KYC_CLAIM_TOPIC, data));
        bytes32 prefixedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(issuerSignerKey, prefixedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(address(0x155E));
        issuer.revokeClaimBySignature(signature);

        assertFalse(identityRegistry.isVerified(investor));
        vm.expectRevert(bytes("Identity is not verified."));
        token.mint(investor, 1);
    }

    function _configureKycClaim() internal returns (ClaimIssuer issuer, uint256 signerKey) {
        signerKey = ISSUER_SIGNER_PRIVATE_KEY;
        address issuerManager = address(0x155E);

        issuer = new ClaimIssuer(issuerManager);
        vm.prank(issuerManager);
        issuer.addKey(keccak256(abi.encode(vm.addr(signerKey))), 3, 1);

        claimTopicsRegistry.addClaimTopic(KYC_CLAIM_TOPIC);
        uint256[] memory topics = new uint256[](1);
        topics[0] = KYC_CLAIM_TOPIC;
        trustedIssuersRegistry.addTrustedIssuer(IClaimIssuer(address(issuer)), topics);
    }

    function _createIdentityWithKycClaim(
        ClaimIssuer issuer,
        uint256 issuerSignerKey
    ) internal returns (Identity investorIdentity) {
        investorIdentity = new Identity(investor, false);
        bytes memory data = abi.encode("KYC_APPROVED");
        bytes32 dataHash = keccak256(abi.encode(IIdentity(address(investorIdentity)), KYC_CLAIM_TOPIC, data));
        bytes32 prefixedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(issuerSignerKey, prefixedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(investor);
        investorIdentity.addClaim(
            KYC_CLAIM_TOPIC,
            1,
            address(issuer),
            signature,
            data,
            "ipfs://retp-lab/kyc-claim"
        );
    }

    function testTransferRejectsUnverifiedRecipientAfterUnpause() public {
        identityRegistry.registerIdentity(address(this), IIdentity(address(0x1234)), 724);
        token.mint(address(this), 100);
        token.unpause();

        vm.expectRevert(bytes("Transfer not possible"));
        token.transfer(unverifiedInvestor, 1);
    }
}
