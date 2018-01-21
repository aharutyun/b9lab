var Remittance = artifacts.require("./Remittance.sol");
var Utils = require("./utils");

contract('Remittance', function(accounts) {
  var instance;
  const alice = accounts[0];
  const bob = accounts[1];
  const transferAmount = 100;
  const bobsPassword = "test"
  const availableSeconds = 10;

  it("remmitance successfully happened", function() {
    return Remittance.deployed().then(function(_instance) {
      instance = _instance;
      return instance.remittance(bob, web3.sha3("test"), availableSeconds, {from: alice, value: transferAmount});
    }).then(function(txHash) {
      return instance.withdraw(bobsPassword, {from: bob});
    }).then(function(txWithdraw) {
        assert(txWithdraw.logs.length != 0);
        assert.strictEqual(bob, txWithdraw.logs[0].args._whoExtracted);
        assert.strictEqual(transferAmount, Utils.balanceToDecimal(txWithdraw.logs[0].args.howMuch));
    });
  });
});
