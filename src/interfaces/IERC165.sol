// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC165 {
    // Does a contract implement an interface?
    // interfaceId is the identifier specified in ERC-165
    // returns `true if contract implements `interfaceId` and `interfaceID` is not 0xffffffff, `false` otherwise.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}