// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract PayableCalculator {
    using Address for address payable;

    address private _owner;
    uint256 private _gain;
    uint256 private _count;

    constructor(address owner_) {
        _owner = owner_;
    }

    //Modifier

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Ownable: Only owner can call this function"
        );
        _;
    }

    modifier paymentValue() {
        require(
            msg.value == 1e15,
            "PayableCalculator: You need to pay 1 finney to use this calculator"
        );
        _gain += msg.value;
        _count += 1;
        _;
    }

    //withdraw
    function withdraw() public onlyOwner {
        require(_gain > 0, "PayableCalculator: can not withdraw 0 ether");
        uint256 amount = _gain;
        _gain = 0;
        payable(msg.sender).sendValue(amount);
    }

    function gain() public view returns (uint256) {
        return _gain;
    }

    function count() public view returns (uint256) {
        return _count;
    }

    //calc

    function add(int256 nb1, int256 nb2)
        public
        payable
        paymentValue
        returns (int256 result)
    {
        return nb1 + nb2;
    }

    function sub(int256 nb1, int256 nb2)
        public
        payable
        paymentValue
        returns (int256 result)
    {
        return nb1 - nb2;
    }

    function mul(int256 nb1, int256 nb2)
        public
        payable
        paymentValue
        returns (int256 result)
    {
        return nb1 * nb2;
    }

    function div(int256 nb1, int256 nb2)
        public
        payable
        paymentValue
        returns (int256 result)
    {
        require(nb2 != 0, "Calculator: can not divide by zero");
        return nb1 / nb2;
    }

    function mod(int256 nb1, int256 nb2)
        public
        payable
        paymentValue
        returns (int256 result)
    {
        return nb1 % nb2;
    }
}
