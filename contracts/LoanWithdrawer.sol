// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MerkleTreeWithHistory.sol";
import "./utils/ReentrancyGuard.sol";
import "./interfaces/IVerifier.sol";

contract LoanWithdrawer is CCIPReceiver, MerkleTreeWithHistory, ReentrancyGuard {
  IVerifier public immutable verifier;
  IERC20 public immutable usdc;

  struct CommitmentStatus {
    bytes32 commitment;
    bool withdrawn;
  }

  bytes32 private s_lastReceivedMessageId;
  bytes32 private s_lastReceivedText;

  mapping(bytes32 => bool) public nullifiers;

  event MessageReceived(
    bytes32 indexed messageId,
    uint64 indexed sourceChainSelector,
    address sender,
    bytes32 text
  );
  event LeafCommitment(
    bytes32 indexed commitment,
    uint indexed leafIndex
  );

  constructor(
    IVerifier _verifier,
    address _usdc,
    address router, 
    IHasher hasher,
    uint32 merkleTreeHeight
  ) CCIPReceiver(router) MerkleTreeWithHistory(merkleTreeHeight, hasher) {
    verifier = _verifier;
    usdc = IERC20(_usdc);
  }

  function _ccipReceive(
    Client.Any2EVMMessage memory any2EvmMessage
  ) internal override {
    s_lastReceivedMessageId = any2EvmMessage.messageId;
    s_lastReceivedText = abi.decode(any2EvmMessage.data, (bytes32));

    nullifiers[s_lastReceivedText] = false;
    uint leafIndex = _insert(s_lastReceivedText);

    emit LeafCommitment(s_lastReceivedText, leafIndex);
  }

  function loanWithdraw(
    bytes32 nullifier,
    bytes32 _root,
    uint[2] calldata _pA, 
    uint[2][2] calldata _pB, 
    uint[2] calldata _pC,
    uint[1] calldata _pubSignals
  ) external payable nonReentrant {
    uint256 loanAmount = _pubSignals[0] * 10 * 18;

    require(!nullifiers[nullifier], "Already withdrawn");

    nullifiers[nullifier] = true;

    require(isKnownRoot(_root), 'invalid root');
    require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals));
    require(usdc.transfer(msg.sender, loanAmount), "USDC transfer failed");
  }

  function getLastReceivedMessageDetails()
    external
    view
    returns (bytes32 messageId, bytes32 text)
  {
    return (s_lastReceivedMessageId, s_lastReceivedText);
  }
}