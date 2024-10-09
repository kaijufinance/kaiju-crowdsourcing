// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IKaijuCrowdSourcingToken } from "./interfaces/IKaijuCrowdSourcingToken.sol";

contract KaijuCrowdSourcingToken is IERC20, ERC20, Ownable, ReentrancyGuard, IKaijuCrowdSourcingToken
{
    constructor () Ownable(msg.sender) ERC20('Kaiju Crowd Sourcing Token','KCST'){
    }

    function mint(address user, uint256 amount) external onlyOwner nonReentrant{
        _mint(user, amount);
    }
	
	function burn(address user, uint256 amount) external onlyOwner nonReentrant{
        _burn(user, amount);
    }
}