// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact hello@vialabs.io
contract Usdc is ERC20, ERC20Pausable, Ownable, ERC20Permit {
    // @note ERC20Permit implements EIP712, that wants an immutable name as part of the domain separator
    error Usdc__Blacklisted(address sender);
    error Usdc__NotAMinter();

    string private _tokenName;
    string private _tokenSymbol;
    mapping(address => bool) private _minters;
    mapping(address => bool) private _blacklist;

    event Name(string name);
    event Symbol(string symbol);
    event Minter(address indexed addr, bool status);
    event Blacklist(address indexed addr, bool status);

    modifier onlyMinters() {
        if (!isMinter(msg.sender)) revert Usdc__NotAMinter();
        _;
    }

    modifier notBlacklisted(address addr) {
        if (isBlacklist(addr)) revert Usdc__Blacklisted(addr);
        _;
    }

    constructor(
        string memory tName,
        string memory tSymbol
    ) ERC20(tName, tSymbol) Ownable() ERC20Permit(tName) {
        _tokenName = tName;
        _tokenSymbol = tSymbol;
    }

    function setName(string calldata tName) external onlyOwner {
        _tokenName = tName;
    }

    function setSymbol(string calldata tSymbol) external onlyOwner {
        _tokenSymbol = tSymbol;
    }

    function setMinter(address addr, bool status) external onlyOwner {
        _minters[addr] = status;

        emit Minter(addr, status);
    }

    function setBlacklist(address addr, bool status) external onlyOwner {
        _blacklist[addr] = status;

        emit Blacklist(addr, status);
    }

    function mint(
        address to,
        uint256 amount
    ) external onlyMinters whenNotPaused returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(uint256 amount) external onlyMinters whenNotPaused {
        _burn(msg.sender, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function name() public view override returns (string memory) {
        return _tokenName;
    }

    function symbol() public view override returns (string memory) {
        return _tokenSymbol;
    }

    function isMinter(address addr) public view returns (bool) {
        return _minters[addr];
    }

    function isBlacklist(address addr) public view returns (bool) {
        return _blacklist[addr];
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {}

    // function _update(
    //     address from,
    //     address to,
    //     uint256 value
    // ) internal override(ERC20, ERC20Pausable) {
    //     super._update(from, to, value);
    // }
}
