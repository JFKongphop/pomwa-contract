import hre, { ethers } from 'hardhat';
import dotenv from 'dotenv';
dotenv.config();

const chainlinkRouter = '0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59';
const chainlinkToken = '0x779877A7B0D9E8603169DdbD7836e478b4624789';
const usdc = process.env.USDC_SEPLIA!;

const name = 'NFTDepositor';

const deploy = async () => {
  const Contract = await ethers.getContractFactory(name);
  const contract = await Contract.deploy(
    chainlinkRouter,
    chainlinkToken,
    usdc
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
        chainlinkToken,
        usdc
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