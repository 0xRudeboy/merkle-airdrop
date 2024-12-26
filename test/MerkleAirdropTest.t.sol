// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;

    address public alice = makeAddr("alice");
    uint256 public testAmount = 1.5 ether;

    function setUp() public {}

    function test_randomTings() public view {
        // returns 2 different values

        //   0xac82d04fb847647e206ea4f7c6a46cce8a969070940d519504ab9c8eb58898eb
        bytes32 leafOne = keccak256(bytes.concat(keccak256(abi.encode(alice, testAmount))));

        //   0xbd304cc759dcf770209990fd85e001c3f48c31ca4935bc1c6e48713071e12e1a
        bytes32 leafTwo = keccak256(abi.encodePacked(alice, testAmount));

        console2.logBytes32(leafOne);
        console2.logBytes32(leafTwo);
    }
}
