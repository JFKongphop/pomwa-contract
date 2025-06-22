const { ethers } = require('ethers');
const dotenv = require('dotenv');
dotenv.config();

const providerURL = process.env.SEPOLIA
const privateKey = process.env.PRIVATE_KEY;
const depositAddress = process.env.DEPOSIT;

const execution = async () => {  
  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const link = new ethers.Contract(
    '0x779877A7B0D9E8603169DdbD7836e478b4624789',
    [
      'function approve(address spender, uint256 amount) public returns (bool)',
      'function allowance(address owner, address spender) public view returns (uint256)',
      'function balanceOf(address account) public view returns (uint256)',
      'function transfer(address to, uint256 amount) public returns (bool)',
    ],
    wallet
  );

  const tx = await link.transferAndCall(depositAddress, ethers.parseEther('1'), '0x');

  const receipt = await tx.wait();

  console.log('DATA:', receipt);
};

execution().catch((error) => {
  console.error('Error contract:', error);
});

