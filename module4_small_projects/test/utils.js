//sum 2 strings, for big number
exports.sum = function(a, b) {
    var zrx = /^0+/; // remove leading zeros
    a = a.replace(zrx, '').split('').reverse();
    b = b.replace(zrx, '').split('').reverse();

    var result = [], max = Math.max(a.length, b.length);
    for (var memo = 0, i = 0; i < max; i++) {
        var res = parseInt(a[i] || 0) + parseInt(b[i] || 0) + memo;
        result[i] = res % 10;
        memo = (res - result[i]) / 10;
    }

    if (memo) {
        result.push(memo);
    }

    return result.reverse().join('');
};

exports.balanceToDecimal = function(balance) {
    return Number(balance.toString(10));
}