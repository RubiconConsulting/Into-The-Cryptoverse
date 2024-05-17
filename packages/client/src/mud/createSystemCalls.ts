/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */

import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { playerEntity,worldContract, waitForTransaction }: SetupNetworkResult,
  { Player , Position}: ClientComponents,

) {
  const move = async () => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const position = getComponentValue(Position, playerEntity);
    if (!position) {
      console.warn("cannot move without a player position, not yet spawned?");
      return;
    }

    const tx = await worldContract.write.move();
    await waitForTransaction(tx);
  };
  const spawn = async (x: number, y: number) => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const canSpawn = getComponentValue(Player, playerEntity)?.value !== true;
    if (!canSpawn) {
      throw new Error("already spawned");
    }

    const tx = await worldContract.write.spawn([x, y]);
    await waitForTransaction(tx);
  };

  const rollDice = async () => {
    // TODO
    const tx = await worldContract.write.diceRoll();
    await waitForTransaction(tx);
    move();
  };

  return {
    rollDice,
    spawn,
  };
}
