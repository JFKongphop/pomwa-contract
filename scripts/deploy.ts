import hre, { ethers } from 'hardhat';

const name = '';

const deploy = async () => {
  const Contract = await ethers.getContractFactory(name);
  const contract = await Contract.deploy();

  await contract.deploymentTransaction()?.wait(3);

  const contractAddress = await contract.getAddress();

  console.log(`${name} ADDRESS:`, contractAddress);

  try {
    await hre.run('verify:verify', {
      address: contractAddress,
      contract: `contracts/${name}.sol:${name}`,
      constructorArguments: [],
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