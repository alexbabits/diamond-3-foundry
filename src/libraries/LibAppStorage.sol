// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";

// Allows libaries to access protocol's state, via `AppStorage`, found at slot of 0.
// `AppStorage` is precisely at slot 0 and nowhere else ever, because this is
// the only state that should ever be housed in facets through this pattern.
library LibAppStorage {

    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

}