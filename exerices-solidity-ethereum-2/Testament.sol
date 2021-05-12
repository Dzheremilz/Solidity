// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract Testament {
    using Address for address payable;

    address private _owner;
    address private _doctor;
    bool private _isDead;
    mapping(address => uint256) _beneficiaries;

    event Bequeathed(address indexed benefactor, uint256 amount);
    event Withdrew(address indexed benefactor);

    constructor(address owner_, address doctor_) {
        _owner = owner_;
        _doctor = doctor_;
    }

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Testament: Your are not the owner of this contract"
        );
        _;
    }

    modifier onlyAlive() {
        require(!_isDead, "Testament: Sorry you are dead, probably");
        _;
    }

    modifier onlyDoctor() {
        require(
            msg.sender == _doctor,
            "Testament: you are not the doctor of this contract"
        );
        _;
    }

    function quoteShare() public {
        require(_isDead, "Testament: the owner is still alive, be patient");
        require(
            _beneficiaries[msg.sender] > 0,
            "Testament: Sorry there is nothing for you"
        );
        uint256 amount = _beneficiaries[msg.sender];
        _beneficiaries[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender);
    }

    function setDoctor(address newDoctor) public onlyOwner onlyAlive {
        _doctor = newDoctor;
    }

    function passAway() public onlyDoctor {
        _isDead = true;
    }

    function bequeath(address account, uint256 amount)
        public
        payable
        onlyOwner
        onlyAlive
    {
        _beneficiaries[account] += amount;
        emit Bequeathed(account, amount);
    }
}
