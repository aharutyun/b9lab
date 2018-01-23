const Splitter = artifacts.require("./Splitter.sol");
const Remittance = artifacts.require("./Remittance.sol");
const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

module.exports = function(deployer) {
  deployer.deploy(Splitter);
  deployer.deploy(Remittance);
  deployer.deploy(RockPaperScissors);
};
