import { useComponentValue } from "@latticexyz/react";
import { GameMap } from "./GameMap";
import { useMUD } from "./MUDContext";
import { hexToArray } from "@latticexyz/utils";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { TerrainType, terrainTypes } from "./terrainTypes";
import { Entity } from "@latticexyz/recs";
import { EncounterScreen } from "./EncounterScreen";
import { MonsterType, monsterTypes } from "./monsterTypes";

export const GameBoard = () => {
  const {
    components: { MapConfig,Player, Position, Encounter,  EncountEvent },
    network: { playerEntity },
    systemCalls: { spawn, rollDice },
  } = useMUD();
  //get the Player component and Position component from the MUD context
  const canSpawn = useComponentValue(Player, playerEntity)?.value !== true;

  const playerPosition = useComponentValue(Position, playerEntity);
  const player =
    playerEntity && playerPosition
      ? {
        x: playerPosition.x,
        y: playerPosition.y,
        emoji: "🤠",
        entity: playerEntity,
      }  
      : null;

      const mapConfig = useComponentValue(MapConfig, singletonEntity);
  if (mapConfig == null) {
    throw new Error("map config not set or not ready, only use this hook after loading state === LIVE");
  }

  const { width, height, terrain: terrainData } = mapConfig;
  const terrain = Array.from(hexToArray(terrainData)).map((value, index) => {
    const { emoji } = value in TerrainType ? terrainTypes[value as TerrainType] : { emoji: "" };
    return {
      x: index % width,
      y: Math.floor(index / width),
      emoji,
    };
  });

  const encounter = useComponentValue(Encounter, playerEntity);
  const monsterType = useComponentValue(EncountEvent, encounter ? (encounter.encountEvent as Entity) : undefined)?.value;
  const monster = monsterType != null && monsterType in MonsterType ? monsterTypes[monsterType as MonsterType] : null;

  //spawn the player at the starting position
  canSpawn ? spawn(0,0) : undefined;
  return <GameMap width={width} height={height} terrain={terrain} onTileClick={ rollDice}  players={player ? [player] : []} 
  encounter={
    encounter ? (
      <EncounterScreen monsterName={monster?.name ?? "MissingNo"} monsterEmoji={monster?.emoji ?? "💱"} />
    ) : undefined
  }/>;
};