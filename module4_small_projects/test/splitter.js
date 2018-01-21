var Splitter = artifacts.require("./Splitter.sol");
var utils = require("./utils");

contract('Splitter', function(accounts) {
  var instance;
  const alice = accounts[0];
  const bob = accounts[1];
  const carol = accounts[2];

  var bobBalance;
  var carolBalance;

  const transferAmount = 100;
  const transferOddAmount = 99;

  it("split should devide transfer amount into 2 equal parts", function() {
    return Splitter.deployed().then(function(_instance) {
      instance = _instance;
      bobBalance = web3.eth.getBalance(bob);
      carolBalance = web3.eth.getBalance(carol);
      return instance.split({from: alice, value: transferAmount});
    }).then(function(txHash) {
      return web3.eth.getTransactionReceipt(txHash.tx);
    }).then(function(_receipt) {
      assert(_receipt.blockNumber != null);
      const afterBobBalance = web3.eth.getBalance(bob);
      const afterCarolBalance = web3.eth.getBalance(carol);
      assert.strictEqual(afterBobBalance.toString(10), utils.sum(String(transferAmount/2), bobBalance.toString(10)));
      assert.strictEqual(afterCarolBalance.toString(10), utils.sum(String(transferAmount/2), carolBalance.toString(10)));
    });
  });

  it("split cannot be done by the person other than alice", function() {
    return Splitter.deployed().then(function(_instance) {
      instance = _instance;
      return instance.split({from: bob, value: transferAmount});
    }).then(function(txHash) {
      assert.fail(txHash);
    }).catch(function(_reason) {
      assert.isOk(_reason);
    });
  });

  it("split cannot be done for odd amounts", function() {
    return Splitter.deployed().then(function(_instance) {
        instance = _instance;
        return instance.split({from: alice, value: transferOddAmount});
    }).then(function(txHash) {
        assert.fail(txHash);
    }).catch(function(_reason) {
        assert.isOk(_reason);
    });
  });

  it("operation cannot be done after contract killed", function() {
      return Splitter.deployed().then(function(_instance) {
          instance = _instance;
          return instance.kill({from: alice});
      }).then(function(txHash) {
          return instance.split({from: alice, value: transferAmount});
      }).then(function(txHash) {
         assert.fail(txHash);
      }).catch(function(_reason) {
         assert.isOk(_reason);
      });
    });
});
