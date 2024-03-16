//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 public value;

    function store(uint256 _value) public {
        value = _value;
    }

    function inc(uint256 x) public {
        value = value + x;
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}