// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AnonAbuse.sol";
import "../test/lib/Loader.sol";

contract CounterScript is Script, Loader {

    UserData[] public userDatas;
    AnonAbuse public anonAbuse;
    address attackerAddress;

    uint256 constant NUM_ADDRESS = 8;

    function setUp() public {
        anonAbuse = new AnonAbuse();

        string memory root = vm.projectRoot();
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            userDatas.push(loadUserData(root, i));
        }

        attackerAddress = randomHackerAddress();

        console.log(attackerAddress);
    }

    function run() public {
        setUp();

        vm.startBroadcast();

        populateContractStructure();

        vm.stopBroadcast();
    }

    function randomHackerAddress() internal view returns (address) {
        // Generate a random uint256 and cast it to an address
        return address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, block.number, msg.sender)))));
    }

    function populateContractStructure() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            address currentHackedAddress = userDatas[i].compressedPublicKey;
            bytes32 groupMerkleRoot = keccak256(abi.encodePacked(block.timestamp, block.difficulty, attackerAddress));
            anonAbuse.entryPoint(groupMerkleRoot, attackerAddress, currentHackedAddress);
        }

    }
}
