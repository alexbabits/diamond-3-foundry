// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// `AppStorageRoot` contract ensures AppStorage is at slot 0 for facets that inherit other contracts with storage.
// For example, ERC20 and ERC1155 facets inherit storage from the OZ templates.
// This causes AppStorage to NOT be at slot 0 where it should be. The AppStorage for those facets was separated 
// from the diamond and in a different slot. Therefore, if we inherit `AppStorageRoot` as the FIRST inheritance, 
// this forces AppStorage to be at slot 0 for the facet, and we can still have the extra storage afterwards.
// Note: This is a band-aid, and should not be used in production. For facets, you should probably just not
// inherit any contract that has storage itself.
contract AppStorageRoot {
    AppStorage internal s;
}

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

    // ERC1155 (Complies with OZ ERC1155 template) 
    // Changed _balances to _erc1155balances to avoid name collision with ERC20 _balances
    mapping(uint256 id => mapping(address account => uint256)) _erc1155balances; 
    mapping(address account => mapping(address operator => bool)) _operatorApprovals;
    string _uri;

    uint256 number; // Needed to test AppStorage mis-match fix via `AppStorageRoot`
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