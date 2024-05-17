import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  enums: {
    BlockType: ["Standard", "Flash", "Action", "Trap", "Question"]
  },
  tables: {
    MapConfig: {
      schema: {
        width: "uint32",
        height: "uint32",
        terrain: "bytes",
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
        point: "int32",
      },
      key: ["id"],
      codegen: {
        dataStruct: false,
      },
    },
    Position: {
      schema: {
        id: "bytes32",
        x: "int32",
        y: "int32",
      },
      key: ["id"],
      codegen: {
        dataStruct: false,
      },
    },
  },
});
