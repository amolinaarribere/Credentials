// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

 import "./MultiSigCertificatesPool.sol";

 /* 
 Like Private Certificates except that Providers must be sent from "Creator" who is not an owner
 */

 contract PublicCertificatesPool is MultiSigCertificatesPool {

     address _creator;
     mapping(address => bool) _submitedByCreator;

     //modifiers
    modifier hasBeenSubmitted(bool YesOrNo, address provider){
        if(false == YesOrNo) require(false == _submitedByCreator[provider], "Provider already activated or in progress");
        else require(true == _submitedByCreator[provider], "Provider not submited by Creator yet");
        _;
    }

     // Constructor
    constructor(address[] memory owners,  uint256 minOwners) MultiSigCertificatesPool(owners, minOwners) payable {
        _creator = msg.sender;
    }

    function addProvider(address provider, string memory providerInfo) external 
        isSomeoneSpecific(_creator)
        hasBeenSubmitted(false, provider)
    override
    {
        _Entities[_providerId]._entities[provider]._Info = bytes(providerInfo);
        _submitedByCreator[provider] = true;
    }

    function validateProvider(address provider) external 
        hasBeenSubmitted(true, provider)
    {
        addEntity(provider, _Entities[_providerId]._entities[provider]._Info, _providerId);
    }

    function removeProvider(address provider) external override{
       removeEntity(provider, _providerId); 

       if(false == Library.isEntity(_Entities[_providerId]._entities[provider])){
            delete(_submitedByCreator[provider]);
       }
    }

 }