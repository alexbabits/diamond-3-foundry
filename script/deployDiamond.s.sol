// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";

import {Diamond} from "../src/Diamond.sol";
import {DiamondInit} from "../src/upgradeInitializers/DiamondInit.sol";

import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../src/facets/OwnershipFacet.sol";

import {IDiamondCutFacet} from "../src/interfaces/IDiamondCutFacet.sol";
import {IDiamondLoupeFacet} from "../src/interfaces/IDiamondLoupeFacet.sol";
import {IERC165} from "../src/interfaces/IERC165.sol";
import {IERC173} from "../src/interfaces/IERC173.sol";

// Script to deploy a Diamond with CutFacet, LoupeFacet and OwnershipFacet
// This Script DOES NOT upgrade the diamond with any of the example facets.
contract DeployScript is Script {
    function run() external {

        vm.startBroadcast();

        // Deploy Contracts
        DiamondInit diamondInit = new DiamondInit();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();

        // Public address associated with the private key that launched this script is now the owner. (msg.sender).
        Diamond diamond = new Diamond(msg.sender, address(diamondCutFacet));
        console.log("Deployed Diamond.sol at address:", address(diamond));

        // We prepare an array of `cuts` that we want to upgrade our Diamond with.
        // The remaining cuts that we want the diamond to have are the Loupe and Ownership facets.
        // A `cut` is a facet, its associated functions, and the action (we want to add).
        // (DiamondCutFacet was already cut during Diamond deployment, cannot re-add again anyway).
        IDiamondCutFacet.FacetCut[] memory cuts = new IDiamondCutFacet.FacetCut[](2);

        // We create and populate array of function selectors needed for FacetCut Structs
        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = IDiamondLoupeFacet.facets.selector;
        loupeSelectors[1] = IDiamondLoupeFacet.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupeFacet.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupeFacet.facetAddress.selector;
        loupeSelectors[4] = IERC165.supportsInterface.selector; // The IERC165 function found in the Loupe.

        bytes4[] memory ownershipSelectors = new bytes4[](2);
        ownershipSelectors[0] = IERC173.owner.selector; // IERC173 has all the ownership functions needed.
        ownershipSelectors[1] = IERC173.transferOwnership.selector;

        // Populate the `cuts` array with all data needed for each `FacetCut` struct
        cuts[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        cuts[1] = IDiamondCutFacet.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: ownershipSelectors
        });

        // After we have all the cuts setup how we want, we can upgrade the diamond to include these facets.
        // We call `diamondCut` with our `diamond` contract through the `IDiamondCutFacet` interface.
        // `diamondCut` takes in the `cuts` and the `DiamondInit` contract and calls its `init()` function.
        IDiamondCutFacet(address(diamond)).diamondCut(cuts, address(diamondInit), abi.encodeWithSignature("init()"));

        // We use `IERC173` instead of an `IOwnershipFacet` interface for the `OwnershipFacet` with no problems
        // because all functions from `OwnershipFacet` are just IERC173 overrides.
        // However, for more complex facets that are not exactly 1:1 with an existing IERC, 
        // you can create custom `IExampleFacet` interface that isn't just identical to an IERC.
        console.log("Diamond cuts complete. Owner of Diamond:", IERC173(address(diamond)).owner());

        vm.stopBroadcast();
    }
}


/* 
                                        Tips

- There are many ways to get a function selector. `facets()` is 0x7a0ed627 for example.                                       
- Function Selector = First 4 bytes of a hashed function signature.
- Function Signature = Function name and it's parameter types. No spaces. "transfer(address,uint256)".

1. `Contract.function.selector` --> console.logBytes4(IDiamondLoupeFacet.facets.selector);
2. `bytes4(keccak256("funcSig")` --> console.logBytes4(bytes4(keccak256("facets()")));
3. `bytes4(abi.encodeWithSignature("funcSig"))` --> console.logBytes4(bytes4(abi.encodeWithSignature("facets()"))); 
4. VSCode extension `Solidity Visual Developer` shows function selectors. Manual copy-paste.

*/