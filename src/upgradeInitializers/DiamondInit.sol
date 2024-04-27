// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondLoupeFacet} from "../interfaces/IDiamondLoupeFacet.sol";
import {IDiamondCutFacet} from "../interfaces/IDiamondCutFacet.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";

// Modify `init()` to initialize any extra state variables in `LibDiamond.DiamondStorage` struct during deployment.
// You can also add parameters to `init()` if needed to set your own state variables.
contract DiamondInit {    

    function init() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Diamond, Introspection (165), Ownership (173)
        ds.supportedInterfaces[type(IDiamondCutFacet).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupeFacet).interfaceId] = true;
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // ERC20
        ds.supportedInterfaces[0x36372b07] = true; // IERC20
        ds.supportedInterfaces[0xa219a025] = true; // IERC20MetaData 

        // ERC1155
        ds.supportedInterfaces[0xd9b67a26] = true; // IERC1155
        ds.supportedInterfaces[0x0e89341c] = true; // IERC1155MetadataURI
    }
    
}