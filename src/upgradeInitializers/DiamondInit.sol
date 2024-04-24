// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";

// Modify `init()` to initialize any extra state variables for your diamond with your deployment script.
// You can also add parameters to `init()` if needed to set your own state variables.
contract DiamondInit {    

    function init() external {
        // add IERC165, IERC173, DiamondCut, DiamondLoupe.
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    }
    
}