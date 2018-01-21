pragma solidity ^0.4.4;

contract Remittance {
    struct RemittanceDetail {
        address sender;
        uint amount;
        uint createdDate;
        uint availableSeconds;
        bytes32 passwordHash;
    }


    mapping(address => RemittanceDetail) recipients;

    event LogRemittanceSuccess(address _whom, bytes32 _passwordHash, uint _availableSeconds);
    event LogMoneyExtracted(address _whoExtracted, uint howMuch);
    event LogClaimHappened(uint amount);

    function Remittance() public {
    }

    function remittance(address _whom, bytes32 _passwordHash, uint _availableSeconds) external payable {
        require(_availableSeconds < 300);

        recipients[_whom] = RemittanceDetail({
            sender: msg.sender,
            amount: msg.value,
            createdDate: now,
            availableSeconds: _availableSeconds,
            passwordHash: _passwordHash
        });
        LogRemittanceSuccess(_whom, _passwordHash, _availableSeconds);
    }

    function withdraw(string _password) external payable {
        require(recipients[msg.sender].passwordHash == keccak256(_password));
        require(!isExpired(msg.sender));

        msg.sender.send(recipients[msg.sender].amount);

        LogMoneyExtracted(msg.sender, recipients[msg.sender].amount);

        recipients[msg.sender].amount = 0;
    }

    function claimMoneyBack(address _claimFromWhom) external payable {
        require(isExpired(_claimFromWhom));
        require(recipients[_claimFromWhom].sender == msg.sender);
        require(recipients[_claimFromWhom].amount != 0);

        msg.sender.send(recipients[_claimFromWhom].amount);

        LogClaimHappened(recipients[_claimFromWhom].amount);
    }

    function isExpired(address _who) internal constant returns (bool) {
        return recipients[_who].createdDate + recipients[_who].availableSeconds <= now;
    }

}