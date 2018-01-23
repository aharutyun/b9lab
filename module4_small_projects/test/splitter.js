const Splitter = artifacts.require("./Splitter.sol");
const Utils = require("./utils");

contract('Splitter', function(accounts) {
  var instance;
  const alice = accounts[0];
  const bob = accounts[1];
  const carol = accounts[2];

  const transferAmount = 100;
  const transferOddAmount = 99;

  it("split should devide transfer amount into 2 equal parts", function() {
    return Splitter.new(bob, carol).then(function(_instance) {
        instance = _instance;
      return instance.split({from: alice, value: transferAmount});
    }).then(function(_txObject) {
        console.log(JSON.stringify(_txObject.logs));
        Utils.handleSuccess(_txObject);
        return instance.withdraw({from: bob});
    }).then(function(_bobWithdrawObject) {
        Utils.handleSuccess(_bobWithdrawObject);
        return instance.withdraw({from: carol});
    }).then(function (_carolWithdrawObject) {
        Utils.handleSuccess(_carolWithdrawObject);
    });
  });

  it("split cannot be done by the person other than alice", function() {
    return Splitter.new(bob, carol).then(function(_instance) {
      instance = _instance;
      return instance.split({from: bob, value: transferAmount});
    }).then(function(txHash) {
      assert.fail(txHash);
    }).catch(function(_reason) {
      assert.isOk(_reason);
    });
  });

  it("split cannot be done for odd amounts", function() {
    return Splitter.new(bob, carol).then(function(_instance) {
        instance = _instance;
        return instance.split({from: alice, value: transferOddAmount});
    }).then(function(txHash) {
        assert.fail(txHash);
    }).catch(function(_reason) {
        assert.isOk(_reason);
    });
  });

  it("operation cannot be done after contract killed", function() {
      return Splitter.new(bob, carol).then(function(_instance) {
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
