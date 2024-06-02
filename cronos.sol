// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoralisMetaverseGame {
    // Game parameters
    uint256 public constant MAX_PLAYERS = 100;
    uint256 public constant GAME_ITEM_PRICE = 0.01 ether;
    uint256 public constant GAME_REWARD = 0.005 ether;

    // Player struct
    struct Player {
        address playerAddress;
        uint256 gameItemsOwned;
        uint256 rewardsEarned;
    }

    // Game state
    mapping(address => Player) public players;
    uint256 public playersCount;

    // Events
    event PlayerJoined(address playerAddress);
    event GameItemPurchased(address playerAddress, uint256 gameItemsOwned);
    event RewardClaimed(address playerAddress, uint256 rewardsEarned);

    // Join the game
    function joinGame() external payable {
        require(playersCount < MAX_PLAYERS, "Maximum number of players reached");
        require(msg.value >= GAME_ITEM_PRICE, "Insufficient funds to purchase game item");

        Player memory newPlayer = Player({
            playerAddress: msg.sender,
            gameItemsOwned: 1,
            rewardsEarned: 0
        });
        players[msg.sender] = newPlayer;
        playersCount++;

        emit PlayerJoined(msg.sender);
    }

    // Purchase game items
    function purchaseGameItems() external payable {
        require(players[msg.sender].playerAddress != address(0), "Player not registered");
        require(msg.value >= GAME_ITEM_PRICE, "Insufficient funds to purchase game item");

        players[msg.sender].gameItemsOwned++;

        emit GameItemPurchased(msg.sender, players[msg.sender].gameItemsOwned);
    }

    // Claim rewards
    function claimRewards() external {
        require(players[msg.sender].playerAddress != address(0), "Player not registered");
        require(players[msg.sender].rewardsEarned > 0, "No rewards to claim");

        uint256 rewardsToTransfer = players[msg.sender].rewardsEarned;
        players[msg.sender].rewardsEarned = 0;
        payable(msg.sender).transfer(rewardsToTransfer);

        emit RewardClaimed(msg.sender, rewardsToTransfer);
    }

    // Reward players (called by the game logic)
    function rewardPlayers(address[] memory playersToReward) external {
        for (uint256 i = 0; i < playersToReward.length; i++) {
            address playerAddress = playersToReward[i];
            require(players[playerAddress].playerAddress != address(0), "Player not registered");
            players[playerAddress].rewardsEarned += GAME_REWARD;
        }
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
