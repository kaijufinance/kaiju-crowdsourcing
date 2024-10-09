// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { IUniswapV2PairMinimal } from "./interfaces/IUniswapV2PairMinimal.sol";
import { IUniswapV2FactoryMinimal } from "./interfaces/IUniswapV2FactoryMinimal.sol";

abstract contract UniswapPriceFeed 
{
    IUniswapV2FactoryMinimal private _uniswapV2Factory;
    address private immutable _wEthAddress;

    constructor(address uniswapV2Factory, address wEthAddress) 
    {
        _uniswapV2Factory = IUniswapV2FactoryMinimal(uniswapV2Factory);
        _wEthAddress = wEthAddress;
    }

    function getTokenRate(address token) internal view returns (uint256 rate) 
    {
        address pairAddress = _uniswapV2Factory.getPricePair(_wEthAddress, token);
        require(pairAddress != address(0), "[UniswapPriceFetcher]: Pair does not exist");

        IUniswapV2PairMinimal pair = IUniswapV2PairMinimal(pairAddress);
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        // Ensure tokenA is token0
        if (_wEthAddress != pair.token0()) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }

        // Calculate price with 18 decimals of precision
        rate = (reserve1 / reserve0);
    }

    function updateUniswapFactory(address factoryAddress) internal
    {
        _uniswapV2Factory = IUniswapV2FactoryMinimal(factoryAddress);
    }
}