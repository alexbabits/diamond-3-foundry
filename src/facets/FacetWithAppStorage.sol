// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";
import {LibExample} from "../libraries/LibExample.sol";

contract FacetWithAppStorage {
    AppStorage internal s; // slot 0

    // We can update state with other state variables if we want to.
    function doSomething() external {
        s.lastVar = s.firstVar + s.secondVar;
    }

    // We can update state variables with arguments.
    function doSomethingElse(uint256 a, uint256 b) external returns (uint256, uint256) {
        s.firstVar += a;
        s.secondVar += b;
        return (s.firstVar, s.secondVar); 
    }

    // We can use library functions to calculate a number
    function libraryFunctionOne(uint256 a, uint256 b) external view returns (uint256) {
        uint256 c = LibExample.calculateWithStorage(a,b);
        return c;
    }

    // We can use library functions to update state
    function libraryFunctionTwo(uint256 a, uint256 b) external {
        LibExample.modifyStorageWithCalcuation(a,b);
    }

    // Public getter needed for AppStorage
    function getVars() public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (s.firstVar, s.secondVar, s.thirdVar, s.fourthVar, s.lastVar);
    }

}