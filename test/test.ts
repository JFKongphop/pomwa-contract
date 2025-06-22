import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
// import { } from '../typechain-types';

describe('Contract', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let contract: any;


  before(async () => {
    [user1, user2] = await ethers.getSigners();
    
    const Contract = await ethers.getContractFactory('');
    contract = await Contract.deploy();
  });

  describe('Function', async () => {
    it('Should return', async () => {

    });
  })
})
