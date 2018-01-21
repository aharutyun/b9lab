var Splitter = artifacts.require("./Splitter.sol");
var Remittance = artifacts.require("./Remittance.sol");
var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

module.exports = function(deployer) {
  deployer.deploy(Splitter, web3.eth.accounts[1], web3.eth.accounts[2]);
  deployer.deploy(Remittance);
  deployer.deploy(RockPaperScissors);
};
