pragma solidity ^0.4.4;

contract Remittance {
    struct RemittanceDetail {
        address sender;
        uint amount;
        uint validDate;
        bytes32 passwordHash;
    }

    uint maximumAvailableTimeIsDay = 86400;


    mapping(address => RemittanceDetail[]) recipients;

    event LogRemittanceSuccess(address _whom, bytes32 _passwordHash, uint _availableSeconds);
    event LogMoneyExtracted(address _whoExtracted, uint howMuch);
    event LogClaimHappened(uint amount);

    function Remittance() public {
    }

    function remittance(address _whom, bytes32 _passwordHash, uint _availableSeconds)
        external
        payable {
        require(_availableSeconds < maximumAvailableTimeIsDay);

        recipients[_whom].push(RemittanceDetail({
            sender: msg.sender,
            amount: msg.value,
            validDate: now + _availableSeconds,
            passwordHash: _passwordHash
        }));

        LogRemittanceSuccess(_whom, _passwordHash, _availableSeconds);
    }

    function withdraw(bytes32 _passwordHash) external {
        uint withdrawalAmount;
        for (uint i = 0; i < recipients[msg.sender].length; i ++) {
            RemittanceDetail memory recipient = recipients[msg.sender][i];
            if (isValidForWithdrawal(recipient, _passwordHash)) {
                withdrawalAmount += recipient.amount;
                recipient.amount = 0;
            }
        }

        require(withdrawalAmount != 0);
        msg.sender.transfer(withdrawalAmount);

        LogMoneyExtracted(msg.sender, withdrawalAmount);

    }

    function isValidForWithdrawal(RemittanceDetail recipient, bytes32 _passwordHash)
        private
        constant
        returns (bool valid) {
        return recipient.passwordHash == _passwordHash && recipient.validDate >= now;
    }

    function claimMoneyBack(address _claimFromWhom) external {
        uint claimAmount;
        for (uint i = 0; i < recipients[_claimFromWhom].length; i ++) {
            RemittanceDetail memory recipient = recipients[_claimFromWhom][i];
            if (recipient.validDate < now && recipient.sender == msg.sender && recipient.amount > 0) {
                claimAmount += recipient.amount;
                recipient.amount = 0;
            }
        }

        require(claimAmount != 0);
        msg.sender.transfer(claimAmount);

        LogClaimHappened(claimAmount);
    }

}