// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract Birthday {
    using Address for address payable;

    address private _receiver;
    uint256 private _today;
    uint256 private _dayBeforeBirthday;

    event Received(address sender, uint256 amount);

    constructor(address receiver_, uint256 dayBeforeBirthday_) {
        _receiver = receiver_;
        _today = block.timestamp;
        _dayBeforeBirthday = dayBeforeBirthday_;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function offer() public payable {
        emit Received(msg.sender, msg.value);
    }

    function getPresent() public payable {
        require(
            msg.sender == _receiver,
            "Birthday: you are not the person for whom this contract is intended"
        );
        require(
            block.timestamp >= _today + _dayBeforeBirthday * 1 days,
            "Birthday: this is not the right time yet"
        );
        payable(msg.sender).sendValue(address(this).balance);
    }
}
