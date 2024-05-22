// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {ERC1155, Arrays} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AppStorageRoot} from "../AppStorage.sol";

// Note: Only functions that modify traditional ERC1155 state need to be overriden to use AppStorage instead.
// Note: `AppStorageRoot` MUST be inherited first to ensure AppStorage is at slot 0.
contract ERC1155Facet is AppStorageRoot, ERC1155 {

    // Needed for `unsafeMemoryAccess()` library function. Comes with OZ's ERC1155.
    using Arrays for uint256[];
    using Arrays for address[];
    
    // ERC1155 Constructor needed for OpenZeppelin's `uri` requirement.
    // Owner is expected to immediately call `initialize()` to properly 
    // initialize token(s) uri during the deployment script.
    constructor() ERC1155("") {}

    // Constructor Equivalent - Called by diamond owner during deployment to set real token values.
    function initialize(string memory uri_) external {
        LibDiamond.enforceIsContractOwner();
        require(bytes(uri_).length != 0, "Must be nonzero");
        require(bytes(s._uri).length == 0, "Already initialized");
        _setURI(uri_);
        s.number = 777;
    }

    // ************* PUBLIC FUNCTIONS *************
    // OVERRIDES NOT REQUIRED: [setApprovalForAll, safeTransferFrom, safeBatchTransferFrom]

    function setURI(string memory newuri) external {
        LibDiamond.enforceIsContractOwner();
        _setURI(newuri);
    }

    function mint(address to, uint256 id, uint256 value, bytes memory data) external {
        LibDiamond.enforceIsContractOwner();
        _mint(to, id, value, data);
    }

    // ************* VIEW FUNCTIONS *************
    // OVERRIDES NOT REQUIRED: [supportsInterface, balanceOfBatch]

    function uri(uint256 /* id */) public view override returns (string memory) {
        return s._uri;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        return s._erc1155balances[id][account];
    }
    
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return s._operatorApprovals[account][operator];
    }


    /* ************* INTERNAL FUNCTIONS *************
    OVERRIDES NOT REQUIRED: [
        _updateWithAcceptanceCheck, 
        _safeTransferFrom, 
        _safeBatchTransferFrom, 
        _mint, 
        _mintBatch, 
        _burn, 
        _burnBatch, 
        _asSingletonArrays
    ]
    */

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override {
        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids.unsafeMemoryAccess(i);
            uint256 value = values.unsafeMemoryAccess(i);

            if (from != address(0)) {
                uint256 fromBalance = s._erc1155balances[id][from];
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
                }
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    s._erc1155balances[id][from] = fromBalance - value;
                }
            }

            if (to != address(0)) {
                s._erc1155balances[id][to] += value;
            }
        }

        if (ids.length == 1) {
            uint256 id = ids.unsafeMemoryAccess(0);
            uint256 value = values.unsafeMemoryAccess(0);
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }

    function _setURI(string memory newuri) internal override {
        s._uri = newuri;
    } 

    function _setApprovalForAll(address owner, address operator, bool approved) internal override {
        if (operator == address(0)) {
            revert ERC1155InvalidOperator(address(0));
        }
        s._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

}