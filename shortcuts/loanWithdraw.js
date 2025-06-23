const path = require('path');
const { ethers } = require('ethers');
const dotenv = require('dotenv');
const { generateProof } = require('./utils/circuit');
const { toBytes32, bytes32ToBigInt } = require('./utils/bytesConverter')
const circomlibjs = require('circomlibjs');

const { MerkleTree } = require('fixed-merkle-tree');
dotenv.config();

const contractName = 'LoanWithdrawer';
const loanWithdrawer = require(`../artifacts/contracts/${contractName}.sol/${contractName}.json`);
const outPath = path.join(__dirname, '..');
const TREE_LEVELS = 2;

const providerURL = process.env.SCROLL
const privateKey = process.env.PRIVATE_KEY;
const loanWithdrawAddress = process.env.LOAN_WITHDRAW
const loanWithdrawABI = loanWithdrawer.abi;

const execution = async () => {  
  const poseidon = await circomlibjs.buildPoseidon();
  const F = poseidon.F;

  const poseidonHash = (inputs) => {
    if (!Array.isArray(inputs)) inputs = [inputs];
    const bigints = inputs.map(BigInt);
    const res = poseidon(bigints);
    return BigInt(F.toString(res));
  };

  const provider = new ethers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const contract = new ethers.Contract(loanWithdrawAddress, loanWithdrawABI, wallet);

  const events = await contract.queryFilter(
    'LeafCommitment', 
    10604124,
    'latest'
  );

  const { args } = events[0];
  const [leafCommitment, leafIndex] = args;
  
  console.log(args)

  const nullifier = 1;
  const secret = 2;
  const loanAmount = 100;
  // const commitment = poseidonHash([nullifier, secret, loanAmount]);
  const commitment = bytes32ToBigInt(leafCommitment);

  const leaves = [
    19014214495641488759237505126948346942972912379615652741039992445865937985820n,
    19014214495641488759237505126948346942972912379615652741039992445865937985820n,
    19014214495641488759237505126948346942972912379615652741039992445865937985820n,
    19014214495641488759237505126948346942972912379615652741039992445865937985820n
  ]
  leaves[Number(leafIndex)] = commitment;
  
  const tree = new MerkleTree(TREE_LEVELS, leaves, {
    hashFunction: (a, b) => poseidonHash([a, b]),
    zeroElement: 0n
  });
  
  const { pathElements, pathIndices, pathRoot } = tree.proof(commitment);
  
  const input = {
    root: pathRoot.toString(),
    nullifier: commitment.toString(),
    secret: [nullifier, secret].map((x) => x.toString()),
    loanAmount: loanAmount.toString(),
    pathElements: pathElements.map((x) => x.toString()),    
    pathIndices: pathIndices.map((x) => x.toString())
  };  

  const parsed = await generateProof(input)
  
  const [a, b, c, publicOutput] = parsed;
  
  const rootBytes32 = toBytes32(pathRoot);

  console.log(rootBytes32)

  const tx = await contract.loanWithdraw(
    leafCommitment,
    rootBytes32,
    a, 
    b, 
    c,
    publicOutput
  );

  const receipt = await tx.wait();

  console.log('nftDeposit:', receipt);
};


execution().catch((error) => {
  console.error('Error contract:', error);
});

