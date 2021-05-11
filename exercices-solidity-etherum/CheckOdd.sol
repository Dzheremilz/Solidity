// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CheckOdd {
    function check(uint256 isOdd) public pure returns (bool odd) {
        return isOdd % 2 != 0;
    }
}
