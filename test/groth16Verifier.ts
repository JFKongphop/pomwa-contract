import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { Groth16Verifier } from '../typechain-types';
import { createMerkleTree } from './utils/merkleTree';
import { buildPoseidon, Poseidon } from 'circomlibjs';
import { generateProof } from './utils/circuit';

describe('Contract', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let contract: Groth16Verifier;
  let F: any;
  let poseidon: Poseidon;

  const TREE_LEVELS = 2;

  before(async () => {
    [user1, user2] = await ethers.getSigners();
    
    const Contract = await ethers.getContractFactory('Groth16Verifier');
    contract = await Contract.deploy();

    poseidon = await buildPoseidon();
    F = poseidon.F;
  });

  const poseidonHash = (inputs: number[] | bigint[]) => {
    if (!Array.isArray(inputs)) inputs = [inputs];
    const bigints = inputs.map(BigInt);
    const res = poseidon(bigints);
    return BigInt(F.toString(res));
  }

  describe('VerifyProof', async () => {
    it('Should return true', async () => {
      const rawLeaves = [0, 0, 0, 0];
      const leaves = rawLeaves.map((x: any) => poseidonHash(x));

      const proofData: any = [
        [1, 2, 900],
        [2, 3, 900],
        [3, 4, 900],
        [4, 5, 900],
      ];

      for (let i = 0; i < proofData.length; i++) {
        const data: any = proofData[i];
        const commitment: any = poseidonHash(data);
        leaves[i] = commitment;

        const tree = createMerkleTree(TREE_LEVELS, leaves, poseidonHash);
        const { pathElements, pathIndices, pathRoot } = tree.proof(commitment); 
        
        const [firstSecret, secondSecret, loanAmount] = data
        const input = {
          root: pathRoot.toString(),
          nullifier: commitment.toString(),
          secret: [firstSecret, secondSecret].map((x) => x.toString()),
          loanAmount: loanAmount.toString(),
          pathElements: pathElements.map((x) => x.toString()),    
          pathIndices: pathIndices.map((x) => x.toString())
        };

        const [a, b, c] = await generateProof(input);

        const valid = await contract.verifyProof(a, b, c);

        expect(valid).true;
      }
    });
  })
})
