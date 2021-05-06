// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SmartWallet {
    mapping(address => uint256) private _balances;
    address private _creator;
    uint256 private _tax;
    uint256 private _gain;
    
    constructor(uint256 tax_) {
        require(tax_ <= 100, "SmartWallet: tax cannot exceed 100%");
        _creator = msg.sender;
        _tax = tax_;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }
    
    function withdrawAll() public {
        require(_balances[msg.sender] > 0, "SmartWallet: can no withdraw 0 ether");
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        if (msg.sender != _creator) {
            uint256 gain = amount * _tax / 100;
            amount -= gain;
            _gain += gain;
            _balances[_creator] += gain;
        }
        payable(msg.sender).transfer(amount);
    }
    
    function withdraw(uint256 amount) public {
        require(_balances[msg.sender] >= amount, "SmartWallet: you don't have enough funds in this account to withdraw");
        _balances[msg.sender] -= amount;
        if (msg.sender != _creator) {
            uint256 gain = amount * _tax / 100;
            amount -= gain;
            _gain += gain;
            _balances[_creator] += gain;
        }
        payable(msg.sender).transfer(amount);
    }
    
    function transfer(address account, uint256 amount) public {
        require(_balances[msg.sender] >= amount, "SmartWallet: you don't have enough funds in this account to transfer");
        _balances[msg.sender] -= amount;
        _balances[account] += amount;
    }
    
    function total() public view returns (uint256) {
        return address(this).balance;
    }
    
    function setTax(uint256 newTax) public {
        require(msg.sender == _creator, "SmartWallet: You are not the creator of this smart contract");
        require(newTax <= 100, "SmartWallet: tax cannot exceed 100%");
        _tax = newTax;
    }
    
    function viewCreator() public view returns (address) {
        return _creator;
    }
    
    function viewTax() public view returns (uint256) {
        return _tax;
    }
    
    function viewGain() public view returns (uint256) {
        return _gain;
    }
    
    function resetGain() public {
        require(msg.sender == _creator, "SmartWallet: You are not the creator of this smart contract");
        _gain = 0;
    }
    
}