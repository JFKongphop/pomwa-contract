import hre, { ethers } from 'hardhat';
import dotenv from 'dotenv';
dotenv.config();

const name = 'Withdraw';
const chainlinkRouter = '0x6aF501292f2A33C81B9156203C9A66Ba0d8E3D21';
const hasher = process.env.HASHER!;

const deploy = async () => {
  const Contract = await ethers.getContractFactory('Withdraw');
  const contract = await Contract.deploy(
    chainlinkRouter,
    hasher,
    2
  );

  await contract.deploymentTransaction()?.wait(3);

  const contractAddress = await contract.getAddress();

  console.log(`${name} ADDRESS:`, contractAddress);

  try {
    await hre.run('verify:verify', {
      address: contractAddress,
      contract: `contracts/${name}.sol:${name}`,
      constructorArguments: [
        chainlinkRouter,
        hasher,
        2
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