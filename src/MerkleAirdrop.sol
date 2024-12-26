// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BagelToken} from "./BagelToken.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    // some list of addresses
    // allow someone in the list to claim tokens
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    event Claim(address indexed account, uint256 amount);

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkelProof) external {
        // calculate using the account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // check if the leaf node is in the merkle root
        if (!MerkleProof.verify(merkelProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        emit Claim(account, amount);

        s_hasClaimed[account] = true;
        i_airdropToken.safeTransfer(account, amount);
    }
}
