// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";

import {Diamond} from "../src/Diamond.sol";
import {DiamondInit} from "../src/upgradeInitializers/DiamondInit.sol";

import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../src/facets/OwnershipFacet.sol";

import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {IOwnership} from "../src/interfaces/IOwnership.sol";

import {HelperContract} from "../test/HelperContract.sol";

// Script to deploy a Diamond with CutFacet, LoupeFacet and OwnershipFacet
contract DeployScript is Script, HelperContract {
    function run() external {

        vm.startBroadcast();

        // Deploy Contracts
        DiamondInit diamondInit = new DiamondInit();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();

        // Public address associated with the private key that launched this script is now the owner, "msg.sender".
        Diamond diamond = new Diamond(msg.sender, address(diamondCutFacet));
        console.log("Deployed Diamond.sol at address:", address(diamond));

        // We prepare an array of `cuts` that we want to upgrade our Diamond with.
        // The cuts are the remaining facets, their associated functions, and the action (we want to add).
        // (DiamondCutFacet was already cut during Diamond deployment)
        FacetCut[] memory cut = new FacetCut[](2);

        cut[0] = FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondLoupeFacet")
        });

        cut[1] = FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("OwnershipFacet")
        });

        // Now that we have all the cuts we want, we can upgrade the diamond to include these facets.
        // We call `diamondCut` with our `diamond` contract through the `DiamondCutFacet.sol` interface.
        IDiamondCut(address(diamond)).diamondCut(cut, address(diamondInit), abi.encodeWithSignature("init()"));

        console.log("Diamond cut complete. Owner of Diamond:", IOwnership(address(diamond)).owner());

        vm.stopBroadcast();
    }
}