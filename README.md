# Kaiju Crowd Sourcing :moneybag:

## Description :page_with_curl:

This is a set of contracts to be used for fund raising. We will issue tokens at a rate to what has been sent. This supports both native ETH as well as ERC20s - these must be registered as supportedd tokens.

We have a ETH-Fundraising Token rate in the contract which defines how many tokens users get for the amount of ETH they have sent to the contract. If tokens are sent to the contract, Uniswap is used to find the current price of the token to WEth and then once this conversaion is done - we use the ETH-Fundraising Token rate to send the correct amount of tokens. 

## Functionality :factory:

- Provides the ability to send ETH to the contract and receive the corresponding number of tokens defined in a rate
- Provides the ability to send ERC20 tokens to the contract (granted they are supported) and receive the corresponding number of tokens defined in a rate
- Provides the ability to get the total funds submitted by a user
- Provides the ability to get the fund submissions for a user
- Provides the ability to get and fund submission but index
- The ETH-Fundraising Token rate is configurable by the <b>contract owner</b>
- The Uniswap Factory address is configurable by the <b>contract owner</b>
- Provides the ability to add/remove supported tokens by the <b>contract owner</b>
- Provides the ability to withdraw ETH from the contract for the <b>contract owner</b>
- Provides the ability to withdraw ERC20 tokens from the contract for the <b>contract owner</b>

## Test Dapps :construction:

Deployers Address: TBC.

| Contract      | Address       | Network       |
| ------------- | ------------- | ------------- |
| Crowd Sourcing Token | [TBC.](https://sepolia.etherscan.io/address/TBC.#code)     | Sepolia       | 
| Crowd Sourcing Contract | [TBC.](https://sepolia.etherscan.io/address/TBC.#code)     | Sepolia       | 

## Deploy Steps :shipit:

1. Deploy crowd sourcing token
2. Deploy crowd sourcing contract using the crowd spurcing token address as a constructor arg as well as the address for the Uniswap factory
3. Set the owner of the crowd sourcing token as the crowd sourcing contract (so it can mint/burn)

## Process Flow :arrows_clockwise:

TBC.

## Notes :notebook:

:warning: TBC.
