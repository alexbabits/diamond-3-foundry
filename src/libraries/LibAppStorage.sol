// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Right now, we are explicitly importing just the `AppStorage` struct, which is everything in that file.
import {AppStorage} from "../AppStorage.sol";

// Allows libaries to access protocol's state.
library LibAppStorage {
    
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

}