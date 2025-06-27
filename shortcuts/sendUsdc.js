const { ethers } = require("ethers");
const dotenv = require('dotenv');
dotenv.config();

const contractName = 'USDC';
const usdc = require(`../artifacts/contracts/tokens/${contractName}.sol/${contractName}.json`);

const sepoliaRpc = process.env.SEPOLIA;
const scroll = process.env.SCROLL;
const privateKey = process.env.PRIVATE_KEY;
const nftDepositAddress = process.env.NFT_DEPOSITOR;
const loanWithdrawAddress = process.env.LOAN_WITHDRAW;
const usdcSepoliaAddress = process.env.USDC_SEPOLIA;
const usdcScrollAddress = process.env.USDC_SCROLL
const usdcABI = usdc.abi;
const ownerAddress = process.env.OWNER_ADDRESS;

const execution = async () => {  
  const provider = new ethers.JsonRpcProvider(scroll);
  const wallet = new ethers.Wallet(privateKey, provider);
  const usdc = new ethers.Contract(usdcScrollAddress, usdcABI, wallet);

  const balance = await usdc.balanceOf(ownerAddress);
  console.log(balance)

  const amount = ethers.parseEther('100000');

  // const tx = await usdc.mint(ownerAddress, amount);
  

  const tx = await usdc.transfer(loanWithdrawAddress, balance)

  // const tx1 = await nft.approve(nftDepositAddress, tokenId);
  // await tx.wait();

  // const commitment = await poseidonHash([1, 2, 100]);

  // console.log('commitment', commitment);

  // const bytes32Commitment = toBytes32(commitment);

  // console.log('bytes32', bytes32Commitment);

  // const tx = await nftDepositor.depositNft(
  //   nftAddress,
  //   tokenId,
  //   receiverAddress,
  //   bytes32Commitment
  // );

  const receipt = await tx.wait();

  console.log('nftDeposit:', receipt);
};


execution().catch((error) => {
  console.error("Error contract:", error);
});

