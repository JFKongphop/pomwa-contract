import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { Hasher } from '../typechain-types';
import { buildPoseidon, Poseidon } from 'circomlibjs';

describe('Contract', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let contract: Hasher;
  let F: any;
  let poseidon: Poseidon;


  before(async () => {
    [user1, user2] = await ethers.getSigners();
    
    const Contract = await ethers.getContractFactory('Hasher');
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

  describe('Poseidon', async () => {
    it('Should return true', async () => {
      const proofData: any = [
        [1, 2],
        [2, 3],
        [3, 4],
        [4, 5],
      ];

      for (let i = 0; i < proofData.length; i++) {
        const data = proofData[i];
        const contractHash = await contract.poseidon(data);
        const libHash = poseidonHash(data);

        expect(contractHash).equal(libHash)
      }
    });
  })
})
