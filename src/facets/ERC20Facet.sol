// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Note: Only functions that modify traditional ERC20 state need to be overriden to use AppStorage instead.
contract ERC20Facet is ERC20 {
    AppStorage internal s;

    // ERC20 Constructor needed for OpenZeppelin's `name` and `symbol` requirements
    // Owner is expected to immediately call `initialize()` to properly 
    // initialize token during the deployment script.
    constructor() ERC20("", "") {}

    // Constructor Equivalent - Called by diamond owner during deployment to set real token values.
    function initialize(uint256 _initialSupply, string memory name_, string memory symbol_) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(msg.sender == ds.contractOwner, "Must own the diamond");
        require(bytes(name_).length != 0 && bytes(symbol_).length != 0, "Must be nonzero");
        require(bytes(s._name).length == 0 && bytes(s._symbol).length == 0, "Already initialized");

        mint(msg.sender, _initialSupply); // decided to use msg.sender and not _msgSender() here.
        s._name = name_;
        s._symbol = symbol_;
    }


    // ************* PUBLIC FUNCTIONS *************
    // OVERRIDES NOT REQUIRED: [transfer, transferFrom, approve]

    // Custom mint function that we wanted.
    function mint(address to, uint256 amount) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(msg.sender == ds.contractOwner, "Must own the diamond");
        _mint(to, amount);
    }


    // ************* VIEW FUNCTIONS *************

    function name() public view override returns (string memory) {
        return s._name;
    }

    function symbol() public view override returns (string memory) {
        return s._symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return s._totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return (s._balances[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return s._allowances[owner][spender];
    }


    // *********** INTERNAL FUNCTIONS *************
    // OVERRIDES NOT REQUIRED: [_transfer, _mint, _burn, _approve, _spendAllowance, _msgSender]

    // This other _approve function sets state, so it needed an override.
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal override {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        s._allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    // (Handles all transfer/mint/burn functionality)
    function _update(address from, address to, uint256 value) internal override {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            s._totalSupply += value;
        } else {
            uint256 fromBalance = s._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                s._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                s._totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                s._balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

}