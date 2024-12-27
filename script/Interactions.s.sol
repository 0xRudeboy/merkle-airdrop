// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";

contract ClaimAirdrop is Script {
    error __ClaimAirdropScript_InvalidSignatureLength();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 ether;
    bytes32[] PROOF = [
        bytes32(0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];
    bytes private SIGNATURE =
        hex"6c576a2bcd6ec720be706c4a336ac69c3cfee293689bca8205e9ff240e2d69c50084e9509ae54535c86062b05a91e5da8bb22d517e7f72ba879823fd3f56c9361b";

    function claimAirdrop(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        bytes32 root = MerkleAirdrop(mostRecentlyDeployed).getMerkleRoot();
        console2.logBytes32(root);

        MerkleAirdrop(mostRecentlyDeployed).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) {
            revert __ClaimAirdropScript_InvalidSignatureLength();
        }
        // 65 bytes for ECDSA signature (32 bytes for r, 32 bytes for s, 1 byte for v)

        // when interacting with APIs/Protocols the usual format is v, r, s however the true position of the values is r, s, v hence why they are decoded as such below
        // Typically if you're using a function its going to be v, r, s
        // If however you're looking at a signature or breaking it up/packing it together its going to be r, s, v
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);

        claimAirdrop(mostRecentlyDeployed);
    }
}
