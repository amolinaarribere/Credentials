// Chai library for testing
// ERROR tests = First we test the error message then we test the action was not carried out

const pool_common = require("../test_libraries/Pools.js");
const init = require("../test_libraries/InitializeContracts.js");
const constants = require("../test_libraries/constants.js");

const CertificatesPoolManager = artifacts.require("CertificatesPoolManager");
const PrivateCertificates = artifacts.require("PrivateCertificatesPool");
var PrivateCertificatesAbi = PrivateCertificates.abi;
const CertisToken = artifacts.require("CertisToken");
var CertisTokenAbi = CertisToken.abi;
const Library = artifacts.require("./Libraries/Library");
const PrivatePoolGenerator = artifacts.require("PrivatePoolGenerator");
const PrivatePoolGeneratorAbi = PrivatePoolGenerator.abi;


const PublicPriceWei = constants.PublicPriceWei;
const PrivatePriceWei = constants.PrivatePriceWei;
const CertificatePriceWei = constants.CertificatePriceWei;
const OwnerRefundPriceWei = constants.OwnerRefundPriceWei;
const Gas = constants.Gas;

// TEST -------------------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------------------

contract("Testing Private Pool",function(accounts){
    var certPoolManager;
    var privateCertPool;
    var publicPool;
    var privatePoolGenerator;
    // used addresses
    const chairPerson = accounts[0];
    const PublicOwners = [accounts[1], accounts[2], accounts[3]];
    const minOwners = 2;
    const provider_1 = accounts[4]; 
    const provider_2 = accounts[5];
    const provider_3 = accounts[6]; 
    const user_1 = accounts[7];
    const holder_1 = accounts[8];
    const holder_2 = accounts[9];
    const PrivateOwners = [accounts[0], accounts[5], accounts[9]];
    const extra_owner = accounts[4];

    beforeEach(async function(){
        let contracts = await init.InitializeContracts(chairPerson, PublicOwners, minOwners, user_1);
        certPoolManager = contracts[0];
        privatePoolGeneratorProxy = new web3.eth.Contract(PrivatePoolGeneratorAbi, contracts[1][3]);
        await privatePoolGeneratorProxy.methods.createPrivateCertificatesPool(PrivateOwners, minOwners).send({from: user_1, value: PrivatePriceWei, gas: Gas}, function(error, result){});
        let response = await privatePoolGeneratorProxy.methods.retrievePrivateCertificatesPool(0).call({from: user_1}, function(error, result){});
        const {0: creator, 1: privateCertPoolAddress} = response;
        privateCertPool = new web3.eth.Contract(PrivateCertificatesAbi, privateCertPoolAddress); 
    });

    // ****** TESTING Adding Owners ***************************************************************** //

    it("Add Owner WRONG",async function(){
        await pool_common.AddOwnerWrong(privateCertPool, PrivateOwners, extra_owner, user_1);
    });

    it("Add Owner CORRECT 1",async function(){
        await pool_common.AddOwnerCorrect(privateCertPool, PrivateOwners, extra_owner, user_1);
    });

    it("Add Owner CORRECT 2",async function(){
        await pool_common.AddOwnerCorrect2(privateCertPool, PrivateOwners, extra_owner, user_1);
    });

    // ****** TESTING Removing Owner ***************************************************************** //

    it("Removing Owner WRONG",async function(){
        await pool_common.RemoveOwnerWrong(privateCertPool, PrivateOwners, provider_3, user_1);
    });

    it("Removing Owner CORRECT 1",async function(){
        await pool_common.RemoveOwnerCorrect(privateCertPool, PrivateOwners, user_1);
    });

    it("Removing Owner CORRECT 2",async function(){
        await pool_common.RemoveOwnerCorrect2(privateCertPool, PrivateOwners, user_1);
    });

    // ****** TESTING Adding Provider ***************************************************************** //

    it("Add Provider WRONG",async function(){
        await pool_common.AddProviderWrong(privateCertPool, PrivateOwners, provider_1, user_1, true);
    });

    it("Add Provider CORRECT 1",async function(){
        await pool_common.AddProviderCorrect(privateCertPool, PrivateOwners, provider_1, provider_2, user_1);
    });

    it("Add Provider CORRECT 2",async function(){
        await pool_common.AddProviderCorrect2(privateCertPool, PrivateOwners, provider_1, provider_2, user_1);
    });

    // ****** TESTING Removing Provider ***************************************************************** //

    it("Removing Provider WRONG",async function(){
        await pool_common.RemoveProviderWrong(privateCertPool, PrivateOwners, provider_1, provider_2, provider_3, user_1, true);
    });

    it("Removing Provider CORRECT 1",async function(){
        await pool_common.RemoveProviderCorrect(privateCertPool, PrivateOwners, provider_1, provider_2, user_1, true);
    });

    it("Removing Provider CORRECT 2",async function(){
        await pool_common.RemoveProviderCorrect2(privateCertPool, PrivateOwners, provider_1, provider_2, user_1, true);
    });

    // ****** TESTING Adding Certificate ***************************************************************** //

    it("Adding Certificate WRONG",async function(){
        await pool_common.AddCertificateWrong(privateCertPool, PrivateOwners, provider_1, provider_2, holder_1, user_1, true);   
    });

    it("Adding Certificate CORRECT",async function(){
        await pool_common.AddCertificateCorrect(privateCertPool, PrivateOwners, provider_1, provider_2, holder_1, holder_2, user_1, true);
    });

    // ****** TESTING callbacks ***************************************************************** //

    it("on Item Validated WRONG",async function(){
        await pool_common.onItemValidatedWrong(privateCertPool, user_1);
    });

    it("on Item Rejected WRONG",async function(){
        await pool_common.onItemRejectedWrong(privateCertPool,  user_1);
    });

});
