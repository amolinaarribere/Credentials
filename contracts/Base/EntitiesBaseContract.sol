// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

import "../Libraries/Library.sol";
import "../Libraries/AddressLibrary.sol";
import "../Libraries/ItemsLibrary.sol";

contract EntitiesBaseContract{
    using Library for *;
    using AddressLibrary for *;
    using ItemsLibrary for *;

    //events
    event _AddEntityValidationIdEvent(string indexed,  address indexed,  string indexed);
    event _RemoveEntityValidationIdEvent(string indexed,  address indexed,  string indexed);
    event _AddEntityRejectionIdEvent(string indexed,  address indexed,  string indexed);
    event _RemoveEntityRejectionIdEvent(string indexed,  address indexed,  string indexed);

    // owners
    uint _ownerId;
    uint256 _minOwners;

    // Total Owners and other Entities
    ItemsLibrary._ItemsStruct[] _Entities;
    string[] _entitiesLabel;

    // modifiers
    modifier isIdCorrect(uint Id, uint length){
        require(true == Library.IdCorrect(Id, length), "EC1");
        _;
    }

    modifier isAnOwner(){
        require(true == isEntity(msg.sender, _ownerId), "EC9");
        _;
    }
    
    modifier HasNotAlreadyVoted(address entity, uint listId){
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        require(false == ItemsLibrary.hasVoted(msg.sender, entityInBytes, _Entities[listId]), "EC5");
        _;
    }
    
    modifier isEntityActivated(bool YesOrNo, address entity, uint listId){
        if(false == YesOrNo) require(false == isEntity(entity, listId), "EC6");
        else require(true == isEntity(entity, listId), "EC7");
        _;
    }

    modifier isEntityPending(bool YesOrNo, address entity, uint listId){
        if(false == YesOrNo) require(false == isEntityPendingToAdded(entity, listId) && 
                                    false == isEntityPendingToRemoved(entity, listId), "EC27");
        else require(true == isEntityPendingToAdded(entity, listId) || 
                    true == isEntityPendingToRemoved(entity, listId), "EC28");
        _;
    }

    modifier isEntityPendingToAdd(bool YesOrNo, address entity, uint listId){
        if(false == YesOrNo) require(false == isEntityPendingToAdded(entity, listId), "EC27");
        else require(true == isEntityPendingToAdded(entity, listId), "EC28");
        _;
    }

    modifier isEntityPendingToRemove(bool YesOrNo, address entity, uint listId){
        if(false == YesOrNo) require(false == isEntityPendingToRemoved(entity, listId), "EC27");
        else require(true == isEntityPendingToRemoved(entity, listId), "EC28");
        _;
    }

    // Entities functions
    function addEntity(address entity, string calldata entityInfo, uint listId) internal 
        isIdCorrect(listId, _Entities.length) 
        isAnOwner
        isEntityActivated(false, entity, listId) 
        isEntityPendingToAdd(false, entity, listId)
    { 
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(entityInBytes, _minOwners, _entitiesLabel[listId], listId, true);
        ItemsLibrary._ItemsStruct storage itemsstruct =  _Entities[listId];
        ItemsLibrary.addItem(manipulateItemStruct, entityInfo, itemsstruct);
    }

    function removeEntity(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length) 
        isAnOwner
        isEntityActivated(true, entity, listId)
        isEntityPendingToRemove(false, entity, listId)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(entityInBytes, _minOwners, _entitiesLabel[listId], listId, true);
        ItemsLibrary._ItemsStruct storage itemsstruct =  _Entities[listId];
        ItemsLibrary.removeItem(manipulateItemStruct, itemsstruct);
    }

    function validateEntity(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length) 
        isAnOwner 
        isEntityPending(true, entity, listId)
        HasNotAlreadyVoted(entity, listId)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(entityInBytes, _minOwners, _entitiesLabel[listId], listId, true);
        ItemsLibrary._ItemsStruct storage itemsstruct =  _Entities[listId];
        ItemsLibrary.validateItem(manipulateItemStruct, itemsstruct);
    }

    function rejectEntity(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length) 
        isAnOwner 
        isEntityPending(true, entity, listId)
        HasNotAlreadyVoted(entity, listId)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(entityInBytes, _minOwners, _entitiesLabel[listId], listId, true);
        ItemsLibrary._ItemsStruct storage itemsstruct =  _Entities[listId];
        ItemsLibrary.rejectItem(manipulateItemStruct, itemsstruct); 
    }

    function retrieveEntity(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length)
    view returns (string memory, bool) 
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        return ItemsLibrary.retrieveItem(entityInBytes, _Entities[listId]);
    }

    function retrieveAllEntities(uint listId) internal 
        isIdCorrect(listId, _Entities.length) 
    view returns (address[] memory) 
    {
        return AddressLibrary.BytesArrayToAddress(ItemsLibrary.retrieveAllItems(_Entities[listId]));
    }

    function isEntity(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length)
    view returns (bool)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        return ItemsLibrary.isItem(entityInBytes, _Entities[listId]);
    }

    function isEntityPendingToAdded(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length)
    view returns (bool)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        return ItemsLibrary.isItemPendingToAdded(entityInBytes,_Entities[listId]);
    }

    function isEntityPendingToRemoved(address entity, uint listId) internal 
        isIdCorrect(listId, _Entities.length)
    view returns (bool)
    {
        bytes32 entityInBytes = AddressLibrary.AddressToBytes(entity);
        return ItemsLibrary.isItemPendingToRemoved(entityInBytes, _Entities[listId]);
    }

    function retrievePendingEntities(bool addORemove, uint listId) internal 
         isIdCorrect(listId, _Entities.length)
    view returns (address[] memory, string[] memory)
    {
        bytes32[] memory EntitiesInBytes;
        string[] memory EntitiesInfo;
        (EntitiesInBytes, EntitiesInfo) = ItemsLibrary.retrievePendingItems(addORemove, _Entities[listId]);
        return(AddressLibrary.BytesArrayToAddress(EntitiesInBytes) , EntitiesInfo);
    }

}