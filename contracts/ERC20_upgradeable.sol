// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyTokenV1 is ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    // 初始化函数，替代构造函数
    function initialize(uint256 initialSupply) public initializer {
        __ERC20_init("MyToken", "MTK");
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // UUPS 升级功能，只有合约的所有者可以升级合约
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // 其他自定义功能可以在这里添加
}