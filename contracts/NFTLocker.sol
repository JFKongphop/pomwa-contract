// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/ReentrancyGuard.sol";

contract NFTLocker is ReentrancyGuard {
  struct DepositInfo {
    address owner;
    uint256 unlockTime;
    bool withdrawn;
  }

  IERC20 public immutable usdc;
  uint256 public constant LOCK_PERIOD = 7 days;
  uint256 public constant REWARD_AMOUNT = 100 * 10 ** 18;

  // nft => tokenId => DepositInfo
  mapping(address => mapping(uint256 => DepositInfo)) public deposits;

  constructor(address _usdc) {
    usdc = IERC20(_usdc);
  }

  function deposit(address nftAddress, uint256 tokenId) external nonReentrant {
    IERC721 nft = IERC721(nftAddress);
    require(nft.ownerOf(tokenId) == msg.sender, "Not the NFT owner");
    require(
      nft.getApproved(tokenId) == address(this) 
      || nft.isApprovedForAll(msg.sender, address(this)),
      "Contract not approved"
    );

    nft.transferFrom(msg.sender, address(this), tokenId);

    deposits[nftAddress][tokenId] = DepositInfo({
      owner: msg.sender,
      unlockTime: block.timestamp + LOCK_PERIOD,
      withdrawn: false
    });

    require(usdc.transfer(msg.sender, REWARD_AMOUNT), "USDC transfer failed");
  }

  function withdraw(address nftAddress, uint256 tokenId) external nonReentrant {
    DepositInfo storage info = deposits[nftAddress][tokenId];
    require(info.owner == msg.sender, "Not depositor");
    require(!info.withdrawn, "Already withdrawn");
    require(block.timestamp <= info.unlockTime, "NFT expired");

    require(usdc.transferFrom(msg.sender, address(this), REWARD_AMOUNT), "Payback required");

    info.withdrawn = true;

    IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
  }

  function getUnlockTime(address nftAddress, uint256 tokenId) external view returns (uint256) {
    return deposits[nftAddress][tokenId].unlockTime;
  }

  function isWithdrawable(address nftAddress, uint256 tokenId) external view returns (bool) {
    DepositInfo memory info = deposits[nftAddress][tokenId];
    return (
      !info.withdrawn &&
      info.owner == msg.sender &&
      block.timestamp <= info.unlockTime
    );
  }
}
