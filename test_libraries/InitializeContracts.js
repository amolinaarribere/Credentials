const Admin = artifacts.require("Admin");
const CertificatesPoolManager = artifacts.require("CertificatesPoolManager");
const Treasury = artifacts.require("Treasury");
const PublicCertificatesPool = artifacts.require("PublicCertificatesPool");
const PrivateCertificatesPool = artifacts.require("PrivateCertificatesPool");
const Provider = artifacts.require("Provider");
const CertisToken = artifacts.require("CertisToken");
const PriceConverter = artifacts.require("PriceConverter");
const ENS = artifacts.require("ENS");
const PropositionSettings = artifacts.require("PropositionSettings");
const PrivatePoolFactory = artifacts.require("PrivatePoolFactory");
const ProviderFactory = artifacts.require("ProviderFactory");

const CertificatesPoolManagerAbi = CertificatesPoolManager.abi;

const MockChainLinkFeedRegistry = artifacts.require("MockChainLinkFeedRegistry"); // Mock
const MockENSRegistry = artifacts.require("MockENSRegistry"); // Mock
const MockENSResolver = artifacts.require("MockENSResolver"); // Mock
const MockENSReverseRegistry = artifacts.require("MockENSReverseRegistry"); // Mock

const MockENSRegistryAbi = MockENSRegistry.abi;


const constants = require("../test_libraries/constants.js");
const obj = require("../test_libraries/objects.js");

const PublicPriceUSD = constants.PublicPriceUSD;
const PrivatePriceUSD = constants.PrivatePriceUSD;
const ProviderPriceUSD = constants.ProviderPriceUSD;
const CertificatePriceUSD = constants.CertificatePriceUSD;
const OwnerRefundPriceUSD = constants.OwnerRefundPriceUSD;
// Mock -----------
const rate = constants.rate;
const decimals = constants.decimals;
const initNodes = constants.initNodes;
var ENSRegistryAddress;
var ENSReverseRegistryAddress;
var ENSResolverAddress;
// Mock -----------
const PropositionLifeTime = constants.PropositionLifeTime;
const PropositionThreshold = constants.PropositionThreshold;
const minToPropose = constants.minToPropose;
const TotalTokenSupply = constants.TotalTokenSupply;
const Gas = constants.Gas;
const PublicPoolContractName = constants.PublicPoolContractName;
const PublicPoolContractVersion = constants.PublicPoolContractVersion;
const PrivatePoolContractName = constants.PrivatePoolContractName;
const PrivatePoolContractVersion = constants.PrivatePoolContractVersion;
const CertificateManagerContractName = constants.CertificateManagerContractName;
const CertificateManagerContractVersion = constants.CertificateManagerContractVersion;
const TreasuryContractName = constants.TreasuryContractName;
const TreasuryContractVersion = constants.TreasuryContractVersion;
const PriceConverterContractName = constants.PriceConverterContractName;
const PriceConverterContractVersion = constants.PriceConverterContractVersion;
const PropositionSettingsContractName = constants.PropositionSettingsContractName;
const PropositionSettingsContractVersion = constants.PropositionSettingsContractVersion;
const ENSContractName = constants.ENSContractName;
const ENSContractVersion = constants.ENSContractVersion;
const AdminContractName = constants.AdminContractName;
const AdminContractVersion = constants.AdminContractVersion;

var CertificatesPoolManagerProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "address",
      "name": "chairPerson",
      "type": "address"
    },
    {
      "internalType": "string",
      "name": "contractName",
      "type": "string"
    },
    {
      "internalType": "string",
      "name": "contractVersion",
      "type": "string"
    }
  ],
  "name": "CertificatesPoolManager_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const ENSProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "address",
      "name": "ENSRegistry",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "ENSReverseRegistry",
      "type": "address"
    },
    {
      "internalType": "bytes32[]",
      "name": "nodes",
      "type": "bytes32[]"
    },
    {
      "internalType": "address",
      "name": "managerContractAddress",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "chairPerson",
      "type": "address"
    },
    {
      "internalType": "string",
      "name": "contractName",
      "type": "string"
    },
    {
      "internalType": "string",
      "name": "contractVersion",
      "type": "string"
    }
  ],
  "name": "ENS_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const PropositionSettingsProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "address",
      "name": "managerContractAddress",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "chairPerson",
      "type": "address"
    },
    {
      "internalType": "uint256",
      "name": "PropositionLifeTime",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "PropositionThreshold",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "minToPropose",
      "type": "uint256"
    },
    {
      "internalType": "string",
      "name": "contractName",
      "type": "string"
    },
    {
      "internalType": "string",
      "name": "contractVersion",
      "type": "string"
    }
  ],
  "name": "PropositionSettings_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const PriceConverterProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "address",
      "name": "registry",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "managerContractAddress",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "chairPerson",
      "type": "address"
    },
    {
      "internalType": "string",
      "name": "contractName",
      "type": "string"
    },
    {
      "internalType": "string",
      "name": "contractVersion",
      "type": "string"
    }
  ],
  "name": "PriceConverter_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const CertisTokenProxyInitializerMethod = {
    "inputs": [
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      },
      {
        "internalType": "uint256",
        "name": "MaxSupply",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "managerContractAddress",
        "type": "address"
      },
      {
        "internalType": "uint8",
        "name": "decimalsValue",
        "type": "uint8"
      },
      {
        "internalType": "address",
        "name": "initialOwner",
        "type": "address"
      }
    ],
    "name": "CertisToken_init",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
};
const TreasuryProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "uint256",
      "name": "PublicPriceUSD",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "PrivatePriceUSD",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "ProviderPriceUSD",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "CertificatePriceUSD",
      "type": "uint256"
    },
    {
      "internalType": "uint256",
      "name": "OwnerRefundFeeUSD",
      "type": "uint256"
    },
    {
      "internalType": "address",
      "name": "managerContractAddress",
      "type": "address"
    },
    {
      "internalType": "address",
      "name": "chairPerson",
      "type": "address"
    },
    {
      "internalType": "string",
      "name": "contractName",
      "type": "string"
    },
    {
      "internalType": "string",
      "name": "contractVersion",
      "type": "string"
    }
  ],
  "name": "Treasury_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const PrivatePoolFactoryProxyInitializerMethod = {
    "inputs": [
      {
        "internalType": "address",
        "name": "managerContractAddress",
        "type": "address"
      }
    ],
    "name": "PrivatePoolFactory_init",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
};
const ProviderFactoryProxyInitializerMethod = {
  "inputs": [
    {
      "internalType": "address",
      "name": "managerContractAddress",
      "type": "address"
    }
  ],
  "name": "ProviderFactory_init",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
};
const PublicCertificatesPoolProxyInitializerMethod = {
    "inputs": [
      {
        "internalType": "address[]",
        "name": "owners",
        "type": "address[]"
      },
      {
        "internalType": "uint256",
        "name": "minOwners",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "managerContractAddress",
        "type": "address"
      },
      {
        "internalType": "string",
        "name": "contractName",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "contractVersion",
        "type": "string"
      }
    ],
    "name": "PublicCertPool_init",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
};

async function InitializeContracts(chairPerson, PublicOwners, minOwners, user_1){
  let certPoolManager = await CertificatesPoolManager.new({from: chairPerson, gas: Gas});
  let CertPoolManagerProxyData = getProxyData(CertificatesPoolManagerProxyInitializerMethod, [chairPerson, CertificateManagerContractName, CertificateManagerContractVersion]);
  let admin = await deployAndInitNewAdmin(AdminContractName, AdminContractVersion, certPoolManager.address, CertPoolManagerProxyData, chairPerson);
  let certPoolManagerProxyAddress = await admin.retrieveManagerProxy();

  var certPoolManagerProxy = new web3.eth.Contract(CertificatesPoolManagerAbi, certPoolManagerProxyAddress);

  let implementations = await deployImplementations(user_1);
  let ProxyData = returnProxyInitData(PublicOwners, minOwners, certPoolManagerProxyAddress, chairPerson, implementations[8]);

  await certPoolManagerProxy.methods.InitializeContracts(obj.returnUpgradeObject(implementations[0], implementations[1], implementations[2], implementations[3], implementations[4], implementations[5], implementations[6], implementations[7], implementations[9], implementations[10],
    ProxyData[0], ProxyData[1], ProxyData[2], ProxyData[3], ProxyData[4], ProxyData[5], ProxyData[6], ProxyData[7], PrivatePoolContractName, PrivatePoolContractVersion)).send({from: chairPerson, gas: Gas});

  let proxies = await retrieveProxies(certPoolManagerProxy, user_1);

  let mockENSRegistryContract = new web3.eth.Contract(MockENSRegistryAbi, ENSRegistryAddress);
  await mockENSRegistryContract.methods.initialize(initNodes, ENSResolverAddress, proxies[7]).send({from: user_1, gas: Gas});
  await mockENSRegistryContract.methods.setSubnodeOwner("0x0000000000000000000000000000000000000000", web3.utils.sha3('reverse'), user_1).send({from: user_1, gas: Gas});
  await mockENSRegistryContract.methods.setSubnodeOwner("0xa097f6721ce401e757d1223a763fef49b8b5f90bb18567ddb86fd205dff71d34", web3.utils.sha3('addr'), ENSReverseRegistryAddress).send({from: user_1, gas: Gas});

  return [certPoolManagerProxy, proxies, implementations, admin.address, certPoolManager.address];
}

async function deployAndInitNewAdmin(ContractName, ContractVersion, certPoolManagerAddress, CertPoolManagerProxyData, chairPerson){
  let admin = await Admin.new();
  await admin.Admin_init(ContractName, ContractVersion, certPoolManagerAddress, CertPoolManagerProxyData, {from: chairPerson, gas: Gas});
  return admin;
}

async function redeployAndInitAdmin(ContractName, ContractVersion, certPoolManagerProxyAddress, adminProxyAddress, chairPerson){
  let admin = await Admin.new();
  await admin.Admin_init_redeploy(ContractName, ContractVersion, certPoolManagerProxyAddress, adminProxyAddress, {from: chairPerson, gas: Gas});
  return admin;
}

async function deployImplementations(user_1){
    let publicPool = await PublicCertificatesPool.new({from: user_1});
    let treasury = await Treasury.new({from: user_1});
    let certisToken = await CertisToken.new({from: user_1});
    let privatePoolFactory = await PrivatePoolFactory.new({from: user_1});
    let privatePool = await PrivateCertificatesPool.new({from: user_1});
    let providerFactory = await ProviderFactory.new({from: user_1});
    let provider = await Provider.new({from: user_1});
    let priceConverter = await PriceConverter.new({from: user_1});
    let propositionSettings = await PropositionSettings.new({from: user_1});
    let ens = await ENS.new({from: user_1});

    // Mock ---------------
    let mockChainLinkFeedRegistry = await MockChainLinkFeedRegistry.new(rate, decimals, {from: user_1});
    let mockENSRegistry = await MockENSRegistry.new({from: user_1});
    ENSRegistryAddress = mockENSRegistry.address;
    let mockENSResolver = await MockENSResolver.new(ENSRegistryAddress, {from: user_1});
    ENSResolverAddress = mockENSResolver.address;
    let mockENSReverseRegistry = await MockENSReverseRegistry.new(ENSRegistryAddress, mockENSResolver.address, {from: user_1});
    ENSReverseRegistryAddress = mockENSReverseRegistry.address;
    // Mock ---------------

    return [publicPool.address, treasury.address, certisToken.address, privatePoolFactory.address, privatePool.address, providerFactory.address, provider.address, priceConverter.address, mockChainLinkFeedRegistry.address, propositionSettings.address, ens.address, mockENSRegistry.address, mockENSReverseRegistry.address];
}

async function retrieveProxies(certPoolManager, user_1){
  let TransparentProxies = await certPoolManager.methods.retrieveTransparentProxies().call({from: user_1});

  let publicPoolProxy = TransparentProxies[0];
  let treasuryProxy = TransparentProxies[1];
  let certisTokenProxy = TransparentProxies[2];
  let privatePoolFactoryProxy = TransparentProxies[3];
  let providerFactoryProxy = TransparentProxies[4];
  let priceConverterProxy = TransparentProxies[5];
  let propositionSettingsProxy = TransparentProxies[6];
  let ensProxy = TransparentProxies[7];

  return [publicPoolProxy, treasuryProxy, certisTokenProxy, privatePoolFactoryProxy, providerFactoryProxy, priceConverterProxy, propositionSettingsProxy, ensProxy];
}

function getProxyData(method, parameters){
  return web3.eth.abi.encodeFunctionCall(method, parameters);
}

function returnProxyInitData(PublicOwners, minOwners, certPoolManager, chairPerson, mockChainLinkFeedRegistry){
  let CertisProxyData = getProxyData(CertisTokenProxyInitializerMethod, ["Certis Token for Test", "CERT", TotalTokenSupply, certPoolManager, 0, chairPerson]);
  let PublicCertificatesPoolProxyData = getProxyData(PublicCertificatesPoolProxyInitializerMethod, [PublicOwners, minOwners, certPoolManager, PublicPoolContractName, PublicPoolContractVersion]);
  let TreasuryProxyData = getProxyData(TreasuryProxyInitializerMethod, [PublicPriceUSD, PrivatePriceUSD, ProviderPriceUSD, CertificatePriceUSD, OwnerRefundPriceUSD, certPoolManager, chairPerson, TreasuryContractName, TreasuryContractVersion]);
  let PrivatePoolFactoryProxyData = getProxyData(PrivatePoolFactoryProxyInitializerMethod, [certPoolManager]);
  let ProviderFactoryProxyData = getProxyData(ProviderFactoryProxyInitializerMethod, [certPoolManager]);
  let PriceConverterProxyData = getProxyData(PriceConverterProxyInitializerMethod, [mockChainLinkFeedRegistry, certPoolManager, chairPerson, PriceConverterContractName, PriceConverterContractVersion]);
  let PropositionSettingsProxyData = getProxyData(PropositionSettingsProxyInitializerMethod, [certPoolManager, chairPerson, PropositionLifeTime, PropositionThreshold, minToPropose, PropositionSettingsContractName, PropositionSettingsContractVersion]);
  let ENSProxyData = getProxyData(ENSProxyInitializerMethod, [ENSRegistryAddress, ENSReverseRegistryAddress, initNodes, certPoolManager, chairPerson, ENSContractName, ENSContractVersion]);

  return [PublicCertificatesPoolProxyData, TreasuryProxyData, CertisProxyData, PrivatePoolFactoryProxyData, ProviderFactoryProxyData, PriceConverterProxyData, PropositionSettingsProxyData, ENSProxyData];
}

exports.InitializeContracts = InitializeContracts;
exports.deployImplementations = deployImplementations;
exports.returnProxyInitData = returnProxyInitData;
exports.redeployAndInitAdmin = redeployAndInitAdmin;