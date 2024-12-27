// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    DeployMerkleAirdrop public deployer;

    bytes32 public root = 0xd32c1d219a66007bb48635faf9c633c9782ce758245314bae61b6500f39220be;

    address user;
    uint256 userPrivKey;

    address public gasPayer;
    uint256 public gasPayerPrivKey;

    address public alice;
    uint256 public alicePrivKey;

    address public bob;
    uint256 public bobPrivKey;

    uint256 public testAmount = 1.5 ether;
    uint256 AMOUNT_TO_CLAIM = 25e18;
    uint256 AMOUNT_TO_SEND = 4 * AMOUNT_TO_CLAIM;

    bytes32 proofOne = 0xbaa072cd3aa185139d07facad6010bee6a3195bdf0bcaf20d16b94883a4b09a2;
    bytes32 proofTwo = 0xd87b1392cbd4e0c97beed9cb0a42176fe7803404c0be43f39363033c1e89ac62;

    bytes32[] PROOF = [proofOne, proofTwo];

    function setUp() public {
        if (!isZkSyncChain()) {
            deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(root, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }

        (user, userPrivKey) = makeAddrAndKey("user");
        (alice, alicePrivKey) = makeAddrAndKey("alice");
        (bob, bobPrivKey) = makeAddrAndKey("bob");
        (gasPayer, gasPayerPrivKey) = makeAddrAndKey("gasPayer");
    }

    function test_usersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);

        console2.log("startingBalance", startingBalance);
        console2.log("endingBalance", endingBalance);
    }

    function test_randomTings() public view {
        // returns 2 different values

        //   0xac82d04fb847647e206ea4f7c6a46cce8a969070940d519504ab9c8eb58898eb
        bytes32 leafOne = keccak256(bytes.concat(keccak256(abi.encode(alice, testAmount))));

        //   0xbd304cc759dcf770209990fd85e001c3f48c31ca4935bc1c6e48713071e12e1a
        bytes32 leafTwo = keccak256(abi.encodePacked(alice, testAmount));

        console2.logBytes32(leafOne);
        console2.logBytes32(leafTwo);
    }

    function test_viewAddressesInConsole() public view {
        console2.log("user", user);
        console2.log("alice", alice);
        console2.log("bob", bob);
    }
}
