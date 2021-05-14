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

    /**
     * @notice some modifier:
     * - atLeastDouble : Check the value send to become the next King, it must be twice the actual pot (contract balance)
     * - notPotOwner : Check the actual King is not bidding on himself
     * - notOwner : The owner of the contract cannot play his own game, he already gain 10% of the pot on victory
     */

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

    /**
     * @notice receive function and potOffering are use to take in the ether from player
     * @dev the address and value receive are transmitted to the private function _potOffering,
     * the principal function of our contract
     */

    receive() external payable notOwner notPotOwner atLeastDouble {
        _potOffering(msg.sender, msg.value);
    }

    function potOffering() external payable notOwner notPotOwner atLeastDouble {
        _potOffering(msg.sender, msg.value);
    }

    /**
     * @notice some view function use to display (return) the state of our contract:
     * - blockNumber : the actual block number
     * - blockNumberToWin : the block to reach for the king to win
     * - pot: the actual balance of the contract
     * - pot2: twice the actual balance, the value to send to become the next King
     * - potOwner: address of the actual pot owner (king)
     */

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

    /**
     * @notice our core function: _potOffering, the function manages 2 distinct cases:
     * - if _blockNumberToWin <= block.number == true
     * it mean the previous king has won, the function then need to distribute the price between the king (80% of the pot),
     * the owner of the contract (10%) and the seed (the remaining 10%), use has the next turn of this game. The new King is refund the difference
     * between the ether sent and the amount use for the new pot.
     * - else
     * the bidder become the new king and if necessary is refund the difference between his bid and twice the pot (bid - pot * 2 = refund value)
     *
     * finally the new king is crowned, the new block number to reach is setup and a new turn begin
     */

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
