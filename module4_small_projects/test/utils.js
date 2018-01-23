exports.balanceToDecimal = function(balance) {
    return Number(balance.toString(10));
}

exports.handleSuccess = function(_txObject) {
    assert(_txObject.logs != null);
    assert(_txObject.logs[0].args.success);
}