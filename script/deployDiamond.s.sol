// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/DiamondCutFacet.sol";
import "../src/facets/DiamondLoupeFacet.sol";
import "../src/facets/OwnershipFacet.sol";
import "../src/upgradeInitializers/DiamondInit.sol";
import "../test/HelperContract.sol";

// Script to deploy a template Diamond with Cut, Loupe and Ownership facet
contract DeployScript is Script, HelperContract {
    function run() external {

        vm.startBroadcast();

        // Deploy facets and the init contract
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        DiamondInit diamondInit = new DiamondInit();

        // Diamond arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: msg.sender,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSignature("init()") // calls the `init()` function upon `Diamond` deployment
        });

        // FacetCut array which contains the three standard facets to be added
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = FacetCut({
            facetAddress: address(diamondCutFacet),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondCutFacet")
        });

        cut[1] = FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondLoupeFacet")
        });

        cut[2] = FacetCut({
            facetAddress: address(ownershipFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("OwnershipFacet")
        });

        // deploy our Diamond after the "core" facets are cut and ready to go, along with all the args needed.
        Diamond diamond = new Diamond(cut, _args);
        console.log("Deployed Diamond.sol at address: ", address(diamond));

        vm.stopBroadcast();
    }
}