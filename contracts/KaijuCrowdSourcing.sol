// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UniswapPriceFeed } from "./UniswapPriceFeed.sol";
import { IKaijuCrowdSourcingToken } from "./interfaces/IKaijuCrowdSourcingToken.sol";

contract KaijuCrowdSourcing is UniswapPriceFeed, Ownable, ReentrancyGuard 
{
     struct SubmittedFundRequest
     {
        address payable Owner;
        address SupportedToken;
        uint256 Amount;
        uint256 EthAmount;
        uint256 ExchangeRateApplied;
        uint256 RewardRateApplied;
        uint256 DateAdded;
        uint256 DateRedeemed;
        bool Active;
     }

     struct SupportedToken
     {
        IERC20 SupportedToken;
        bool Supported;
     }

     SubmittedFundRequest[] public SubmittedFunds;
	 
     mapping(address => uint256[]) private _usersSubmittedFundIndexes;
     mapping(address => SupportedToken) private _supportedTokens;
	 
     uint256 _ethToTokenRate = 1;

     IKaijuCrowdSourcingToken _rewardToken;

     event UpdatedSupportedTokenEvent(address indexed updater, address indexed token, bool supported, uint256 timestamp);
     event WithdrawTokenEvent(address indexed withdrawer, address indexed token, uint256 amount, uint256 timestamp);
     event WithdrawEthereumEvent(address indexed withdrawer, uint256 amount, uint256 timestamp);
     event SubmittedFundRequestEvent(address indexed submitter, uint256 indexed submittedFundRequestIndex, uint256 timestamp);
     event SubmittedTokenFundRequestEvent(address indexed submitter, address indexed tokenAddress, uint256 indexed submittedFundRequestIndex, uint256 timestamp);
     event UpdatedEthToRewardTokenRateEvent(address indexed updater, uint256 newRate, uint256 timestamp);

     constructor(
        address rewardTokenAdress, 
        address uniswapPriceFactoryAddress, 
        uint256 ethToTokenRate,
        address wEthAddress) 
        Ownable(msg.sender) 
        UniswapPriceFeed(uniswapPriceFactoryAddress, wEthAddress)
     {
         _rewardToken = IKaijuCrowdSourcingToken(rewardTokenAdress);
         _ethToTokenRate = ethToTokenRate;
     }

     // Crowd source with ETH
     function SubmitFunds() payable external 
     {
         // Check request has ETH
         require(msg.value >= 0, 'Nothing has been sent');
         
         // Calculate tokens to issue for source request
         uint256 tokensToIssue = msg.value / _ethToTokenRate;
         require(tokensToIssue > 0, 'No tokens to issue');
 
         // Create the request
         SubmittedFundRequest memory request = SubmittedFundRequest(
            payable(msg.sender),
            address(0),
            msg.value,
            msg.value,
            1,
            _ethToTokenRate,
            block.timestamp,
            0,
            true
         );

         // Save the request
         SubmittedFunds.push(request);

         // Get the index of the new request
         uint256 index = SubmittedFunds.length - 1;

         // Link the user to the index (their submissions)
         _usersSubmittedFundIndexes[msg.sender].push(index);

         // Mint the requester the corresponding amount of tokens
         _rewardToken.mint(msg.sender, tokensToIssue);

         // Fire event
         emit SubmittedFundRequestEvent(msg.sender, index, request.DateAdded);
     }

     // Crowd source with token (ERC20)
     function SubmitTokenFunds(address tokenAddress, uint256 amount) external 
     {
         // Check requesting token is supported
         SupportedToken storage supportedToken = _supportedTokens[tokenAddress];
         require(supportedToken.Supported, 'Token is not supported');

         // Check number of tokens to submit is not 0
         require(amount >= 0, 'Nothing has been sent');

         // Check this contract is able to take tokens from the user
         uint256 allowance = supportedToken.SupportedToken.allowance(msg.sender, address(this));
         require(allowance < amount, 'The token amount must be approved for this contracts address');

         // Transfer the ERC20s to this contract
         supportedToken.SupportedToken.transferFrom(msg.sender, address(this), amount);
		 
         // Get price for eth token pair from uniswap
         uint256 wethToTokenRate = getTokenRate(tokenAddress);

         // Calculate rate to ETH
         uint256 ethAmount = amount / wethToTokenRate;
         
         // Calculate amount of tokens to issue
         uint256 tokensToIssue = ethAmount / _ethToTokenRate;
         require(tokensToIssue > 0, 'No tokens to issue');

         // Create the request
         SubmittedFundRequest memory request = SubmittedFundRequest(
            payable(msg.sender),
            tokenAddress,
            amount,
            ethAmount,
            wethToTokenRate,
            _ethToTokenRate,
            block.timestamp,
            0,
            true
         );

         // Save the request
         SubmittedFunds.push(request);

         // Get the index of the new request
         uint256 index = SubmittedFunds.length - 1;

         // Link the user to the index (their submissions)
         _usersSubmittedFundIndexes[msg.sender].push(index);

         // Mint the requester the corresponding amount of tokens
         _rewardToken.mint(msg.sender, tokensToIssue);

         // Fire event
         emit SubmittedTokenFundRequestEvent(msg.sender, tokenAddress, index, request.DateAdded);
     }

     function UpdateSupportedToken(address tokenAddress, bool supported) onlyOwner external 
     {
        SupportedToken storage supportedToken = _supportedTokens[tokenAddress];
        supportedToken.SupportedToken = IERC20(tokenAddress);
        supportedToken.Supported = supported; 

        emit UpdatedSupportedTokenEvent(msg.sender, tokenAddress, supported, block.timestamp);
     }

     function WithdrawEthereum(address payable toAddress, uint256 amount) onlyOwner external 
     {
         toAddress.transfer(amount);

         emit WithdrawEthereumEvent(toAddress, amount, block.timestamp);
     }

     function WithdrawTokens(address payable toAddress, address tokenAddress, uint256 amount) onlyOwner external 
     {
         IERC20 token = IERC20(tokenAddress);
         token.transfer(toAddress, amount);

         emit WithdrawTokenEvent(toAddress, tokenAddress, amount, block.timestamp);
     }

     function UpdateEthToRewardTokenRate(uint256 newRate) onlyOwner external 
     {
         _ethToTokenRate = newRate;

         emit UpdatedEthToRewardTokenRateEvent(msg.sender, newRate, block.timestamp);
     }
}