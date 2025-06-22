import { buildPoseidon } from "circomlibjs";

export const poseidonHash = async (inputs: number[] | bigint[]) => {
  const poseidon = await buildPoseidon();
  const F = poseidon.F;
  if (!Array.isArray(inputs)) inputs = [inputs];
  const bigints = inputs.map(BigInt);
  const res = poseidon(bigints);
  return BigInt(F.toString(res));
}