// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AnonAbuse.sol";
import "../test/lib/Loader.sol";

contract AnonAbuseScript is Script, Loader {

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
    }

    function run() public {

        fundAttackedAddressPreAttack();

        logBalances("pre-attack state");

        vm.startBroadcast();

        populateContractStructure();

        vm.stopBroadcast();
    }


    function fundAttackedAddressPreAttack() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            vm.deal(userDatas[i].compressedPublicKey, 1 ether);
        }
    }

    function drainAttackedAddress() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            uint256 pk = uint256(userDatas[i].privateKey);
            vm.startBroadcast(pk);
            address targetAddress = address(0x00000000000000000000);
            payable(targetAddress).transfer(1 ether);
            vm.stopBroadcast();
        }
    }

    function randomHackerAddress() internal view returns (address) {
        // Generate a random uint256 and cast it to an address
        return address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, block.number, msg.sender)))));
    }

    function populateContractStructure() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            address currentHackedAddress = userDatas[i].compressedPublicKey;
            bytes32 groupMerkleRoot = keccak256(abi.encodePacked(block.timestamp, block.difficulty, currentHackedAddress));
            address zeroAddress = address(0x00000000000000000000);
            anonAbuse.entryPoint(groupMerkleRoot, zeroAddress, currentHackedAddress);
        }
    }

    function logBalances(string memory state) public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            // Retrieve the balance of each address
            uint balance = userDatas[i].compressedPublicKey.balance;

            // Log the balance to the console
            console.log(state);
            console.log("Address:", userDatas[i].compressedPublicKey);
            console.log("Balance:", balance);
        }
    }
}
