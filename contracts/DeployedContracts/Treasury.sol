// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */

import "../Interfaces/ITreasury.sol";
import "../Libraries/UintLibrary.sol";
import "../Libraries/Library.sol";
import "../Base/TokenGovernanceBaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


contract Treasury is ITreasury, TokenGovernanceBaseContract{
    using Library for *;
    using UintLibrary for *;

    // EVENTS /////////////////////////////////////////
    event _NewPrices(uint, uint, uint, uint, uint);
    event _Pay(address indexed, uint, uint);
    event _Refund(address indexed, uint, uint);
    event _AssignDividend(address indexed, uint, uint);
    event _Withdraw(address indexed, uint);

    // DATA /////////////////////////////////////////
    // proposition to change prices
    struct ProposedPricesStruct{
        uint NewPublicPriceWei;
        uint NewCertificatePriceWei;
        uint NewPrivatePriceWei;
        uint NewProviderPriceWei;
        uint NewOwnerRefundFeeWei;
    }

    ProposedPricesStruct private _ProposedPrices;

    // parameters
    uint private _PublicPriceWei;
    uint private _CertificatePriceWei;
    uint private _PrivatePriceWei;
    uint private _ProviderPriceWei;
    uint private _OwnerRefundFeeWei;

    // last amount at which dividends where assigned for each token owner
    uint private _AggregatedDividendAmount;
    mapping(address => uint) private _lastAssigned;

    // dividends per token owner
    struct _BalanceStruct{
        mapping(uint => uint) _balance;
        uint[] _factors;
    }
    
    mapping(address => _BalanceStruct) private _balances;

    // MODIFIERS /////////////////////////////////////////
    modifier areFundsEnough(Library.Prices price){
        uint256 minPrice = 2**256 - 1;

        if(Library.Prices.NewProvider == price) minPrice = _PublicPriceWei;
        else if(Library.Prices.NewPool == price) minPrice = _PrivatePriceWei;
        else if(Library.Prices.NewCertificate == price) minPrice = _CertificatePriceWei;
        else minPrice = _ProviderPriceWei;

        require(msg.value >= minPrice, "EC2-");
        _;
    }

    modifier isBalanceEnough(uint amount){
        require(checkBalance(msg.sender) >= amount, "EC20-");
        _;
    }

    modifier isFromPublicPool(){
        require(true == Library.ItIsSomeone(_managerContract.retrievePublicCertificatePoolProxy()), "EC8-");
        _;
    }

    modifier isPriceOK(uint256 PublicPriceWei, uint256 OwnerRefundFeeWei){
        require(PublicPriceWei >= OwnerRefundFeeWei, "EC21-");
        _;
    }
    
    // CONSTRUCTOR /////////////////////////////////////////
    function Treasury_init(uint256 PublicPriceWei, uint256 PrivatePriceWei, uint256 ProviderPriceWei, uint256 CertificatePriceWei, uint256 OwnerRefundFeeWei, address managerContractAddress, address chairPerson, uint256 PropositionLifeTime, uint8 PropositionThresholdPercentage, uint8 minWeightToProposePercentage) public initializer 
    {
        super.TokenGovernanceContract_init(PropositionLifeTime, PropositionThresholdPercentage, minWeightToProposePercentage, chairPerson, managerContractAddress);
        InternalupdatePrices(PublicPriceWei, PrivatePriceWei, ProviderPriceWei, CertificatePriceWei, OwnerRefundFeeWei, true);
    }

    // GOVERNANCE /////////////////////////////////////////
    function updatePrices(uint256 PublicPriceWei, uint256 PrivatePriceWei, uint256 ProviderPriceWei, uint256 CertificatePriceWei, uint256 OwnerRefundFeeWei) external override
    {
        InternalupdatePrices(PublicPriceWei, PrivatePriceWei, ProviderPriceWei, CertificatePriceWei, OwnerRefundFeeWei, false);
    }

    function InternalupdatePrices(uint256 PublicPriceWei, uint256 PrivatePriceWei, uint256 ProviderPriceWei, uint256 CertificatePriceWei, uint256 OwnerRefundFeeWei, bool fromConstructor) internal
        isPriceOK(PublicPriceWei, OwnerRefundFeeWei)
    {
        if(fromConstructor){
            _PublicPriceWei = PublicPriceWei;
            _PrivatePriceWei = PrivatePriceWei;
            _ProviderPriceWei = ProviderPriceWei;
            _CertificatePriceWei = CertificatePriceWei;
            _OwnerRefundFeeWei = OwnerRefundFeeWei;
        }
        else{
            addProposition(block.timestamp + _PropositionLifeTime, _PropositionThresholdPercentage);
            _ProposedPrices.NewPublicPriceWei = PublicPriceWei;
            _ProposedPrices.NewCertificatePriceWei = CertificatePriceWei;
            _ProposedPrices.NewPrivatePriceWei = PrivatePriceWei;
            _ProposedPrices.NewProviderPriceWei = ProviderPriceWei;
            _ProposedPrices.NewOwnerRefundFeeWei = OwnerRefundFeeWei;
        }
        
    }

    function propositionApproved() internal override
    {
        _PublicPriceWei = _ProposedPrices.NewPublicPriceWei;
        _PrivatePriceWei = _ProposedPrices.NewPrivatePriceWei;
        _ProviderPriceWei = _ProposedPrices.NewProviderPriceWei;
        _CertificatePriceWei = _ProposedPrices.NewCertificatePriceWei;
        _OwnerRefundFeeWei = _ProposedPrices.NewOwnerRefundFeeWei;
        
        removeProposition();

        emit _NewPrices(_PublicPriceWei, _PrivatePriceWei, _ProviderPriceWei, _CertificatePriceWei, _OwnerRefundFeeWei);
    }

    function propositionRejected() internal override
    {
        removeProposition();
    }

    function propositionExpired() internal override
    {
        removeProposition();
    }

    function removeProposition() internal
    {
         delete(_ProposedPrices);
    }

    function retrieveProposition() external override view returns(bytes32[] memory)
    {
        bytes32[] memory proposition = new bytes32[](5);
        proposition[0] = UintLibrary.UintToBytes32(_ProposedPrices.NewPublicPriceWei);
        proposition[1] = UintLibrary.UintToBytes32(_ProposedPrices.NewPrivatePriceWei);
        proposition[2] = UintLibrary.UintToBytes32(_ProposedPrices.NewProviderPriceWei);
        proposition[3] = UintLibrary.UintToBytes32(_ProposedPrices.NewCertificatePriceWei);
        proposition[4] = UintLibrary.UintToBytes32(_ProposedPrices.NewOwnerRefundFeeWei);
        return proposition;
    }

    // FUNCTIONALITY /////////////////////////////////////////
    function pay(Library.Prices price) external 
        areFundsEnough(price)
    override payable
    {
        uint256 amount = msg.value;
        if(price == Library.Prices.NewProvider) amount -= _OwnerRefundFeeWei;
        _AggregatedDividendAmount += amount;

        emit _Pay(msg.sender, msg.value, _AggregatedDividendAmount);
    }

    function InternalonTokenBalanceChanged(address from, address to, uint256 amount) internal override
    {
        super.InternalonTokenBalanceChanged(from, to, amount);
        if(address(0) != from) InternalAssignDividends(from);
        if(address(0) != to) InternalAssignDividends(to);
    }

    function AssignDividends() external override
    {
       InternalAssignDividends(msg.sender);
    }

    function InternalAssignDividends(address recipient) internal
    {
        if(_lastAssigned[recipient] < _AggregatedDividendAmount){
           uint amountToSplit = _AggregatedDividendAmount - _lastAssigned[recipient];
           _lastAssigned[recipient] = _AggregatedDividendAmount;
           addBalance(recipient, amountToSplit * GetTokensBalance(recipient), totalSupply());
           
           emit _AssignDividend(recipient, amountToSplit * GetTokensBalance(recipient), totalSupply());
        }
    }

    function getRefund(address addr, uint numberOfOwners) external 
        isFromPublicPool()
    override
    {
        addBalance(addr, _OwnerRefundFeeWei, numberOfOwners);

        emit _Refund(addr, _OwnerRefundFeeWei, numberOfOwners);
    }

    function withdraw(uint amount) external 
        isBalanceEnough(amount)
    override
    {
        uint[] memory f = returnFactors(msg.sender);
        (uint total, uint commonDividend) = sumUpTotal(msg.sender);
        uint remainder =  total - (amount * commonDividend);

        for(uint i=0; i < f.length; i++){
            substractBalance(msg.sender, returnBalanceForFactor(msg.sender, f[i]), f[i]);
        }

        addBalance(msg.sender, remainder, commonDividend);

        (bool success, bytes memory data) = msg.sender.call{value: amount}("");
        require(success, string(abi.encodePacked("Error transfering funds to address : ", data)));

        emit _Withdraw(msg.sender, amount);
    }

    function retrieveBalance(address addr) external override view returns(uint)
    {
        return checkBalance(addr);
    }

    function retrievePrices() external override view returns(uint, uint, uint, uint, uint)
    {
        return(_PublicPriceWei, _PrivatePriceWei, _ProviderPriceWei, _CertificatePriceWei, _OwnerRefundFeeWei);
    }

    function retrieveAggregatedAmount() external override view returns(uint){
        return _AggregatedDividendAmount;
    }

    function checkBalance(address addr) internal view returns(uint){
        (uint total, uint commonDividend) = sumUpTotal(addr);

        return total / commonDividend;
    }

    function sumUpTotal(address addr) internal view returns (uint, uint)
    {
        uint[] memory f = returnFactors(addr);
        uint CommonDividend = UintLibrary.ProductOfFactors(f);
        uint total = 0;

        for(uint i=0; i < f.length; i++){
            total += returnBalanceForFactor(addr, f[i]) * CommonDividend / f[i];
        }

        return (total, CommonDividend);
    }

    function returnFactors(address addr) internal view returns(uint[] memory){
        return _balances[addr]._factors;
    }

    function returnBalanceForFactor(address addr, uint factor) internal view returns(uint){
        return _balances[addr]._balance[factor];
    }

    function addBalance(address addr, uint amount, uint factor) internal
    {
        if(amount > 0){
            if(0 == _balances[addr]._balance[factor])
            {
                _balances[addr]._factors.push(factor);
            }
            _balances[addr]._balance[factor] += amount;
        }
    }

    function substractBalance(address addr, uint amount, uint factor) internal
    {
        require(_balances[addr]._balance[factor] >= amount, "Not enough balance for this factor");

        _balances[addr]._balance[factor] -= amount;

        if(0 == _balances[addr]._balance[factor])
        {
            UintLibrary.UintArrayRemoveResize(UintLibrary.FindUintPosition(factor, _balances[addr]._factors), _balances[addr]._factors);
        }
        
    }

}