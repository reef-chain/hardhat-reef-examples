
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
		constructor(uint256 initialBalance) public ERC20("Fluid Token", "FLD") {
				_mint(msg.sender, initialBalance);
		}
}
