// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol";

contract PrivateVote {
    address public owner;
    euint32 private candidateACount;
    euint32 private candidateBCount;
    mapping(address => bool) public hasVoted;

    constructor() {
        owner = msg.sender;
        candidateACount = TFHE.asEuint32(0);
        candidateBCount = TFHE.asEuint32(0);
    }

    // Cast an encrypted vote (0 for Candidate A, 1 for Candidate B)
    function castVote(bytes calldata encryptedVote) public {
        require(!hasVoted[msg.sender], "Already voted");
        euint32 vote = TFHE.asEuint32(encryptedVote);
        euint32 isCandidateA = TFHE.eq(vote, TFHE.asEuint32(0));
        euint32 isCandidateB = TFHE.eq(vote, TFHE.asEuint32(1));

        candidateACount = TFHE.add(candidateACount, isCandidateA);
        candidateBCount = TFHE.add(candidateBCount, isCandidateB);
        hasVoted[msg.sender] = true;
    }

    // Get encrypted vote counts (only callable by owner)
    function getEncryptedTally() public view returns (bytes memory, bytes memory) {
        require(msg.sender == owner, "Only owner can view tally");
        return (TFHE.decrypt(candidateACount), TFHE.decrypt(candidateBCount));
    }

    // Get public vote counts (for demo purposes, assuming owner decrypts off-chain)
    function getVoteCount() public view returns (uint32, uint32) {
        require(msg.sender == owner, "Only owner can view tally");
        return (TFHE.decrypt(candidateACount), TFHE.decrypt(candidateBCount));
    }
}
