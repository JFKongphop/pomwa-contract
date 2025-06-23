// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./utils/ReentrancyGuard.sol";

contract NFTLocker is ReentrancyGuard {
  struct DepositInfo {
    address owner;
    uint256 unlockTime;
  }

  // nftAddress => tokenId => DepositInfo
  mapping(address => mapping(uint256 => DepositInfo)) public deposits;

  event Deposited(address indexed nft, uint256 indexed tokenId, address indexed depositor, uint256 unlockTime);
  event Withdrawn(address indexed nft, uint256 indexed tokenId, address indexed withdrawer);

  uint256 public constant LOCK_PERIOD = 7 days;

  function deposit(address nftAddress, uint256 tokenId) external nonReentrant {
    IERC721 nft = IERC721(nftAddress);

    require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
    require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Contract not approved");

    // Transfer NFT to this contract
    nft.transferFrom(msg.sender, address(this), tokenId);

    // Record deposit
    deposits[nftAddress][tokenId] = DepositInfo({
      owner: msg.sender,
      unlockTime: block.timestamp + LOCK_PERIOD
    });

    emit Deposited(nftAddress, tokenId, msg.sender, block.timestamp + LOCK_PERIOD);
  }

  function withdraw(address nftAddress, uint256 tokenId) external nonReentrant {
    DepositInfo memory info = deposits[nftAddress][tokenId];
    require(info.owner == msg.sender, "Not depositor");
    require(block.timestamp >= info.unlockTime, "NFT still locked");

    delete deposits[nftAddress][tokenId];

    // Transfer NFT back
    IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);

    emit Withdrawn(nftAddress, tokenId, msg.sender);
  }

  function getUnlockTime(address nftAddress, uint256 tokenId) external view returns (uint256) {
    return deposits[nftAddress][tokenId].unlockTime;
  }
}
