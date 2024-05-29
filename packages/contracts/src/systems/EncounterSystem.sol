// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {System} from "@latticexyz/world/src/System.sol";
import {Player, Encounter, EncounterData, MonsterCatchAttempt, OwnedBy, EncountEvent} from "../codegen/index.sol";
import {MonsterCatchResult} from "../codegen/common.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";

contract EncounterSystem is System {
    function throwBall() public {
        bytes32 player = addressToEntityKey(_msgSender());

        EncounterData memory encounter = Encounter.get(player);
        require(encounter.exists, "not in encounter");

        uint256 rand = uint256(
            keccak256(
                abi.encode(
                    player,
                    encounter.encountEvent,
                    encounter.catchAttempts,
                    blockhash(block.number - 1),
                    block.prevrandao
                )
            )
        );
        if (rand % 2 == 0) {
            // 50% chance to catch monster
            MonsterCatchAttempt.set(player, MonsterCatchResult.Caught);
            OwnedBy.set(encounter.encountEvent, player);
            Encounter.deleteRecord(player);
        } else if (encounter.catchAttempts >= 2) {
            // Missed 2 times, monster escapes
            MonsterCatchAttempt.set(player, MonsterCatchResult.Fled);
            EncountEvent.deleteRecord(encounter.encountEvent);
            Encounter.deleteRecord(player);
        } else {
            // Throw missed!
            MonsterCatchAttempt.set(player, MonsterCatchResult.Missed);
            Encounter.setCatchAttempts(player, encounter.catchAttempts + 1);
        }
    }

    function flee() public {
        bytes32 player = addressToEntityKey(_msgSender());

        EncounterData memory encounter = Encounter.get(player);
        require(encounter.exists, "not in encounter");

        EncountEvent.deleteRecord(encounter.encountEvent);
        Encounter.deleteRecord(player);
    }
}
