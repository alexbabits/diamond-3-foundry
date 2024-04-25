// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage, LibAppStorage} from "./LibAppStorage.sol"; 

// Example "Utility" Library for calculations or state changes you want to make via a library.
library LibExample {

    // We can do calculations with the state from `AppStorage` in libraries.
    function calculateWithStorage(uint256 a, uint256 b) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.appStorage();
        uint256 c = s.secondVar + a + b;
        return c;
    }

    // We can update the state in `AppStorage` through library functions.
    function modifyStorageWithCalcuation(uint256 a, uint256 b) internal {
        AppStorage storage s = LibAppStorage.appStorage();
        s.thirdVar += a;
        s.fourthVar += b;
    }

}