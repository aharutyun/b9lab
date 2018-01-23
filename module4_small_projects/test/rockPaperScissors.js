const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

contract('RockPaperScissors', function(accounts) {
  var instance;
  const alice = accounts[0];
  const bob = accounts[1];
  const depositAmount = 100000000;
  const aliceChoice = 1; //rock
  const bobChoice = 2; // paper
  const aliceSecret = "123";
  const bobSecret = "321";
  const gameName = "game1";

  var bobBalance;

  it("bob should win", function() {
    return RockPaperScissors.new().then(function(_instance) {
      instance = _instance;
        return instance.newGame(gameName, bob, depositAmount, {from: alice});
    }).then(function(txHash) {
        return instance.calculateKeccak(aliceChoice, aliceSecret, {from: alice});
    }).then(function(_aliceChoiceHash) {
        return instance.playerMove(_aliceChoiceHash, gameName, {from: alice, value: depositAmount});
    }).then(function(txAlice) {
          return instance.calculateKeccak(bobChoice, bobSecret, {from: bob});
      }).then(function(_bobsChoiceHash) {
        return instance.playerMove(_bobsChoiceHash, gameName, {from: bob, value: depositAmount});
    }).then(function(txBob) {
      bobBalance = web3.eth.getBalance(bob);
      return instance.play(gameName, aliceSecret, bobSecret, {from: alice});
    }).then(function(txResult) {
      var bobBalanceAfter = web3.eth.getBalance(bob);
      assert.strictEqual(bob, txResult.logs[0].args._winnerAddress);
      assert.strictEqual(gameName, txResult.logs[0].args._gameName);
      assert.strictEqual(bobBalanceAfter.toString(10), bobBalance.plus((depositAmount * 2)).toString(10));
    });
  });
});
