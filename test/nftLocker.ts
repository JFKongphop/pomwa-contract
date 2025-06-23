import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { NFTLocker } from 'typechain-types';

describe('Contract', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let locker: NFTLocker;

  before(async () => {
    [user1, user2] = await ethers.getSigners();

    const USDC = await ethers.getContractFactory('USDC');
    const usdc = await USDC.deploy();

    const NFT = await ethers.getContractFactory('NFT');
    const nft = await NFT.deploy();

    await nft.connect(user1).mint();
    
    const Locker = await ethers.getContractFactory('NFTLocker');
    locker = await Locker.deploy(usdc);

    const allUsdc = await usdc.balanceOf(user1);
    await usdc.connect(user1).transfer(locker, allUsdc);
  });


  describe('Poseidon', async () => {
    
  });
})
