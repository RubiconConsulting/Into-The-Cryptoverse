// SPDX-License-Identifier: MIT
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
pragma solidity >=0.8.24;

import {
    Encounter,
    Encounterable,
    EncounterData,
    EncounterTrigger,
    Player,
    Position,
    Dice,
    MapConfig,
    EncountEvent
} from "../codegen/index.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {BlockType} from "../codegen/common.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";

//MapSystem is a system that manages the map
contract MapSystem is System {
    ////////////////
    //	Error  	 ///
    ////////////////
    error MapSystem_PlayerAlreadySpawned();

    ///////////////////////
    /// Function		///
    ///////////////////////

    ///////////////
    /// Public 	///
    ///////////////
    /**
     * the player spawn at the given position of the map
     * @param x x position
     * @param y y position
     */
    function spawn(uint32 x, uint32 y) public {
        //addrees as id for player
        uint32 width = MapConfig.getWidth();

        bytes32 player = addressToEntityKey(address(_msgSender()));
        if (Player.get(player) == true) {
            revert MapSystem_PlayerAlreadySpawned();
        }

        Player.set(player, true);
        Position.set(player, x, y, y * width + x);
        Encounterable.set(player, true);
    }

    /**
     * the player roll the dice
     */
    function diceRoll() public {
        bytes32 playerId = addressToEntityKey(address(_msgSender()));
        //get a random number from 1 to 6
        //just hardcode the dice roll to 1 for test, and next can get the number from Chainlink VRF
        //TODO - get the random number from Chainlink VRF
        Dice.set(playerId, 2);
    }

    /**
     * q
     * the player move following the dice point
     */
    function move() public {
        bytes32 playerId = addressToEntityKey(address(_msgSender()));
        require(!Encounter.getExists(playerId), "Player is in encounter");

        uint32 dicePoint = Dice.get(playerId);
        (,, uint32 position) = Position.get(playerId);
        //TODO - let the player move following a path
        position += uint32(dicePoint);
        uint32 width = MapConfig.getWidth();
        uint32 height = MapConfig.getWidth();

        uint32 positionY = position / width;
        uint32 positionX = position % width;
        bytes32 postionEntity = positionToEntityKey(positionX, positionY);

        Position.set(playerId, positionX, positionY, position);
        if (Encounterable.get(playerId) && EncounterTrigger.get(postionEntity)) {
            startEncounter(playerId);
        }
    }

    function startEncounter(bytes32 player) internal {
        bytes32 encountEvent = keccak256(abi.encode(player, blockhash(block.number - 1), block.prevrandao));
        BlockType blockType = BlockType((uint256(encountEvent) % uint256(type(BlockType).max)) + 1);
        EncountEvent.set(encountEvent, blockType);
        Encounter.set(player, EncounterData({exists: true, encountEvent: encountEvent, catchAttempts: 0}));
    }
}
