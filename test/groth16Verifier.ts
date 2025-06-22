import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { Groth16Verifier } from '../typechain-types';

describe('Contract', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let contract: Groth16Verifier;

  before(async () => {
    [user1, user2] = await ethers.getSigners();
    
    const Contract = await ethers.getContractFactory('Groth16Verifier');
    contract = await Contract.deploy();
  });

  describe('verify', async () => {
    it('Should return true', async () => {
      

    });
  })
})
