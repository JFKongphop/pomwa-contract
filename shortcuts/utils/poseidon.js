const circomlibjs = require("circomlibjs");

const poseidonHash = async (inputs) => {
  const poseidon = await circomlibjs.buildPoseidon();
  const F = poseidon.F;

  if (!Array.isArray(inputs)) inputs = [inputs];
  
  const bigints = inputs.map(BigInt);
  const res = poseidon(bigints);
  return BigInt(F.toString(res));
};

module.exports = {
  poseidonHash
}