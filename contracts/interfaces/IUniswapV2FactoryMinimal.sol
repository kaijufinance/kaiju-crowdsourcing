// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

interface IUniswapV2FactoryMinimal 
{
    function getPricePair(address tokenA, address tokenB) external view returns (address pair);
}