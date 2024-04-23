// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IDiamond {
    enum FacetCutAction {Add, Replace, Remove} // {0, 1, 2}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action; // are we adding, replacing, or removing this facet?
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}