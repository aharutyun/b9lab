var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");
var Utils = require("./utils");

contract('RockPaperScissors', function(accounts) {
  var instance;
  const alice = accounts[0];
  const bob = accounts[1];
  const depositAmount = 100000000;
  const aliceChoice = "rock"
  const bobChoice = "paper";
  const aliceSecret = "123";
  const bobSecret = "321";
  const gameName = "game1";

  var bobBalance;

  it("bob should win", function() {
    return RockPaperScissors.deployed().then(function(_instance) {
      instance = _instance;
        return instance.newGame(gameName, bob, depositAmount, {from: alice});
    }).then(function(txHash) {
      return instance.playerMove(aliceChoice, aliceSecret, gameName, {from: alice, value: depositAmount});
    }).then(function(txAlice) {
        return instance.playerMove(bobChoice, bobSecret, gameName, {from: bob, value: depositAmount});
    }).then(function(txBob) {
      bobBalance = web3.eth.getBalance(bob);
      return instance.play(gameName, aliceSecret, bobSecret, {from: alice});
    }).then(function(txResult) {
      var bobBalanceAfter = web3.eth.getBalance(bob);
      assert.strictEqual(txResult.logs[0].args._winnerAddress, bob);
      assert.strictEqual(txResult.logs[0].args._gameName, gameName);
      assert.strictEqual(Utils.balanceToDecimal(bobBalanceAfter), Utils.balanceToDecimal(bobBalance) + (depositAmount * 2));
    });
  });
});
