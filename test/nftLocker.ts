import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { NFTLocker, NFT, USDC } from 'typechain-types';

describe('NFTLocker', async () => {
  let user1: SignerWithAddress; 
  let user2: SignerWithAddress;
  let nft: NFT;
  let usdc: USDC;
  let locker: NFTLocker;
  const SECONDS_IN_A_WEEK = 604800; // 24 * 60 * 60 * 7

  before(async () => {
    [user1, user2] = await ethers.getSigners();

    const USDC = await ethers.getContractFactory('USDC');
    usdc = await USDC.deploy();

    const NFT = await ethers.getContractFactory('NFT');
    nft = await NFT.deploy();

    await nft.connect(user1).mint();
    await nft.connect(user2).mint();
    
    const Locker = await ethers.getContractFactory('NFTLocker');
    locker = await Locker.deploy(usdc);

    const allUsdc = await usdc.balanceOf(user1);
    await usdc.connect(user1).transfer(locker, allUsdc);
  });

  describe('Deposit', async () => {
    it('Should deposit nft and gain 100 usdc from user1', async () => {
      const user1TokenId = 0;
      await nft.connect(user1).approve(locker, user1TokenId);
      await locker.connect(user1).deposit(nft, user1TokenId);

      const nftLockerBalance = await nft.balanceOf(locker);
      const usdcUser1Balance = await usdc.balanceOf(user1)
      const rewardAmount = await locker.REWARD_AMOUNT();

      
      const now = Math.floor(Date.now() / 1000);
      const nextWeek = now + SECONDS_IN_A_WEEK;

      const depositInfo = await locker.depositsInfo(nft, user1TokenId);
      const [owner, endDay, withdrawn] = depositInfo;

      expect(nftLockerBalance).equal(1n);
      expect(usdcUser1Balance).equal(rewardAmount);
      expect(user1).equal(owner);
      expect(endDay).closeTo(BigInt(nextWeek), 5);
      expect(withdrawn).false;
    });

    it('Should deposit nft and gain 100 usdc from user2', async () => {
      const user1TokenId = 1;
      await nft.connect(user2).approve(locker, user1TokenId);
      await locker.connect(user2).deposit(nft, user1TokenId);

      const nftLockerBalance = await nft.balanceOf(locker);
      const usdcUser1Balance = await usdc.balanceOf(user2)

      const rewardAmount = await locker.REWARD_AMOUNT();

      const now = Math.floor(Date.now() / 1000);
      const nextWeek = now + SECONDS_IN_A_WEEK;

      const depositInfo = await locker.depositsInfo(nft, user1TokenId);
      const [owner, endDay, withdrawn] = depositInfo;

      expect(nftLockerBalance).equal(2n);
      expect(usdcUser1Balance).equal(rewardAmount);
      expect(user2).equal(owner);
      expect(endDay).closeTo(BigInt(nextWeek), 5);
      expect(withdrawn).false;
    });
  });

  describe('Withdraw', async () => {
    it('Should return ')
  });
})
