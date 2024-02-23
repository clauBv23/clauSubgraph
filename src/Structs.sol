// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct Member {
    bytes32 id;
    string name;
    address adminAddr;
}

struct Organization {
    bytes32 id;
    string name;
    address owner;
}
