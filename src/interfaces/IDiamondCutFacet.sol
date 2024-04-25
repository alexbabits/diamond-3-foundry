// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IDiamondCutFacet {

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    enum FacetCutAction {Add, Replace, Remove} // {0, 1, 2}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    // `_diamondCut` = array of facets, the action wanted, and it's selectors.
    // `_init` = DiamondInit.sol address and `_calldata` is the `init()` function.
    // _init and _calldata are used to execute arbitrary function using delegatecall to set state variables
    // in the diamond during deployment or an upgrade.
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
    
}