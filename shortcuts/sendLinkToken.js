const { ethers } = require('ethers');
const dotenv = require('dotenv');
dotenv.config();

const providerURL = process.env.SEPOLIA
const privateKey = process.env.PRIVATE_KEY;
const depositAddress = process.env.NFT_DEPOSITOR;
const linkAbi = [
  {
    constant: false,
    inputs: [
      { name: "_to", type: "address" },
      { name: "_value", type: "uint256" },
      { name: "_data", type: "bytes" }
    ],
    name: "transferAndCall",
    outputs: [{ name: "success", type: "bool" }],
    type: "function"
  }
];

const execution = async () => {  
  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const link = new ethers.Contract(
    '0x779877A7B0D9E8603169DdbD7836e478b4624789',
    linkAbi,
    wallet
  );
  
  const tx = await link.transferAndCall(depositAddress, ethers.parseEther('1'), '0x');

  const receipt = await tx.wait();

  console.log('DATA:', receipt);
};

execution().catch((error) => {
  console.error('Error contract:', error);
});

