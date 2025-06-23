// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/ReentrancyGuard.sol";

contract NFTDepositor is OwnerIsCreator, ReentrancyGuard {  
  event MessageSent(
    bytes32 indexed messageId,
    uint64 indexed scrollSepoliaDest,
    address receiver,
    bytes32 text,
    address feeToken,
    uint256 fees
  );
  event NFTDeposit(
    address indexed nftAddress, 
    address indexed owner,
    uint256 tokenId,
    uint256 startedTime,
    uint256 expiredTime
  );
  event NFTWithdraw(
    address indexed nftAddress, 
    address indexed owner,
    uint256 tokenId,
    uint256 withdrawnTime
  );
  event LinkReceived(address indexed sender, uint256 amount);

  error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

  struct DepositInfo {
    address owner;
    uint256 unlockTime;
    bool withdrawn;
  }
  
  IRouterClient public s_router;
  LinkTokenInterface public s_linkToken;
  uint public ntfPools;
  IERC20 public immutable usdc;
  uint256 public constant LOCK_PERIOD = 7 days;
  uint256 public constant REWARD_AMOUNT = 100 * 10 ** 18;
  uint64 public constant destinationScrollSepolia = 2279865765895943307;

  // nft => tokenId => DepositInfo
  mapping(address => mapping(uint256 => DepositInfo)) public depositsInfo;
  mapping(address => uint) public userLinkTokenBalance; 
  
  constructor(
    address _router, 
    address _link,
    address _usdc
  ) {
    s_router = IRouterClient(_router);
    s_linkToken = LinkTokenInterface(_link);
    usdc = IERC20(_usdc);
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

  function depositNft(
    address nftAddress,
    uint256 tokenId,
    address receiver,
    bytes32 commitment
  ) external nonReentrant returns (bytes32 messageId) {
    address owner = msg.sender;
    IERC721 nft = IERC721(nftAddress);
    require(nft.ownerOf(tokenId) == owner, "Not the NFT owner");
    require(
      nft.getApproved(tokenId) == address(this) 
      || nft.isApprovedForAll(owner, address(this)),
      "Contract not approved"
    );

    nft.transferFrom(msg.sender, address(this), tokenId);

    uint256 unlockTime = block.timestamp + LOCK_PERIOD;

    depositsInfo[nftAddress][tokenId] = DepositInfo({
      owner: owner,
      unlockTime: unlockTime,
      withdrawn: false
    });

    ntfPools += 1;

    Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
      receiver: abi.encode(receiver),
      data: abi.encode(commitment),
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

    if (fees > userLinkTokenBalance[owner]) {
      revert NotEnoughBalance(userLinkTokenBalance[owner], fees);
    } 

    if (fees > s_linkToken.balanceOf(address(this))) {
      revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
    }

    s_linkToken.approve(address(s_router), fees);
    userLinkTokenBalance[owner] -= fees;

    messageId = s_router.ccipSend(destinationScrollSepolia, evm2AnyMessage);

    emit MessageSent(
      messageId,
      destinationScrollSepolia,
      receiver,
      commitment,
      address(s_linkToken),
      fees
    );
    emit NFTDeposit(
      nftAddress,
      owner,
      tokenId,
      block.timestamp,
      unlockTime
    );

    return messageId;
  }

  function withdrawNft(address nftAddress, uint256 tokenId) external nonReentrant {
    DepositInfo storage info = depositsInfo[nftAddress][tokenId];
    require(info.owner == msg.sender, "Not depositor");
    require(!info.withdrawn, "Already withdrawn");
    require(block.timestamp <= info.unlockTime, "NFT expired");

    require(usdc.transferFrom(msg.sender, address(this), REWARD_AMOUNT), "Payback required");

    info.withdrawn = true;
    ntfPools -= 1;

    IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
  }

  function getUnlockTime(address nftAddress, uint256 tokenId) external view returns (uint256) {
    return depositsInfo[nftAddress][tokenId].unlockTime;
  }

  function isWithdrawable(address nftAddress, uint256 tokenId) external view returns (bool) {
    DepositInfo memory info = depositsInfo[nftAddress][tokenId];
    return (
      !info.withdrawn &&
      info.owner == msg.sender &&
      block.timestamp <= info.unlockTime
    );
  }
}