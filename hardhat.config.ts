import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter"
import dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      outputSelection: {
        "*": {
          "*": ["storageLayout"],
        },
      },
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  gasReporter: {
    enabled: false,
  },
  networks: {
    hardhat: {
      allowBlocksWithSameTimestamp: true,
    },
    mainnet: {
      url: process.env.MAINNET! || "",
      accounts: [process.env.PRIVATE_KEY!]
    },
    holesky: {
      url: process.env.HOLESKY! || "",
      accounts: [process.env.PRIVATE_KEY!]
    },
    sepolia: {
      url: process.env.SEPOLIA! || "",
      accounts: [process.env.PRIVATE_KEY!]
    },
    scroll: {
      url: process.env.SCROLL! || "",
      accounts: [process.env.PRIVATE_KEY!]
    }
  },
  etherscan: {
    apiKey: process.env.S! || "",
    customChains: [
      {
        network: "scroll",
        chainId: 534351,
        urls: {
          apiURL: "https://api-sepolia.scrollscan.com/api",
          browserURL: "https://sepolia.scrollscan.com"
        }
      },
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io"
        }
      },
    ]
  }
};

export default config;
