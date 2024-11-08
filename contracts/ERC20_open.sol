/**
 * 使用openzepplin的实现
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AxsToken is ERC20 {

    constructor(uint256 initialSupply) ERC20("AxsToken", "AXS") {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }
}