// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */


 interface IMultiSigContract  {
    function addOwner(address owner, string calldata ownerInfo) external;
    function removeOwner(address owner) external;
    function validateOwner(address owner) external;
    function rejectOwner(address owner) external;

    function changeMinOwners(uint newMinOwners) external;
    function validateMinOwners() external;
    function rejectMinOwners() external;

    function retrieveOwner(address owner) external view returns (string memory, bool);
    function retrieveAllOwners() external view returns (bytes32[] memory);
    function retrieveMinOwners() external view returns (uint);
    function retrievePendingOwners(bool addedORremove) external view returns (bytes32[] memory, string[] memory);
    function retrievePendingMinOwners() external view returns (uint);
}