const { ethers } = require("ethers");
const dotenv = require('dotenv');
const { toBytes32 } = require('./utils/bytesConverter')
const { poseidonHash } = require('./utils/poseidon');
dotenv.config();

const contractName = 'Deposit';
const data = require(`../artifacts/contracts/${contractName}.sol/${contractName}.json`);

const providerURL = process.env.SEPOLIA
const privateKey = process.env.PRIVATE_KEY;
const senderAddress = process.env.DEPOSIT
const receiverAddress = process.env.WITHDRAW
const contractABI = data.abi;

const execution = async () => {  
  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const contract = new ethers.Contract(senderAddress, contractABI, wallet);

  const commitment = await poseidonHash([2, 3, 900]);

  console.log('commitment', commitment);

  const bytes32Commitment = toBytes32(commitment);

  console.log('bytes32', bytes32Commitment);

  const tx = await contract.sendMessage(
    receiverAddress,
    bytes32Commitment
  );

  const receipt = await tx.wait();

  console.log('DATA:', receipt);
};

execution().catch((error) => {
  console.error("Error contract:", error);
});

