// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IKaijuCrowdSourcingToken is IERC20 
{
     function mint(address toAddress, uint256 amount) external;
	function burn(address toAddress, uint256 amount) external;
}