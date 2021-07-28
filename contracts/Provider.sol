// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
 import "./Libraries/Library.sol";
 import "./Interfaces/IProvider.sol";
 import "./Abstract/MultiSigContract.sol";
 import "./PrivateCertificatesPool.sol";
 import "./PublicCertificatesPool.sol";
 import "./Libraries/ItemsLibrary.sol";
 import "./Libraries/AddressLibrary.sol";

 contract Provider is IProvider, MultiSigContract {
    using Library for *;
    using AddressLibrary for *;
    using ItemsLibrary for *;

    uint256 constant TotalEntities = 2;

    // Owners
    uint256 constant _ownerIdProviders = 0;
    string constant _ownerLabel = "Owner";

    // Pools
    uint256 constant _poolId = 1;
    string constant _poolLabel = "Pool";

    // Certificates
    uint256 constant _certId = 2;
    string constant _certLabel = "Certificate";

    string[] _Label = [_ownerLabel, _poolLabel];
    
    struct _CertificatesPerHolderStruct{
        mapping(address => ItemsLibrary._ItemsStruct) _CertificatesPerHolder;
    }
   
    mapping(address => _CertificatesPerHolderStruct) _CertificatesPerPool;

    mapping(address => uint256) _AddCertificatePricePerPool;
    mapping(address => uint256) _SubscriptionPricePerPool;
    mapping(address => bool) _submited;

    // Provider
    string _ProviderInfo;

    

    // modifiers
    modifier isAPool(address pool){
        require(true == isPool(pool));
        _;
    }

    modifier isCertificateActivated(bool YesOrNo, bytes32 cert, address pool, address holder){
        if(false == YesOrNo) require(false == isCertificate(pool, cert, holder), "EC6");
        else require(true == isCertificate(pool, cert, holder), "EC7");
        _;
    }

    modifier isCertificatePending(bool YesOrNo, bytes32 cert, address pool, address holder){
        if(false == YesOrNo) require(false == isCertificatePendingToAdded(pool, cert, holder) && 
                                    false == isCertificatePendingToRemoved(pool, cert, holder), "EC27");
        else require(true == isCertificatePendingToAdded(pool, cert, holder) || 
                    true == isCertificatePendingToRemoved(pool, cert, holder), "EC28");
        _;
    }

    modifier isCertificatePendingToAdd(bool YesOrNo, bytes32 cert, address pool, address holder){
        if(false == YesOrNo) require(false == isCertificatePendingToAdded(pool, cert, holder), "EC27");
        else require(true == isCertificatePendingToAdded(pool, cert, holder), "EC28");
        _;
    }

    modifier isCertificatePendingToRemove(bool YesOrNo, bytes32 cert, address pool, address holder){
        if(false == YesOrNo) require(false == isCertificatePendingToRemoved(pool, cert, holder), "EC27");
        else require(true == isCertificatePendingToRemoved(pool, cert, holder), "EC28");
        _;
    }

    modifier HasNotAlreadyVotedForCertificate(bytes32 cert, address pool, address holder){
        require(false == ItemsLibrary.hasVoted(msg.sender, cert, _CertificatesPerPool[pool]._CertificatesPerHolder[holder]), "EC5");
        _;
    }

     // Constructor
    constructor(address[] memory owners,  uint256 minOwners, string memory ProviderInfo) 
        MultiSigContract(owners, minOwners, TotalEntities, _Label, _ownerIdProviders)
    payable
    {
        _ProviderInfo = ProviderInfo;
    }

    // POOL CRUD Operations
    function subscribeToPublicPool(address pool, string calldata poolInfo, uint256 AddCertificatePrice, uint256 SubscriptionPrice) external override{
        InternaladdPool(pool, poolInfo, AddCertificatePrice, SubscriptionPrice);
        if(true == isPool(pool)){
            MultiSigCertificatesPool poolToSubscribe = PublicCertificatesPool(pool);
            poolToSubscribe.addProvider{value:_SubscriptionPricePerPool[pool]}(address(this), _ProviderInfo);
        }
    }

    function addPool(address pool, string calldata poolInfo, uint256 AddCertificatePrice) external override{
        InternaladdPool(pool, poolInfo, AddCertificatePrice, 0);
    }

    function InternaladdPool(address pool, string calldata poolInfo, uint256 AddCertificatePrice, uint256 SubscriptionPrice) internal{
        addEntity(pool, poolInfo, _poolId);
        if(false == _submited[pool]){
            _AddCertificatePricePerPool[pool] = AddCertificatePrice;
            _SubscriptionPricePerPool[pool] = SubscriptionPrice;
            _submited[pool] = true;
        }
    }

    function removePool(address pool) external override{
       removeEntity(pool, _poolId); 
    }

    function validatePool(address pool) external override{
        validateEntity(pool, _poolId);
    }

    function rejectPool(address pool) external override{
        rejectEntity(pool, _poolId);
    }

    function removePricesForPool(address entity) internal
    {
        delete(_submited[entity]);
        delete(_AddCertificatePricePerPool[entity]);
        delete(_SubscriptionPricePerPool[entity]);
    }
    
    function retrievePool(address pool) external override view returns (string memory, bool, uint256){
        string memory poolInfo;
        bool isActivated;

        (poolInfo, isActivated) = InternalRetrievePool(pool);
        return (poolInfo, isActivated, _AddCertificatePricePerPool[pool]);
    }
    
    function InternalRetrievePool(address pool) internal view returns (string memory, bool){
        return retrieveEntity(pool, _poolId);
    }

    function retrieveAllPools() external override view returns (address[] memory)
    {
        return retrieveAllEntities(_poolId);
    }

    function isPool(address pool) public view returns (bool)
    {
        return(isEntity(pool, _poolId));
    }
    
    // Certificates management
    function extractCertIds(address pool, address holder) internal pure returns(uint[] memory){
        uint[] memory certIdIdArray = new uint[](3);
        certIdIdArray[0] = _certId;
        certIdIdArray[1] = AddressLibrary.AddressToUint(pool);
        certIdIdArray[2] = AddressLibrary.AddressToUint(holder);

        return(certIdIdArray);
    }

     function addCertificate(address pool, bytes32 CertificateHash, address holder) external override
        isAPool(pool)
        isAnOwner
        isCertificateActivated(false, CertificateHash, pool, holder) 
        isCertificatePendingToAdd(false, CertificateHash, pool, holder)
     {
        _CertificatesPerHolderStruct storage hs = _CertificatesPerPool[pool];
        uint[] memory certIdIdArray = extractCertIds(pool, holder);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(CertificateHash, "", _minOwners, _certLabel, certIdIdArray, false);
        ItemsLibrary._ItemsStruct storage itemsstruct =  hs._CertificatesPerHolder[holder];
        ItemsLibrary.addItem(manipulateItemStruct,itemsstruct, address(this));
     }
     
     function removeCertificate(address pool, bytes32 CertificateHash, address holder) external override
        isAPool(pool)
        isAnOwner
        isCertificateActivated(true, CertificateHash, pool, holder) 
        isCertificatePendingToRemove(false, CertificateHash, pool, holder)
     {
        _CertificatesPerHolderStruct storage hs = _CertificatesPerPool[pool];
        uint[] memory certIdIdArray = extractCertIds(pool, holder);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(CertificateHash, "", _minOwners, _certLabel, certIdIdArray, false);
        ItemsLibrary._ItemsStruct storage itemsstruct =  hs._CertificatesPerHolder[holder];
        ItemsLibrary.removeItem(manipulateItemStruct, itemsstruct, address(this));
     }

     function validateCertificate(address pool, bytes32 CertificateHash, address holder) external override
        isAPool(pool)
        isAnOwner
        isCertificatePending(true, CertificateHash, pool, holder)
        HasNotAlreadyVotedForCertificate(CertificateHash, pool, holder)
     {
        _CertificatesPerHolderStruct storage hs = _CertificatesPerPool[pool];
        uint[] memory certIdIdArray = extractCertIds(pool, holder);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(CertificateHash, "", _minOwners, _certLabel, certIdIdArray, false);
        ItemsLibrary._ItemsStruct storage itemsstruct =  hs._CertificatesPerHolder[holder];
        ItemsLibrary.validateItem(manipulateItemStruct, itemsstruct, address(this));
     }

     function rejectCertificate(address pool, bytes32 CertificateHash, address holder) external override
        isAPool(pool)
        isAnOwner
        isCertificatePending(true, CertificateHash, pool, holder)
        HasNotAlreadyVotedForCertificate(CertificateHash, pool, holder)
     {
        _CertificatesPerHolderStruct storage hs = _CertificatesPerPool[pool];
        uint[] memory certIdIdArray = extractCertIds(pool, holder);
        ItemsLibrary._manipulateItemStruct memory manipulateItemStruct = ItemsLibrary._manipulateItemStruct(CertificateHash, "", _minOwners, _certLabel, certIdIdArray, false);
        ItemsLibrary._ItemsStruct storage itemsstruct =  hs._CertificatesPerHolder[holder];
        ItemsLibrary.rejectItem(manipulateItemStruct, itemsstruct, address(this));
     }
 
    function manipulateCertificate(address pool, bytes32 CertificateHash, address holder, bool addOrRemove) internal
    {
        MultiSigCertificatesPool poolToSend;
        (string memory p ,) = InternalRetrievePool(pool);

        if(keccak256(abi.encodePacked("Private")) == keccak256(abi.encodePacked((p)))){
                poolToSend = PrivateCertificatesPool(pool);
            }
        else {
                poolToSend = PublicCertificatesPool(pool);
        }

        if(addOrRemove){
                poolToSend.addCertificate{value:_AddCertificatePricePerPool[pool]}(CertificateHash, holder);
            }
        else{
               poolToSend.removeCertificate(CertificateHash, holder);
        }
            
        //delete(_CertificatesPerPool[getPoolId(pool)]._CertificatesPerHolder[getHolderId(holder)]._cert[CertificateHash]);
        
    }

    function isCertificate(address pool, bytes32 CertificateHash, address holder) public view returns(bool)
    {
        return ItemsLibrary.isItem(CertificateHash, _CertificatesPerPool[pool]._CertificatesPerHolder[holder]);
    }

    function isCertificatePendingToAdded(address pool, bytes32 CertificateHash, address holder) internal view returns(bool)
    {
        return ItemsLibrary.isItemPendingToAdded(CertificateHash, _CertificatesPerPool[pool]._CertificatesPerHolder[holder]);
    }

    function isCertificatePendingToRemoved(address pool, bytes32 CertificateHash, address holder) internal view returns(bool)
    {
        return ItemsLibrary.isItemPendingToRemoved(CertificateHash, _CertificatesPerPool[pool]._CertificatesPerHolder[holder]);
    }

    
    receive() external override payable{}

    // Callback functions

    function onItemValidated(bytes32 item, uint[] calldata ids, bool addOrRemove) public override  
    {
        if(ids[0] == _poolId){
            if(false == addOrRemove)removePricesForPool(AddressLibrary.BytesToAddress(item));
        }
        else if(ids[0] == _certId){
            manipulateCertificate(AddressLibrary.UintToAddress(ids[1]), item, AddressLibrary.UintToAddress(ids[2]), addOrRemove);
        }
    }

    function onItemRejected(bytes32 item, uint[] calldata ids, bool addOrRemove) internal override  
    {
        if(ids[0] == _poolId){
            if(true == addOrRemove)removePricesForPool(AddressLibrary.BytesToAddress(item));
        } 
    }
    
 }