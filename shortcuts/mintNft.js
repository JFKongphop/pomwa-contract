const { ethers } = require('ethers');
const dotenv = require('dotenv');
dotenv.config();

const providerURL = process.env.SEPOLIA
const privateKey = process.env.PRIVATE_KEY;
const nftAddress = process.env.NFT;

const NFT_ABI = [
  "function mint() external",
  "function ownerOf(uint256 tokenId) view returns (address)",
];

async function main() {
  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const nft = new ethers.Contract(nftAddress, NFT_ABI, wallet);

  console.log("Minting NFT...");
  const tx = await nft.mint();
  const receipt = await tx.wait();

  console.log("NFT minted in tx:", receipt.hash);

  // Optional: check ownership of tokenId 0 (if it's the first one)
  try {
    const owner = await nft.ownerOf(0);
    console.log("Owner of token 0:", owner);
  } catch (err) {
    console.warn("ownerOf(0) call failed (maybe not minted yet or wrong ID)");
  }
}

main().catch(console.error);