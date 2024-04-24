// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IDiamondCut {

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    enum FacetCutAction {Add, Replace, Remove} // {0, 1, 2}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    // `_diamondCut` is the array of facets, the action wanted, and it's selectors.
    // `_init` is the DiamondInit.sol address and `_calldata` is the `init()` function.
    // They are used to execute arbitrary function using delegatecall to set state variables
    // in the diamond during deployment or an upgrade.
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
    
}