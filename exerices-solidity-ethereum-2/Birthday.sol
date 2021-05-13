// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract Birthday {
    using Address for address payable;

    address private _receiver;
    uint256 private _dateBirthday;

    event Received(address indexed sender, uint256 amount);

    constructor(address receiver_, uint256 dayBeforeBirthday) {
        _receiver = receiver_;
        _dateBirthday = block.timestamp + (dayBeforeBirthday * 1 minutes); // change by 'days', use minutes for test purpose
    }

    receive() external payable {
        require(block.timestamp < _dateBirthday, "Birthday: it's too late");
        require(msg.value > 0, "Birthday: you cannot send 0 ether");
        emit Received(msg.sender, msg.value);
    }

    function offer() public payable {
        require(block.timestamp < _dateBirthday, "Birthday: it's too late");
        require(msg.value > 0, "Birthday: you cannot send 0 ether");
        emit Received(msg.sender, msg.value);
    }

    function getPresent() public payable {
        require(
            msg.sender == _receiver,
            "Birthday: you are not the person for whom this contract is intended"
        );
        require(
            block.timestamp >= _dateBirthday,
            "Birthday: this is not the right time yet"
        );
        //payable(msg.sender).sendValue(address(this).balance);
        selfdestruct(payable(msg.sender)); // no, bad idea, when you selfdestruct states variables lose their data
    }
}
