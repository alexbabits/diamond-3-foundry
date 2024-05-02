// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {Diamond} from "../src/Diamond.sol";
import {DiamondInit} from "../src/upgradeInitializers/DiamondInit.sol";

import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../src/facets/OwnershipFacet.sol";

import {IDiamondCutFacet} from "../src/interfaces/IDiamondCutFacet.sol";
import {IDiamondLoupeFacet} from "../src/interfaces/IDiamondLoupeFacet.sol";
import {IERC165} from "../src/interfaces/IERC165.sol";
import {IERC173} from "../src/interfaces/IERC173.sol";

import {ExampleFacet} from "../src/facets/ExampleFacet.sol";
import {FacetWithAppStorage} from "../src/facets/FacetWithAppStorage.sol";
import {FacetWithAppStorage2, ExampleEnum} from "../src/facets/FacetWithAppStorage2.sol";

import {ERC20Facet} from "../src/facets/ERC20Facet.sol";
import {IERC20Facet} from "../src/interfaces/IERC20Facet.sol";
import {ERC1155Facet} from "../src/facets/ERC1155Facet.sol";
import {IERC1155Facet} from "../src/interfaces/IERC1155Facet.sol";

contract DiamondUnitTest is Test {

    Diamond diamond;
    DiamondInit diamondInit;
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    OwnershipFacet ownershipFacet;

    IDiamondLoupeFacet ILoupe;
    IDiamondCutFacet ICut;

    ExampleFacet exampleFacet;
    FacetWithAppStorage facetWithAppStorage;
    FacetWithAppStorage2 facetWithAppStorage2;

    ERC20Facet erc20Facet;
    ERC1155Facet erc1155Facet;

    address diamondOwner = address(0x1337DAD);
    address alice = address(0xA11C3);
    address bob = address(0xB0B);

    address[] facetAddressList;

    function setUp() public {

        // Deploy core diamond template contracts
        diamondInit = new DiamondInit();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        ownershipFacet = new OwnershipFacet();
        diamond = new Diamond(diamondOwner, address(diamondCutFacet));
        
        // Create the `cuts` array. (Already cut DiamondCut during diamond deployment)
        IDiamondCutFacet.FacetCut[] memory cuts = new IDiamondCutFacet.FacetCut[](2);

        // Get function selectors for facets for `cuts` array.
        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = IDiamondLoupeFacet.facets.selector;
        loupeSelectors[1] = IDiamondLoupeFacet.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupeFacet.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupeFacet.facetAddress.selector;
        loupeSelectors[4] = IERC165.supportsInterface.selector;

        bytes4[] memory ownershipSelectors = new bytes4[](2);
        ownershipSelectors[0] = IERC173.owner.selector; 
        ownershipSelectors[1] = IERC173.transferOwnership.selector;

        // Populate the `cuts` array with the needed data.
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

        // Upgrade our diamond with the remaining facets by making the cuts. Must be owner!
        vm.prank(diamondOwner);
        IDiamondCutFacet(address(diamond)).diamondCut(cuts, address(diamondInit), abi.encodeWithSignature("init()"));

        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses

        // Set interfaces for less verbose diamond interactions.
        ILoupe = IDiamondLoupeFacet(address(diamond));
        ICut = IDiamondCutFacet(address(diamond));
    }


    function test_Deployment() public view {

        // All 3 facets have been added to the diamond, and are not 0x0 address.
        assertEq(facetAddressList.length, 3, "Cut, Loupe, Ownership");
        assertNotEq(facetAddressList[0], address(0), "Not 0x0 address");
        assertNotEq(facetAddressList[1], address(0), "Not 0x0 address");
        assertNotEq(facetAddressList[2], address(0), "Not 0x0 address");

        // Owner is set correctly?
        assertEq(IERC173(address(diamond)).owner(), diamondOwner, "Diamond owner set properly");

        // Interface support set to true during `init()` call during Diamond upgrade?
        assertTrue(IERC165(address(diamond)).supportsInterface(type(IERC165).interfaceId), "IERC165");
        assertTrue(IERC165(address(diamond)).supportsInterface(type(IERC173).interfaceId), "IERC173");
        assertTrue(IERC165(address(diamond)).supportsInterface(type(IDiamondCutFacet).interfaceId), "Cut");
        assertTrue(IERC165(address(diamond)).supportsInterface(type(IDiamondLoupeFacet).interfaceId), "Loupe");
        assertTrue(IERC165(address(diamond)).supportsInterface(0x36372b07), "IERC20");
        assertTrue(IERC165(address(diamond)).supportsInterface(0xa219a025), "IERC20MetaData");
        assertTrue(IERC165(address(diamond)).supportsInterface(0xd9b67a26), "IERC1155");
        assertTrue(IERC165(address(diamond)).supportsInterface(0x0e89341c), "IERC1155MetadataURI");

        // Facets have the correct function selectors?     
        bytes4[] memory loupeViewCut = ILoupe.facetFunctionSelectors(facetAddressList[0]); // DiamondCut
        bytes4[] memory loupeViewLoupe = ILoupe.facetFunctionSelectors(facetAddressList[1]); // Loupe
        bytes4[] memory loupeViewOwnership = ILoupe.facetFunctionSelectors(facetAddressList[2]); // Ownership
        assertEq(loupeViewCut[0], IDiamondCutFacet.diamondCut.selector, "should match");
        assertEq(loupeViewLoupe[0], IDiamondLoupeFacet.facets.selector, "should match");
        assertEq(loupeViewLoupe[1], IDiamondLoupeFacet.facetFunctionSelectors.selector, "should match");
        assertEq(loupeViewLoupe[2], IDiamondLoupeFacet.facetAddresses.selector, "should match");
        assertEq(loupeViewLoupe[3], IDiamondLoupeFacet.facetAddress.selector, "should match");
        assertEq(loupeViewLoupe[4], IERC165.supportsInterface.selector, "should match");
        assertEq(loupeViewOwnership[0], IERC173.owner.selector, "should match");
        assertEq(loupeViewOwnership[1], IERC173.transferOwnership.selector, "should match");
    
        // Function selectors are associated with the correct facets?
        assertEq(facetAddressList[0], ILoupe.facetAddress(IDiamondCutFacet.diamondCut.selector), "should match");
        assertEq(facetAddressList[1], ILoupe.facetAddress(IDiamondLoupeFacet.facets.selector), "should match");
        assertEq(facetAddressList[1], ILoupe.facetAddress(IDiamondLoupeFacet.facetFunctionSelectors.selector), "should match");
        assertEq(facetAddressList[1], ILoupe.facetAddress(IDiamondLoupeFacet.facetAddresses.selector), "should match");
        assertEq(facetAddressList[1], ILoupe.facetAddress(IDiamondLoupeFacet.facetAddress.selector), "should match");
        assertEq(facetAddressList[1], ILoupe.facetAddress(IERC165.supportsInterface.selector), "should match");
        assertEq(facetAddressList[2], ILoupe.facetAddress(IERC173.owner.selector), "should match");
        assertEq(facetAddressList[2], ILoupe.facetAddress(IERC173.transferOwnership.selector), "should match");   
    }

    // Tests Add, Replace, and Remove functionality for ExampleFacet
    function test_AddReplaceRemove() public {

        // Deploy another facet
        exampleFacet = new ExampleFacet();

        // We create and populate array of function selectors needed for the cut of ExampleFacet.
        bytes4[] memory exampleSelectors = new bytes4[](5);
        exampleSelectors[0] = ExampleFacet.exampleFunction1.selector;
        exampleSelectors[1] = ExampleFacet.exampleFunction2.selector;
        exampleSelectors[2] = ExampleFacet.exampleFunction3.selector;
        exampleSelectors[3] = ExampleFacet.exampleFunction4.selector;
        exampleSelectors[4] = ExampleFacet.exampleFunction5.selector;

        // Make the cut
        IDiamondCutFacet.FacetCut[] memory cut = new IDiamondCutFacet.FacetCut[](1);

        cut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(exampleFacet),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: exampleSelectors
        });

        // Upgrade diamond with ExampleFacet cut. No need to init anything special/new.
        vm.prank(diamondOwner);
        ICut.diamondCut(cut, address(0x0), "");

        // Update testing variable `facetAddressList` with our new facet by calling `facetAddresses()`.
        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses();

        // 4 facets should now be in the Diamond. And the new one is valid.
        assertEq(facetAddressList.length, 4, "Cut, Loupe, Ownership, ExampleFacet");
        assertNotEq(facetAddressList[3], address(0), "ExampleFacet is not 0x0 address");

        // New facet has the correct function selectors?
        bytes4[] memory loupeViewExample = ILoupe.facetFunctionSelectors(facetAddressList[3]); // ExampleFacet
        assertEq(loupeViewExample[0], ExampleFacet.exampleFunction1.selector, "should match");
        assertEq(loupeViewExample[1], ExampleFacet.exampleFunction2.selector, "should match");
        assertEq(loupeViewExample[2], ExampleFacet.exampleFunction3.selector, "should match");
        assertEq(loupeViewExample[3], ExampleFacet.exampleFunction4.selector, "should match");
        assertEq(loupeViewExample[4], ExampleFacet.exampleFunction5.selector, "should match");

        // Function selectors are associated with the correct facet.
        assertEq(facetAddressList[3], ILoupe.facetAddress(ExampleFacet.exampleFunction1.selector), "should match");  
        assertEq(facetAddressList[3], ILoupe.facetAddress(ExampleFacet.exampleFunction2.selector), "should match"); 
        assertEq(facetAddressList[3], ILoupe.facetAddress(ExampleFacet.exampleFunction3.selector), "should match"); 
        assertEq(facetAddressList[3], ILoupe.facetAddress(ExampleFacet.exampleFunction4.selector), "should match"); 
        assertEq(facetAddressList[3], ILoupe.facetAddress(ExampleFacet.exampleFunction5.selector), "should match"); 

        // We can successfully call the ExampleFacet functions.
        ExampleFacet(address(diamond)).exampleFunction1();
        ExampleFacet(address(diamond)).exampleFunction2();
        ExampleFacet(address(diamond)).exampleFunction3();
        ExampleFacet(address(diamond)).exampleFunction4();
        ExampleFacet(address(diamond)).exampleFunction5();

        // We can successfully replace a function and put it in a different facet.
        bytes4[] memory selectorToReplace = new bytes4[](1);
        selectorToReplace[0] = ExampleFacet.exampleFunction1.selector;

        // Make the cut
        IDiamondCutFacet.FacetCut[] memory replaceCut = new IDiamondCutFacet.FacetCut[](1);

        replaceCut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCutFacet.FacetCutAction.Replace,
            functionSelectors: selectorToReplace
        });

        vm.prank(diamondOwner);
        ICut.diamondCut(replaceCut, address(0), "");

        // The exampleFunction1 now lives in ownershipFacet and not ExampleFacet.
        assertEq(address(ownershipFacet), ILoupe.facetAddress(ExampleFacet.exampleFunction1.selector));

        // Double checking, the Ownership facet now has the new function selector     
        bytes4[] memory loupeViewOwnership = ILoupe.facetFunctionSelectors(facetAddressList[2]); // Ownership
        assertEq(loupeViewOwnership[0], IERC173.owner.selector, "should match");
        assertEq(loupeViewOwnership[1], IERC173.transferOwnership.selector, "should match");
        assertEq(loupeViewOwnership[2], ExampleFacet.exampleFunction1.selector, "should match");

        // The ExampleFacet no longer has access to the exampleFunction1
        vm.expectRevert();
        ExampleFacet(address(diamond)).exampleFunction1();

    
        // We can also remove functions completely by housing them in 0x0.
        bytes4[] memory selectorsToRemove = new bytes4[](2);
        selectorsToRemove[0] = ExampleFacet.exampleFunction2.selector;
        selectorsToRemove[1] = ExampleFacet.exampleFunction3.selector;

        // Make the cut
        IDiamondCutFacet.FacetCut[] memory removeCut = new IDiamondCutFacet.FacetCut[](1);

        removeCut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(0),
            action: IDiamondCutFacet.FacetCutAction.Remove,
            functionSelectors: selectorsToRemove
        });

        // Remove the functions via the removeCut
        vm.prank(diamondOwner);
        ICut.diamondCut(removeCut, address(0), "");

        // Functions cannot be called and no longer exist in the diamond.
        vm.expectRevert();
        ExampleFacet(address(diamond)).exampleFunction2();
        vm.expectRevert();
        ExampleFacet(address(diamond)).exampleFunction3();

        // The exampleFunction2 and 3 now live at 0x0.
        assertEq(address(0), ILoupe.facetAddress(ExampleFacet.exampleFunction2.selector));
        assertEq(address(0), ILoupe.facetAddress(ExampleFacet.exampleFunction3.selector));

        // Note: I have not changed the template in diamond-3 in any meaningful way.
        // Therefore, I did not include the cache bug test here b/c it is fixed in diamond-3.
    }


    // Tests AppStorage with two new facets.
    function test_AppStorage() public {

        facetWithAppStorage = new FacetWithAppStorage();

        IDiamondCutFacet.FacetCut[] memory cut = new IDiamondCutFacet.FacetCut[](1);

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = FacetWithAppStorage.doSomething.selector; 
        selectors[1] = FacetWithAppStorage.doSomethingElse.selector; 
        selectors[2] = FacetWithAppStorage.libraryFunctionOne.selector;
        selectors[3] = FacetWithAppStorage.libraryFunctionTwo.selector;
        selectors[4] = FacetWithAppStorage.getVars.selector; 

        cut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(facetWithAppStorage),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(diamondOwner);
        ICut.diamondCut(cut, address(0x0), "");

        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses

        // Sanity check
        assertEq(facetAddressList.length, 4, "Cut, Loupe, Ownership, FacetWithAppStorage");
        assertNotEq(facetAddressList[3], address(0), "FacetWithAppStorage is not 0x0 address");

        FacetWithAppStorage FWAS = FacetWithAppStorage(address(diamond)); // for ease of use.

        // Do the functions actually update `AppStorage` correctly?
        FWAS.doSomethingElse(5, 7);
        (uint256 one, uint256 two, , , ) = FWAS.getVars();
        assertEq(one, 5, "0+5");
        assertEq(two, 7, "0+7");

        FWAS.doSomething(); 
        ( , , , , uint256 last) = FWAS.getVars();
        assertEq(last, 12, "5+7");

        uint256 c = FWAS.libraryFunctionOne(42, 13);
        assertEq(c, 62, "42+13+7");

        FWAS.libraryFunctionTwo(69, 420);
        ( , , uint256 third, uint256 fourth, ) = FWAS.getVars();
        assertEq(third, 69, "0+69");
        assertEq(fourth, 420, "0+420");

        FWAS.libraryFunctionTwo(69, 420);
        ( , , uint256 thirdAgain, uint256 fourthAgain, ) = FWAS.getVars();
        assertEq(thirdAgain, 138, "69+69");
        assertEq(fourthAgain, 840, "420+420");


        // *********************************************
        // ***** Test AppStorage with Second Facet *****
        // *********************************************

        facetWithAppStorage2 = new FacetWithAppStorage2();

        IDiamondCutFacet.FacetCut[] memory cut2 = new IDiamondCutFacet.FacetCut[](1);

        bytes4[] memory selector = new bytes4[](6);
        selector[0] = FacetWithAppStorage2.getFirstVar.selector;
        selector[1] = FacetWithAppStorage2.changeNestedStruct.selector; 
        selector[2] = FacetWithAppStorage2.changeUnprotectedNestedStruct.selector; 
        selector[3] = FacetWithAppStorage2.viewNestedStruct.selector; 
        selector[4] = FacetWithAppStorage2.viewUnprotectedNestedStruct.selector; 
        selector[5] = FacetWithAppStorage2.getNumber.selector; 

        cut2[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(facetWithAppStorage2),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: selector
        });

        vm.prank(diamondOwner);
        ICut.diamondCut(cut2, address(0x0), "");

        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses

        // Sanity check
        assertEq(facetAddressList.length, 5, "Cut, Loupe, Ownership, FWAS, FWAS2");
        assertNotEq(facetAddressList[4], address(0), "FWAS2 is not 0x0 address");

        // AppStorage should properly persist between multiple facets
        FacetWithAppStorage2 FWAS2 = FacetWithAppStorage2(address(diamond)); // for ease of use.
        assertEq(FWAS2.getFirstVar(), 5, "should match");

        // We can view and change values inside a nested struct protected by a mapping in AppStorage.
        (uint256 var123, uint256 var456, uint256 var789, ExampleEnum exampleEnum) = FWAS2.viewNestedStruct();
        assertEq(var123, 0, "not set yet");
        assertEq(var456, 0, "not set yet");
        assertEq(var789, 0, "not set yet");
        assertEq(uint8(exampleEnum), uint8(ExampleEnum.ENUM_ONE), "not set yet"); // cast Enum to uint8 for equality test

        FWAS2.changeNestedStruct();
        (uint256 _var123, uint256 _var456, uint256 _var789, ExampleEnum _exampleEnum) = FWAS2.viewNestedStruct();
        assertEq(_var123, 123, "set");
        assertEq(_var456, 456, "set");
        assertEq(_var789, 789, "set");
        assertEq(uint8(_exampleEnum), uint8(ExampleEnum.ENUM_TWO), "set"); // cast Enum to uint8 for equality test

        // We can view and change values inside an "unprotected" nested struct in AppStorage.
        (uint256 var69, uint256 var420) = FWAS2.viewUnprotectedNestedStruct();
        assertEq(var69, 0, "not set yet");
        assertEq(var420, 0, "not set yet");

        // Does the example event properly emit and does state get properly updated?
        vm.expectEmit();
        emit FacetWithAppStorage2.ExampleEvent(69, 420);
        FWAS2.changeUnprotectedNestedStruct();
        (uint256 _var69, uint256 _var420) = FWAS2.viewUnprotectedNestedStruct();
        assertEq(_var69, 69, "set");
        assertEq(_var420, 420, "set");      
        
        // Does the example error properly emit?
        vm.expectRevert(abi.encodeWithSelector(FacetWithAppStorage2.ExampleError.selector));
        FWAS2.changeUnprotectedNestedStruct();
    }

    // Deploying & Cutting ERC20Facet, state updates, transfers, approval, error emission, event emission.
    function test_ERC20() public {
        
        erc20Facet = new ERC20Facet();

        IDiamondCutFacet.FacetCut[] memory cut = new IDiamondCutFacet.FacetCut[](1);

        bytes4[] memory selectors = new bytes4[](11);
        selectors[0] = IERC20Facet.initialize.selector; 
        selectors[1] = IERC20Facet.name.selector;
        selectors[2] = IERC20Facet.symbol.selector;
        selectors[3] = IERC20Facet.decimals.selector;
        selectors[4] = IERC20Facet.balanceOf.selector;
        selectors[5] = IERC20Facet.allowance.selector;
        selectors[6] = IERC20Facet.transfer.selector; // ignore any IDE coloring, its ERC20.transfer()
        selectors[7] = IERC20Facet.transferFrom.selector;
        selectors[8] = IERC20Facet.approve.selector;
        selectors[9] = IERC20Facet.mint.selector;
        selectors[10] = IERC20Facet.totalSupply.selector;

        cut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(erc20Facet),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(diamondOwner);
        ICut.diamondCut(cut, address(0x0), "");
        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses
        assertEq(facetAddressList.length, 4, "Cut, Loupe, Ownership, ERC20Facet"); // sanity checks
        assertNotEq(facetAddressList[3], address(0), "ERC20Facet is not 0x0 address"); // sanity checks
        IERC20Facet erc20 = IERC20Facet(address(diamond)); // for ease of use.

        // Alice cannot call initialize
        vm.expectRevert();
        vm.prank(alice);
        erc20.initialize(1000000e18, "MyERC20Facet", "MERC20F");

        // Only owner can initialize
        vm.startPrank(diamondOwner);
        erc20.initialize(1000000e18, "MyERC20Facet", "MERC20F"); 
        assertEq(erc20.name(), "MyERC20Facet", "should be name");
        assertEq(erc20.symbol(), "MERC20F", "should be symbol");
        assertEq(erc20.decimals(), 18, "should be 18 decimals");
        assertEq(erc20.totalSupply(), 1000000e18, "initial supply should be 1M");
        assertEq(erc20.balanceOf(diamondOwner), 1000000e18, "owner should have initial supply");
        
        // Nobody can re-initialize
        vm.expectRevert();
        erc20.initialize(1337e18, "TokenName", "TKN"); // Cannot re-initialize

        // Transfer (AppStorage balance updated properly and emits correct event)
        vm.expectEmit();
        emit IERC20Facet.Transfer(diamondOwner, bob, 69420e18);
        erc20.transfer(bob, 69420e18);

        assertEq(erc20.balanceOf(bob), 69420e18, "should get tokens");
        assertEq(erc20.balanceOf(diamondOwner), 1000000e18-69420e18, "should deduct tokens");
        vm.stopPrank();

        // Transfer fails if u have no tokens (Reverts with correct custom error)
        vm.expectRevert(abi.encodeWithSelector(IERC20Facet.ERC20InsufficientBalance.selector, alice, 0, 1));
        vm.prank(alice);
        erc20.transfer(bob, 1);

        // Owner can mint more coins, but nobody else can.
        vm.prank(diamondOwner);
        erc20.mint(bob, 1337e18);
        vm.prank(alice);
        vm.expectRevert();
        erc20.mint(alice, 1);

        // diamondOwner approves alice to spend some of his tokens.
        vm.prank(diamondOwner);
        erc20.approve(alice, 1000e18);

        // Cannot transferFrom more than allowance
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(IERC20Facet.ERC20InsufficientAllowance.selector, alice, 1000e18, 1001e18));
        erc20.transferFrom(diamondOwner, bob, 1001e18);

        // Can transfer up to amount, but then no more
        erc20.transferFrom(diamondOwner, bob, 1000e18);
        vm.expectRevert(abi.encodeWithSelector(IERC20Facet.ERC20InsufficientAllowance.selector, alice, 0, 1));
        erc20.transferFrom(diamondOwner, bob, 1);

        // Note: These unit tests are not exhaustive b/c ERC20Facet inherits OZ ERC20 template.
        // The only changes were adding `s` for storage on state-changing functions.
        // Once we see the functions work, AppStorage updates, errors, and events are emitting properly
        // Then everything appears to be in good working order.
    }


    // Deploying & Cutting ERC1155Facet, state updates, transfers, approval, error emission, event emission.
    function test_ERC1155() public {
        
        erc1155Facet = new ERC1155Facet();

        IDiamondCutFacet.FacetCut[] memory cut = new IDiamondCutFacet.FacetCut[](1);

        bytes4[] memory selectors = new bytes4[](12);
        selectors[0] = IERC1155Facet.initialize.selector; 
        selectors[1] = IERC1155Facet.setURI.selector;
        selectors[2] = IERC1155Facet.mint.selector;
        selectors[3] = IERC1155Facet.uri.selector;
        selectors[4] = IERC1155Facet.onERC1155Received.selector;
        selectors[5] = IERC1155Facet.onERC1155BatchReceived.selector;
        selectors[6] = IERC1155Facet.balanceOf.selector;
        selectors[7] = IERC1155Facet.balanceOfBatch.selector;
        selectors[8] = IERC1155Facet.setApprovalForAll.selector;
        selectors[9] = IERC1155Facet.isApprovedForAll.selector;
        selectors[10] = IERC1155Facet.safeTransferFrom.selector;
        selectors[11] = IERC1155Facet.safeBatchTransferFrom.selector;

        cut[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(erc1155Facet),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: selectors
        });


        vm.prank(diamondOwner);
        ICut.diamondCut(cut, address(0x0), "");
        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses

        assertEq(facetAddressList.length, 4, "Cut, Loupe, Ownership, ERC1155Facet"); // sanity checks
        assertNotEq(facetAddressList[3], address(0), "ERC1155Facet is not 0x0 address"); // sanity checks
        IERC1155Facet erc1155 = IERC1155Facet(address(diamond)); // for ease of use.

        // Alice cannot call initialize
        vm.expectRevert();
        vm.prank(alice);
        erc1155.initialize("exampleURI");

        // Only owner can initialize
        vm.startPrank(diamondOwner);
        erc1155.initialize("MyERC1155URIString"); 
        assertEq(erc1155.uri(0), "MyERC1155URIString", "should be name");

        // Nobody can re-initialize
        vm.expectRevert();
        erc1155.initialize("Im trying to reinitialize ERC1155");

        // Owner can mint himself 1000 tokens of ID 0.
        // Check that it emits event correctly.
        vm.expectEmit();
        emit IERC1155Facet.TransferSingle(diamondOwner, address(0), diamondOwner, 0, 1000e18);
        erc1155.mint(diamondOwner, 0, 1000e18, "");
        vm.stopPrank();

        // Transfer fails if u have no tokens (Reverts with correct custom error)
        vm.expectRevert(abi.encodeWithSelector(IERC1155Facet.ERC1155InsufficientBalance.selector, alice, 0, 1, 0));
        vm.prank(alice);
        erc1155.safeTransferFrom(alice, bob, 0, 1, "");

        // Transfer (AppStorage balance updated properly and emits correct event)
        vm.prank(diamondOwner);
        vm.expectEmit();
        emit IERC1155Facet.TransferSingle(diamondOwner, diamondOwner, bob, 0, 420e18);
        erc1155.safeTransferFrom(diamondOwner, bob, 0, 420e18, "");
        assertEq(erc1155.balanceOf(diamondOwner, 0), 1000e18-420e18, "should deduct tokens");
        assertEq(erc1155.balanceOf(bob, 0), 420e18, "bob gets 420 tokenID 0");

        // TransferFrom (Bob tries to send diamondOwner tokens but doesn't have approval)
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(IERC1155Facet.ERC1155MissingApprovalForAll.selector, bob, diamondOwner));
        erc1155.safeTransferFrom(diamondOwner, alice, 0, 100e18, "");

        // Gets approval
        vm.prank(diamondOwner);
        vm.expectEmit();
        emit IERC1155Facet.ApprovalForAll(diamondOwner, bob, true);
        erc1155.setApprovalForAll(bob, true);

        // Bob can now send on behalf
        vm.prank(bob);
        vm.expectEmit();
        emit IERC1155Facet.TransferSingle(bob, diamondOwner, alice, 0, 100e18);
        erc1155.safeTransferFrom(diamondOwner, alice, 0, 100e18, "");

        // Note: These unit tests are not exhaustive b/c ERC1155Facet inherits OZ ERC1155 template.
        // The only changes were adding `s` for storage on state-changing functions.
        // Once we see the functions work, AppStorage updates, errors, and events are emitting properly
        // Then everything appears to be in good working order.


        // Deploy FWAS2 to test no storage collisions with AppStorage and OZ ERC1155 inheritance
        // We thwart the AppStorage collisions with AppStorageRoot contract in AppStorage
        // Forcing the AppStorage to always be at slot 0 of a contract.
        facetWithAppStorage2 = new FacetWithAppStorage2();

        IDiamondCutFacet.FacetCut[] memory cut2 = new IDiamondCutFacet.FacetCut[](1);

        bytes4[] memory selector = new bytes4[](6);
        selector[0] = FacetWithAppStorage2.getFirstVar.selector;
        selector[1] = FacetWithAppStorage2.changeNestedStruct.selector; 
        selector[2] = FacetWithAppStorage2.changeUnprotectedNestedStruct.selector; 
        selector[3] = FacetWithAppStorage2.viewNestedStruct.selector; 
        selector[4] = FacetWithAppStorage2.viewUnprotectedNestedStruct.selector; 
        selector[5] = FacetWithAppStorage2.getNumber.selector; 

        cut2[0] = IDiamondCutFacet.FacetCut({
            facetAddress: address(facetWithAppStorage2),
            action: IDiamondCutFacet.FacetCutAction.Add,
            functionSelectors: selector
        });

        vm.prank(diamondOwner);
        ICut.diamondCut(cut2, address(0x0), "");

        facetAddressList = IDiamondLoupeFacet(address(diamond)).facetAddresses(); // save all facet addresses

        FacetWithAppStorage2 FWAS2 = FacetWithAppStorage2(address(diamond)); // for ease of use.

        // Importantly, without `AppStorageRoot`, the `_number` was 0 before. Now it matches.
        uint256 _number = FWAS2.getNumber();
        assertEq(_number, 777, "should match");
    }

}