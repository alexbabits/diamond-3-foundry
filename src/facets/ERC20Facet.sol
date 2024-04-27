// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AppStorage} from "../AppStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20Facet} from "../interfaces/IERC20Facet.sol";

// Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
// Any function that modifies traditional ERC20 state needs to now use AppStorage instead.
contract ERC20Facet is IERC20Facet {
    AppStorage internal s;

    // Constructor Equivalent
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

    function transfer(address to, uint256 value) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function mint(address to, uint256 amount) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(msg.sender == ds.contractOwner, "Must own the diamond");
        _mint(to, amount);
    }


    // ************* VIEW FUNCTIONS *************

    function name() public view returns (string memory) {
        return s._name;
    }

    function symbol() public view  returns (string memory) {
        return s._symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return s._totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return (s._balances[account]);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return s._allowances[owner][spender];
    }


    // ************* INTERNAL FUNCTIONS ************* 

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal {
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

    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function _update(address from, address to, uint256 value) internal {
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

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

}