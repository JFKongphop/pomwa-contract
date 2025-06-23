const { ethers } = require('ethers');
const dotenv = require('dotenv');
dotenv.config();

const providerScroll = process.env.SCROLL;
const privateKey = process.env.PRIVATE_KEY;
const usdcScroll = process.env.USDC_SCROLL;
const loanWithdrawer = process.env.LOAN_WITHDRAW;

const ERC20_ABI = [
  "function mint(address to, uint256 amount) external",
  "function transfer(address to, uint256 amount) returns (bool)",
  "function balanceOf(address account) view returns (uint256)",
];

async function main() {
  const provider = new ethers.JsonRpcProvider(providerScroll);
  const wallet = new ethers.Wallet(privateKey, provider);
  const erc20 = new ethers.Contract(
    usdcScroll,
    ERC20_ABI,
    wallet
  );

  const tokenAmount = ethers.parseEther('1000000')

  const tx1 = await erc20.mint(wallet.address, tokenAmount);
  await tx1.wait();

  const balance = await erc20.balanceOf(wallet.address);
  console.log(`Balance after mint: ${ethers.formatUnits(balance, 18)}`);

  console.log(`Transferring ${tokenAmount} tokens to ${loanWithdrawer}`);
  const tx2 = await erc20.transfer(loanWithdrawer, tokenAmount);
  await tx2.wait();

  const recipientBalance = await erc20.balanceOf(loanWithdrawer);
  console.log(`Recipient balance: ${ethers.formatUnits(recipientBalance, 18)}`);
}

main().catch(console.error);
