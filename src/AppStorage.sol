// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

struct AppStorage {

    // Test Variables
    uint256 firstVar;
    uint256 secondVar;
    uint256 thirdVar;
    uint256 fourthVar;
    uint256 lastVar;
    mapping(InnerStructID => NestedStruct) ns;
    UnprotectedNestedStruct uns;

    // ERC20 (Complies with OZ ERC20 template)
    mapping(address account => uint256) _balances;
    mapping(address account => mapping(address spender => uint256)) _allowances;
    uint256 _totalSupply;
    string _name;
    string _symbol;

    // ERC1155 (Complies with OZ ERC20 template) 
    // Changed _balances to _erc1155balances to avoid name collision with ERC20 _balances
    mapping(uint256 id => mapping(address account => uint256)) _erc1155balances; 
    mapping(address account => mapping(address operator => bool)) _operatorApprovals;
    string _uri;
}

// Example struct placed inside of AppStorage, "protected" with a mapping. 
// Note: Do not nest structs unless you will never add more state variables to the inner struct.
// Note: You can't add new state vars to inner structs in upgrades without overwriting existing state vars.
// Note: It's recommended, but not mandatory, to place this within a mapping inside AppStorage to solve that issue.
// Note: Read exhaustive security concerns here: https://eip2535diamonds.substack.com/p/diamond-upgrades
struct NestedStruct {
    ExampleEnum exampleEnum;
    uint256 var123;
    uint256 var456;
    uint256 var789;
}

// Example struct placed inside of AppStorage with no "protection".
struct UnprotectedNestedStruct {
    uint256 var69;
    uint256 var420;
}

// Shows that we can have enums within our structs with AppStorage
enum ExampleEnum {
    ENUM_ONE, 
    ENUM_TWO,
    ENUM_THREE
}

// Nice-to-have helper type when you have more than one inner struct that is in a mapping in AppStorage
// Could also make these immutable/constant values somewhere.
enum InnerStructID {
    ONE,
    TWO,
    THREE
}