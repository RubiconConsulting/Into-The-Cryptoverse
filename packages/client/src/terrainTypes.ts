// "Standard", "Flash", "Action", "Trap", "Question"
export enum TerrainType {
  Flash =1,
  Action =2,
  Trap =3,
  Question =4,
}

type TerrainConfig = {
  emoji: string;
};

export const terrainTypes: Record<TerrainType, TerrainConfig> = {
  [TerrainType.Flash]: {
    emoji: "📒",
  },
  [TerrainType.Action]: {
    emoji: "📘",
  },
  [TerrainType.Trap]: {
    emoji: "📕",
  },
  [TerrainType.Question]: {
    emoji: "📖",
  },
};
