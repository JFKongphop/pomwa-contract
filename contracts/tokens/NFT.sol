// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
  uint256 public nextTokenId;

  constructor() ERC721("MyNFT", "MNFT") {}

  function mint() external {
    _safeMint(msg.sender, nextTokenId);
    nextTokenId++;
  }
}
