pragma solidity ^0.4.4;

contract Splitter {
    address alice;
    address bob;
    address carol;
    bool contractAlive;

    mapping(address => uint) recipientsBalances;

    event LogSuccess(bool success);

    function Splitter(address _bob, address _carol) public {
        alice = msg.sender;
        bob = _bob;
        carol = _carol;
        contractAlive = true;
    }

    modifier onlyAlice() {
        require(alice == msg.sender);
        _;
    }

    modifier onlyContractAlive() {
        require(contractAlive);
        _;
    }

    function split()
        onlyAlice()
        onlyContractAlive()
        external
        payable  {

        require(msg.value % 2 == 0);

        uint half = msg.value / 2;
        recipientsBalances[bob] += half;
        recipientsBalances[carol] += half;
        LogSuccess(true);
    }

    function withdraw() onlyContractAlive() external {
        require(recipientsBalances[msg.sender] != 0);
        uint recipientBalance = recipientsBalances[msg.sender];
        recipientsBalances[msg.sender] = 0;
        msg.sender.transfer(recipientBalance);
        LogSuccess(true);
    }

    function kill()
        onlyAlice()
        onlyContractAlive()
        external
        returns (bool success) {
        contractAlive = false;
        return true;
    }

}