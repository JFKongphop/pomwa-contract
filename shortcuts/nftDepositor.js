const { ethers } = require("ethers");
const dotenv = require('dotenv');
const { toBytes32 } = require('./utils/bytesConverter')
const { poseidonHash } = require('./utils/poseidon');
dotenv.config();

const contractName = 'NFTDepositor';
const nftDeposit = require(`../artifacts/contracts/${contractName}.sol/${contractName}.json`);
const nft = require('../artifacts/contracts/tokens/NFT.sol/NFT.json');

const providerURL = process.env.SEPOLIA
const privateKey = process.env.PRIVATE_KEY;
const nftDepositAddress = process.env.NFT_DEPOSITOR
const receiverAddress = process.env.LOAN_WITHDRAW
const nftAddress = process.env.NFT;
const nftDepositABI = nftDeposit.abi;
const nftABI = nft.abi;

const execution = async () => {  
  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const nftDepositor = new ethers.Contract(nftDepositAddress, nftDepositABI, wallet);
  const nft = new ethers.Contract(nftAddress, nftABI, wallet);

  const tokenId = 1;

  // const tx1 = await nft.approve(nftDepositAddress, tokenId);
  // await tx1.wait();

  const commitment = await poseidonHash([1, 2, 100]);

  console.log('commitment', commitment);

  const bytes32Commitment = toBytes32(commitment);

  console.log('bytes32', bytes32Commitment);

  const tx = await nftDepositor.depositNft(
    nftAddress,
    tokenId,
    receiverAddress,
    bytes32Commitment
  );

  const receipt = await tx.wait();

  console.log('nftDeposit:', receipt);
};


execution().catch((error) => {
  console.error("Error contract:", error);
});

