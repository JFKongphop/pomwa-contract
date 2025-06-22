import * as path from 'path';
import * as fs from 'fs';
import { groth16, Groth16Proof, PublicSignals } from 'snarkjs';

const outPath = path.join(__dirname, '..', '..');
const vkeyPath = path.join(outPath, 'proof-source/verification_key.json');


export type Input = {
  root: string;
  nullifier: string;
  secret: string[];
  pathElements: string[];
  pathIndices: string[]
}

export type OutPut = {
  proof: Groth16Proof, 
  publicSignals: PublicSignals
}

// export const generateProof = async (input: Input): Promise<OutPut> => {
//   const { 
//     proof, 
//     publicSignals 
//   } = await groth16.fullProve(input, wasmPath, zkeyPath);

//   return { proof, publicSignals }; 
// }

export const generateProof = async (input: Input) => {
  const { proof, publicSignals } = await groth16.fullProve(
    input,
    'proof-source/withdraw_js/withdraw.wasm',
    'proof-source/withdraw.zkey'
  );

  const calldata = await groth16.exportSolidityCallData(proof, publicSignals);
  const parsed = JSON.parse(`[${calldata}]`);

  // const checkProof = await verifyProof(proof);
  //console.log('Proof', checkProof)

  // console.log(parsed)

  return parsed;
}

export const verifyProof = async (proof: Groth16Proof) => {
  const vkey = JSON.parse(fs.readFileSync(vkeyPath, 'utf-8'));
  return await groth16.verify(vkey, [], proof);
}