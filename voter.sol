// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    address public owner;
    
    struct Candidate {
        string name;
        uint256 voteCount;
    }
    
    Candidate[] public candidates;
    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;

    event VoterRegistered(address indexed voter);
    event CandidateAdded(string indexed candidateName);
    event VoteCasted(address indexed voter, uint256 indexed candidateIndex);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function registerVoter(address _voter) public {
        require(!registeredVoters[_voter], "Address is already registered");
        registeredVoters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(_name);
    }

    function vote(uint256 _candidateIndex) public {
        require(registeredVoters[msg.sender], "Voter is not registered");
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");

        candidates[_candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
        emit VoteCasted(msg.sender, _candidateIndex);
    }

    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function getCandidate(uint256 _index) public view returns (string memory, uint256) {
        require(_index < candidates.length, "Invalid candidate index");
        return (candidates[_index].name, candidates[_index].voteCount);
    }

    function getWinner() public view returns (string memory winnerName, uint256 winningVoteCount) {
        require(candidates.length > 0, "No candidates available");

        winningVoteCount = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }
    }
}
