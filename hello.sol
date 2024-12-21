// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollaborativeChallenges {
    
    struct Challenge {
        string name;
        uint256 reward;
        address creator;
        address[] participants;
        bool isCompleted;
    }

    mapping(uint256 => Challenge) public challenges;
    uint256 public challengeCount;

    mapping(address => uint256) public balances;

    event ChallengeCreated(uint256 indexed challengeId, string name, uint256 reward);
    event ChallengeCompleted(uint256 indexed challengeId);
    event RewardDistributed(uint256 indexed challengeId, address indexed participant, uint256 amount);

    function createChallenge(string memory name, uint256 reward) external payable {
        require(msg.value == reward, "Insufficient reward sent.");

        Challenge storage newChallenge = challenges[challengeCount++];
        newChallenge.name = name;
        newChallenge.reward = reward;
        newChallenge.creator = msg.sender;
        newChallenge.isCompleted = false;

        emit ChallengeCreated(challengeCount - 1, name, reward);
    }

    function joinChallenge(uint256 challengeId) external {
        require(challengeId < challengeCount, "Invalid challenge ID.");
        require(!challenges[challengeId].isCompleted, "Challenge already completed.");

        Challenge storage challenge = challenges[challengeId];
        challenge.participants.push(msg.sender);
    }

    function completeChallenge(uint256 challengeId) external {
        require(challengeId < challengeCount, "Invalid challenge ID.");
        Challenge storage challenge = challenges[challengeId];
        require(msg.sender == challenge.creator, "Only the creator can mark the challenge as completed.");
        require(!challenge.isCompleted, "Challenge already completed.");
        require(challenge.participants.length > 0, "No participants in the challenge.");

        challenge.isCompleted = true;

        uint256 rewardPerParticipant = challenge.reward / challenge.participants.length;
        for (uint256 i = 0; i < challenge.participants.length; i++) {
            balances[challenge.participants[i]] += rewardPerParticipant;
            emit RewardDistributed(challengeId, challenge.participants[i], rewardPerParticipant);
        }

        emit ChallengeCompleted(challengeId);
    }

    function withdrawRewards() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No rewards to withdraw.");
        
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
