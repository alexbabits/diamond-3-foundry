// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

struct AppStorage {
    // Test Variables
    uint256 firstVar;
    uint256 secondVar;
    uint256 thirdVar;
    uint256 fourthVar;
    uint256 lastVar;

    // ERC20
    mapping(address account => uint256) _balances;
    mapping(address account => mapping(address spender => uint256)) _allowances;
    uint256 _totalSupply;
    string _name;
    string _symbol;

    // ERC1155
    // Soon
}