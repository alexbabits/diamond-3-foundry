// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage, LibAppStorage} from "./LibAppStorage.sol"; 

// Example "Utility" Library for calculations or state changes you want to make with a library.
library LibExample {

    // This example function shows that we can do calculations with the state from `AppStorage`!
    function calculateSomething(uint256 a, uint256 b) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 c = s.firstVar + a + b; // s.firstVar is an example state variable inside `AppStorage` struct.
        return c;
    }

    // This example function shows that we can also update the state in `AppStorage`
    function changeState(uint256 a, uint256 b) internal returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.firstVar += a;
        s.firstVar += b;
        return s.firstVar;
    }

}