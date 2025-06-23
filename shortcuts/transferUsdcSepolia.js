const { ethers } = require('ethers');
const dotenv = require('dotenv');
dotenv.config();

const providerSepolia = process.env.SEPOLIA;
const privateKey = process.env.PRIVATE_KEY;
const usdcSepolia = process.env.USDC_SEPOLIA;
const nftDeposit = process.env.NFT_DEPOSITOR;

const ERC20_ABI = [
  "function mint(address to, uint256 amount) external",
  "function transfer(address to, uint256 amount) returns (bool)",
  "function balanceOf(address account) view returns (uint256)",
];

async function main() {
  const provider = new ethers.JsonRpcProvider(providerSepolia);
  const wallet = new ethers.Wallet(privateKey, provider);
  const erc20 = new ethers.Contract(
    usdcSepolia,
    ERC20_ABI,
    wallet
  );

  const tokenAmount = ethers.parseEther('1000000')

  const tx1 = await erc20.mint(wallet.address, tokenAmount);
  await tx1.wait();

  const balance = await erc20.balanceOf(wallet.address);
  console.log(`Balance after mint: ${ethers.formatUnits(balance, 18)}`);

  console.log(`Transferring ${tokenAmount} tokens to ${nftDeposit}`);
  const tx2 = await erc20.transfer(nftDeposit, tokenAmount);
  await tx2.wait();

  const recipientBalance = await erc20.balanceOf(nftDeposit);
  console.log(`Recipient balance: ${ethers.formatUnits(recipientBalance, 18)}`);
}

main().catch(console.error);
