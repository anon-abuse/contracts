// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Groth16Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

contract AnonAbuse {
    
    /// treeMetaData structure, includes
    /// merkle root of the group tree
    /// as well as every leaf node in list format  
    struct treeMetaData {
        bytes32 merkleRoot;
        address[] hackedAddresses;
    }

    /// Mapping from the address of the stealer casted to uint256 
    /// to treeMetaData
    mapping(uint256 => treeMetaData) public treeMetaDataByID;

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  EVENTS                                 ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when a group is added to the router.
    ///
    /// @param groupId The identifier for the group.
    /// @param merkleRoot of the created tree. 
    event GroupAdded(uint256 indexed groupId, bytes32 indexed merkleRoot);

    /// @notice Emitted when a group is updated in the router.
    ///
    /// @param groupId The identitfier for the group.
    /// @param oldMerkleRoot the previous merkle root
    /// @param newMerkleRoot the new merkle root
    event GroupUpdated(
        uint256 indexed groupId,
        bytes32 indexed oldMerkleRoot,
        bytes32 indexed newMerkleRoot 
    );

    // Getter functions
    function getLeafsromAttackerAddress(address attacker_address) external view returns (address[] memory) {
        return treeMetaDataByID[getGroupdIdFromAttackerAddress(attacker_address)].hackedAddresses;
    }

    function getGroupdIdFromAttackerAddress(address attacker_address) 
    internal
    pure
    returns (uint256)
    {
        return uint256(uint160(attacker_address));
    }

    function getLeafsromGroupID(uint256 groupID) external view returns (address[] memory) {
        return treeMetaDataByID[groupID].hackedAddresses;
    }

    // Setter functions
    function entryPoint(
        // Groth16Proof memory rugProof,
        // Groth16Proof memory groupMerkleTreeConstruction,
        bytes32 groupMerkleRoot,
        address hackerAddress,
        address attackedAddress
    )
    public
    {

    uint256 hackerAddressAsUint = getGroupdIdFromAttackerAddress(hackerAddress);

    //require valid rugProof from Risc0 Bonsai VM
    // require(verifySignature(rugProof.a, rugProof.b, rugProof.c, groupMerkleRoot,
    //                         hackerAddress), "Invalid Risc0 Proof");

    // Check if hackerAddress is already present in the mapping
    if (treeMetaDataByID[hackerAddressAsUint].merkleRoot != bytes32(0)) {
        // hackerAddress is present, so update the corresponding value
        updateTreeMetaDataByID(hackerAddressAsUint, groupMerkleRoot, attackedAddress);
        emit GroupAdded(hackerAddressAsUint,  groupMerkleRoot);
    } else {
        // hackerAddress is not present, so create a new key-value pair
        bytes32 oldMerkleRoot = treeMetaDataByID[hackerAddressAsUint].merkleRoot;
        updateTreeMetaDataByID(hackerAddressAsUint, groupMerkleRoot, attackedAddress);
        emit GroupUpdated(hackerAddressAsUint, oldMerkleRoot, groupMerkleRoot);
    }   
    }

    function updateTreeMetaDataByID(uint256 id, bytes32 merkle_root, address attacked_address)
    internal
    {
        treeMetaDataByID[id].merkleRoot = merkle_root;
        treeMetaDataByID[id].hackedAddresses.push(attacked_address);
    }

}
