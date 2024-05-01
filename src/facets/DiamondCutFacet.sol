// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IDiamondCutFacet} from "../interfaces/IDiamondCutFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCutFacet {

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external override {
        LibDiamond.enforceIsContractOwner(); // This is `onlyOwner` Diamond Equivilant.
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
    
}