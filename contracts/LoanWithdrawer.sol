// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MerkleTreeWithHistory.sol";
import "./utils/ReentrancyGuard.sol";
import "./interfaces/IVerifier.sol";

contract Withdraw is CCIPReceiver, MerkleTreeWithHistory, ReentrancyGuard {
  IVerifier public immutable verifier;
  IERC20 public immutable usdc;


  bytes32 private s_lastReceivedMessageId;
  bytes32 private s_lastReceivedText;

  event MessageReceived(
    bytes32 indexed messageId,
    uint64 indexed sourceChainSelector,
    address sender,
    bytes32 text
  );
  event Deposit(
    bytes32 indexed commitment,
    uint indexed leafIndex
  );


  constructor(
    IVerifier _verifier,
    address router, 
    IHasher hasher,
    uint32 merkleTreeHeight
  ) CCIPReceiver(router) MerkleTreeWithHistory(merkleTreeHeight, hasher) {
    verifier = _verifier;
  }

  function _ccipReceive(
    Client.Any2EVMMessage memory any2EvmMessage
  ) internal override {
    s_lastReceivedMessageId = any2EvmMessage.messageId;
    s_lastReceivedText = abi.decode(any2EvmMessage.data, (bytes32));

    uint leafIndex = _insert(s_lastReceivedText);

    emit MessageReceived(
      any2EvmMessage.messageId,
      any2EvmMessage.sourceChainSelector,
      abi.decode(any2EvmMessage.sender, (address)),
      abi.decode(any2EvmMessage.data, (bytes32))
    );
    emit Deposit(s_lastReceivedText, leafIndex);
  }

  function loanWithdraw(
    bytes32 _commitment,
    bytes32 _root,
    uint[2] calldata _pA, 
    uint[2][2] calldata _pB, 
    uint[2] calldata _pC,
    uint[1] calldata _pubSignals
  ) external payable nonReentrant {
    uint256 loanAmount = _pubSignals[0] * 10 * 18;

    require(usdc.transferFrom(msg.sender, address(this), loanAmount), "Payback required");


  }

  function getLastReceivedMessageDetails()
    external
    view
    returns (bytes32 messageId, bytes32 text)
  {
    return (s_lastReceivedMessageId, s_lastReceivedText);
  }




}