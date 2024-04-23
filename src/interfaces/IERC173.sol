// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// ERC-165 identifier for this interface is `0x7f5828d0`
interface IERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address owner_);
    function transferOwnership(address _newOwner) external;
}