// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20 {
  constructor() ERC20("USDC", "USDC") {
    _mint(msg.sender, 1_000_000 * 10 ** decimals());
  }

  function mint(address to, uint256 amount) external {
      _mint(to, amount);
  }
}
