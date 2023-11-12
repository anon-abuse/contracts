// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AnonAbuse.sol";
import "../test/lib/Loader.sol";

contract CounterScript is Script, Loader {

    UserData[] public userDatas;

    function setUp() public {
        string memory root = vm.projectRoot();
        for (uint i = 0; i < 8; i++) {
            userDatas.push(loadUserData(root, i));
        }
        
    }

    function run() public {
        vm.broadcast();
    }
}
