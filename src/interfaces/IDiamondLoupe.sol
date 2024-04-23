// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Loupe = IRL tool used to look at diamonds. These functions look at diamonds.
interface IDiamondLoupe {

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    // These functions are expected to be called frequently by tools.
    function facets() external view returns (Facet[] memory facets_);
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
    function facetAddresses() external view returns (address[] memory facetAddresses_);
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}