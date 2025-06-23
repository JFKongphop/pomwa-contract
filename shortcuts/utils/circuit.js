const { groth16 } = require('snarkjs')

const generateProof = async (input) => {
  const { proof, publicSignals } = await groth16.fullProve(
    input,
    'proof-source/withdraw.wasm',
    'proof-source/withdraw.zkey'
  );

  const calldata = await groth16.exportSolidityCallData(proof, publicSignals);
  const parsed = JSON.parse(`[${calldata}]`);

  return parsed;
}

module.exports = { generateProof };