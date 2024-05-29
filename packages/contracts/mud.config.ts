import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  enums: {
    BlockType: ["Standard", "Flash", "Action", "Trap", "Question"],
    MonsterCatchResult: ["Missed", "Caught", "Fled"],
  },
  tables: {
    Encounter: {
      schema: {
        player: "bytes32",
        exists: "bool",
        encountEvent: "bytes32",
        catchAttempts: "uint256",
      },
      key: ["player"],
    },
    EncounterTrigger: "bool",
    Encounterable: "bool",
    MonsterCatchAttempt: {
      type: "offchainTable",
      schema: {
        encounter: "bytes32",
        result: "MonsterCatchResult",
      },
      key: ["encounter"],
      codegen: {
        dataStruct: false,
      },
    },
    OwnedBy: "bytes32",
    EncountEvent: "BlockType",
    MapConfig: {
      schema: {
        width: "uint32",
        height: "uint32",
        terrain: "bytes",
        pathIndex: "bytes",
      },
      key: [],
      codegen: {
        dataStruct: false,
      },
    },
    Movable: "bool",
    Player: "bool",
    Dice: {
      schema: {
        id: "bytes32",
        point: "uint32",
      },
      key: ["id"],
      codegen: {
        dataStruct: false,
      },
    },
    Position: {
      schema: {
        id: "bytes32",
        x: "uint32",
        y: "uint32",
        positon:"uint32",
      },
      key: ["id"],
      codegen: {
        dataStruct: false,
      },
    },
  },
});
