var tools = require('../test/tools');
var BasicERC20Token = artifacts.require("./token/BasicERC20Token.sol");
var BountyIndex = artifacts.require("./bounty/BountyIndex.sol");

// IMPORTANT: If running live, make sure you choose a non-dumb value for
var startblock = web3.eth.blockNumber + 10;
var endBlock = startblock + 1000;

var supply = tools.gitcoinSupply() * tools.weiPerEther();
module.exports = function(deployer, network) {
  deployer.deploy(BasicERC20Token).await.then(function(result){
        deployer.deploy(BountyIndex);
  });
};
