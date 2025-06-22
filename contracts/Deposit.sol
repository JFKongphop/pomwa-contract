// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract Deposit is OwnerIsCreator {
  uint64 public constant destinationScrollSepolia = 2279865765895943307;
  mapping(address => uint) public userLinkTokenBalance; 

  error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

  event MessageSent(
    bytes32 indexed messageId,
    uint64 indexed scrollSepoliaDest,
    address receiver,
    bytes32 text,
    address feeToken,
    uint256 fees
  );
  event LinkReceived(address indexed sender, uint256 amount);

  IRouterClient private s_router;
  LinkTokenInterface private s_linkToken;

  constructor(address _router, address _link) {
    s_router = IRouterClient(_router);
    s_linkToken = LinkTokenInterface(_link);
  }

  function onTokenTransfer(
    address sender,
    uint256 amount,
    bytes calldata
  ) external {
    require(msg.sender == address(s_linkToken), "Only LINK token");

    userLinkTokenBalance[sender] += amount;
    emit LinkReceived(msg.sender, amount);
  }

  function sendMessage(
    address receiver,
    bytes32 text
  ) external returns (bytes32 messageId) {
    Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
      receiver: abi.encode(receiver),
      data: abi.encode(text),
      tokenAmounts: new Client.EVMTokenAmount[](0),
      extraArgs: Client._argsToBytes(
        Client.GenericExtraArgsV2({
          gasLimit: 500_000,
          allowOutOfOrderExecution: true
        })
      ),
      feeToken: address(s_linkToken)
    });

    uint256 fees = s_router.getFee(
      destinationScrollSepolia,
      evm2AnyMessage
    );

    if (fees > userLinkTokenBalance[msg.sender]) {
      revert NotEnoughBalance(userLinkTokenBalance[msg.sender], fees);
    } 

    if (fees > s_linkToken.balanceOf(address(this))) {
      revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
    }

    s_linkToken.approve(address(s_router), fees);

    userLinkTokenBalance[msg.sender] -= fees;

    messageId = s_router.ccipSend(destinationScrollSepolia, evm2AnyMessage);

    emit MessageSent(
      messageId,
      destinationScrollSepolia,
      receiver,
      text,
      address(s_linkToken),
      fees
    );

    return messageId;
  }
}