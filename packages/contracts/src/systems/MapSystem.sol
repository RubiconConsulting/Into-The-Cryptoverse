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

import {Player, Position, Dice} from "../codegen/index.sol";
import {System} from "@latticexyz/world/src/System.sol";

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
    function spawn(int32 x, int32 y) public {
        //addrees as id for player
        bytes32 player = addressToEntityKey(address(_msgSender()));
        if (Player.get(player) == true) {
            revert MapSystem_PlayerAlreadySpawned();
        }

        Player.set(player, true);
        Position.set(player, x, y);
    }

    function diceRoll() public {
        bytes32 playerId = addressToEntityKey(address(_msgSender()));
        //get a random number from 1 to 6
        //just mock the dice roll for test, and next can get the number from Chainlink VRF
        //TODO - get the random number from Chainlink VRF
        Dice.set(playerId, 1);
    }

    function move() public {
        bytes32 playerId = addressToEntityKey(address(_msgSender()));

        int32 dicePoint = Dice.get(playerId);
        (int32 x, int32 y) = Position.get(playerId);
        //TODO - let the player move following a path
        x += dicePoint;
        y = y;
        Position.set(playerId, x, y);
    }

    /**
     * transfer the address to entity key
     * @param addr address
     */
    function addressToEntityKey(address addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
