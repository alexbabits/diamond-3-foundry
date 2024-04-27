// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";

// Example facet using AppStorage
contract FacetWithAppStorage2 {
    AppStorage internal s; // slot 0

    // Getter to check if AppStorage persists through different facets.
    function getFirstVar() public view returns (uint256) {
        return s.firstVar;
    }
}