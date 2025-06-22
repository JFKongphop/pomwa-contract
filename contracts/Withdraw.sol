// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import "./MerkleTreeWithHistory.sol";

contract Withdraw is CCIPReceiver, MerkleTreeWithHistory {
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

  bytes32 private s_lastReceivedMessageId;
  bytes32 private s_lastReceivedText;

  constructor(
    address router, 
    IHasher hasher,
    uint32 merkleTreeHeight
  ) CCIPReceiver(router) MerkleTreeWithHistory(merkleTreeHeight, hasher) {}

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

  function getLastReceivedMessageDetails()
    external
    view
    returns (bytes32 messageId, bytes32 text)
  {
    return (s_lastReceivedMessageId, s_lastReceivedText);
  }
}