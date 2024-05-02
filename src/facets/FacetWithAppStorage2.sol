// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorageRoot, ExampleEnum, InnerStructID} from "../AppStorage.sol";

// Example facet using AppStorage
contract FacetWithAppStorage2 is AppStorageRoot {

    // Errors and events for this example FacetWtihAppStorage2
    event ExampleEvent(uint256 indexed var69, uint256 indexed var420);
    error ExampleError();

    // Shows our getter properly works because AppStorage persists through different facets.
    function getFirstVar() public view returns (uint256) {
        return s.firstVar;
    }

    // Shows ability to work with nested struct values inside AppStorage protected by a mapping.
    function changeNestedStruct() public {
        s.ns[InnerStructID.ONE].var123 = 123;
        s.ns[InnerStructID.ONE].var456 = 456;
        s.ns[InnerStructID.ONE].var789 = 789;
        s.ns[InnerStructID.ONE].exampleEnum = ExampleEnum.ENUM_TWO;
    }

    // Shows ability to use "unprotected" inner struct without a mapping
    function changeUnprotectedNestedStruct() public {
        if (s.uns.var69 == 69) revert ExampleError();
        s.uns.var69 = 69;
        s.uns.var420 = 420;
        emit ExampleEvent(s.uns.var69, s.uns.var420);
    }

    // Shows ability to view nested struct values inside AppStorage
    function viewNestedStruct() public view returns (uint256, uint256, uint256, ExampleEnum) {
        return (
            s.ns[InnerStructID.ONE].var123, 
            s.ns[InnerStructID.ONE].var456, 
            s.ns[InnerStructID.ONE].var789, 
            s.ns[InnerStructID.ONE].exampleEnum
        );
    }

    // Shows ability to view unprotected nested struct inside AppStorage
    function viewUnprotectedNestedStruct() public view returns (uint256, uint256) {
        return (s.uns.var69, s.uns.var420);
    }

    // Used to test AppStorage is in proper place in ERC1155Facet
    function getNumber() external view returns (uint256) {
        return s.number;
    }

}