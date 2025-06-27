import hre, { ethers } from 'hardhat';
import dotenv from 'dotenv';
dotenv.config();

const chainlinkRouter = '0x6aF501292f2A33C81B9156203C9A66Ba0d8E3D21';
const verifier = process.env.VERIFIER!;
const usdc = process.env.USDC_SCROLL!;
const hasher = process.env.HASHER!;
const TREE_LEVELS = 2;

const name = 'LoanWithdrawer';

const deploy = async () => {
  const Contract = await ethers.getContractFactory(name);
  const contract = await Contract.deploy(
    verifier,
    usdc,
    chainlinkRouter, 
    hasher,
    TREE_LEVELS
  );

  await contract.deploymentTransaction()?.wait(3);

  const contractAddress = await contract.getAddress();

  console.log(`${name} ADDRESS:`, contractAddress);

  try {
    await hre.run('verify:verify', {
      address: contractAddress,
      contract: `contracts/${name}.sol:${name}`,
      constructorArguments: [
        verifier,
        usdc,
        chainlinkRouter, 
        hasher,
        TREE_LEVELS
      ],
    });
  }
  catch (e) {
    console.log("ERROR", e);
  }
}

deploy().catch((err) => {
  console.log(err);
  process.exitCode = 1;
})