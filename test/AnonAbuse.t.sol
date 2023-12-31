// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/AnonAbuse.sol";
import "./lib/Loader.sol";

contract AnonAbuseTest is Test, Loader {
    AnonAbuse public anonAbuse;
    uint256 constant NUM_TESTS = 8;
    address[] hackedAddress;
    address hackerAddress;
    bytes32 groupMerkleRoot;

    UserData[] public userDatas;

    function setUp() public {
        anonAbuse = new AnonAbuse();
        populateContractStructure();
        
        string memory root = vm.projectRoot();
        for (uint i = 0; i < NUM_TESTS; i++) {
            userDatas.push(loadUserData(root, i));
            console.logBytes32(userDatas[i].privateKey);
            console.logBytes(userDatas[i].uncompressedPublicKey);
            console.log(userDatas[i].compressedPublicKey);
        }
    }

    function populateContractStructure() public {
        hackerAddress = randomHackerAddress();
        groupMerkleRoot = keccak256(abi.encodePacked(block.timestamp, block.difficulty, hackerAddress));
        for (uint i = 0; i < NUM_TESTS; i++) {
            address currentHackedAddress = randomHackerAddress();
            anonAbuse.entryPoint(groupMerkleRoot, hackerAddress, currentHackedAddress);
            hackedAddress.push(currentHackedAddress);
        }

    }

    function randomHackerAddress() internal view returns (address) {
        // Generate a random uint256 and cast it to an address
        return address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, block.number, msg.sender)))));
    }

    //Testing that
    //1. The data is handled correctly, as in the getters return what we expect;
        //a. generate a set of addresses;
        //b. generates roots that for which root[i] is equal to tree while it's populated by
        //   addresses[:i]
        //c. Assert equality between expected roots at each stage;
    //2. the verifier works well;

    function testGetters() public {
        // Retrieve the merkleRoot for this groupId
        address[] memory leafs = anonAbuse.getLeavesFromAttackerAddress(hackerAddress);

        for (uint i = 0; i < NUM_TESTS; i++) {
            assertEq(hackedAddress[i], leafs[i]);
        }
    }

}

