// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";

contract FacetWithAppStorage {
    AppStorage internal s; // slot 0

    // Uses other state vars to change a state var
    function doSomething() external {
        s.lastVar = s.firstVar + s.secondVar;
    }

    // Uses inputs to change the state var
    function doSomethingElse(uint256 a, uint256 b) external returns (uint256) {
        s.firstVar += a;
        s.firstVar += b;
        return s.firstVar; 
    }
}