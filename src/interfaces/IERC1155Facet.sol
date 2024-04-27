// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Inheriting interfaces from OZ didn't allow tests to get function selectors the way I like.
// So I chose to manually copy-paste the needed ERC1155 interfaces instead.
interface IERC1155Facet {

    // Custom functions/events/errors we built
    function initialize(string memory uri_) external;
    function setURI(string memory newuri) external;
    function mint(address to, uint256 id, uint256 value, bytes memory data) external;

    // ************* OpenZeppelin ERC1155 Standard Interfaces *************

    // IERC1155: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external;

    // IERC1155MetadataURI: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol
    function uri(uint256 id) external view returns (string memory);

    // IERC1155Receiver: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);
    function onERC1155BatchReceived(
        address operator, 
        address from, 
        uint256[] calldata ids, 
        uint256[] calldata values, 
        bytes calldata data
    ) external returns (bytes4);

    // IERC1155Errors: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/draft-IERC6093.sol
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}