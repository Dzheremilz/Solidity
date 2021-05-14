// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/// @title King of the hill
/// @author Dzheremilz
/// @notice This is a king of the hill game where people can bet ether
/// @dev For this contract we use some import from OpenZeppelin (Address, Ownable)
contract KingOfTheHill is Ownable {
    ///@dev we attach function from the Address library to the address payable type
    using Address for address payable;

    address private _potOwner;
    uint256 private _blockNumberToWin;

    /// @notice some event to call when the king change or someone win the game
    event KingChanged(address indexed newKing);
    event Won(address indexed winner, uint256 amount);

    /**
     * @notice we use a constructor payable to send ether at the deploy time,
     * not less than 1 finney
     */
    constructor() payable {
        require(
            msg.value >= 1e15,
            "KingOfTheHill: send at least 1 finney to begin the war"
        );
        _potOwner = msg.sender;
        _blockNumberToWin = block.number + 6;
        emit KingChanged(msg.sender);
    }

    modifier atLeastDouble() {
        require(
            msg.value >= (address(this).balance - msg.value) * 2,
            "KingOfTheHill: you did not send enough ether to become the King"
        );
        _;
    }

    modifier notPotOwner() {
        require(
            msg.sender != _potOwner,
            "KingOfTheHill: You already are the King"
        );
        _;
    }

    modifier notOwner() {
        require(
            msg.sender != owner(),
            "KingOfTheHill: sorry myself you cannot play this game"
        );
        _;
    }

    receive() external payable notOwner notPotOwner atLeastDouble {
        _potOffering(msg.sender, msg.value);
    }

    function potOffering() external payable notOwner notPotOwner atLeastDouble {
        _potOffering(msg.sender, msg.value);
    }

    function blockNumber() external view returns (uint256) {
        return block.number;
    }

    function blockNumberToWin() external view returns (uint256) {
        return _blockNumberToWin;
    }

    function pot() external view returns (uint256) {
        return address(this).balance;
    }

    function pot2() external view returns (uint256) {
        return address(this).balance * 2;
    }

    function potOwner() external view returns (address) {
        return _potOwner;
    }

    function _potOffering(address account, uint256 amount) private {
        uint256 currentPot = address(this).balance - amount;
        if (_blockNumberToWin <= block.number) {
            payable(_potOwner).sendValue((currentPot * 80) / 100);
            payable(owner()).sendValue((currentPot * 10) / 100);
            uint256 seed = address(this).balance - amount;
            uint256 value = seed * 2;
            uint256 sendBack = amount - value;
            payable(account).sendValue(sendBack);
            emit Won(_potOwner, (currentPot * 80) / 100);
        } else {
            uint256 value = currentPot * 2;
            uint256 sendBack = amount - value;
            if (sendBack > 0) {
                payable(account).sendValue(sendBack);
            }
        }
        _potOwner = account;
        _blockNumberToWin = block.number + 6;
        emit KingChanged(account);
    }
}
