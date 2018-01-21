pragma solidity ^0.4.4;

contract Splitter {
    address alice;
    address bob;
    address carol;

    bool contractAlive = true;

    function Splitter(address _bob, address _carol) public {
        alice = tx.origin;
        bob = _bob;
        carol = _carol;
    }

    modifier onlyAlice() {
        require(alice == msg.sender);
        _;
    }

    modifier onlyContractAlive() {
        require(contractAlive);
        _;
    }

    function split() external payable onlyAlice() onlyContractAlive() {
        require(msg.value % 2 == 0);
        bob.send(msg.value / 2);
        carol.send(msg.value / 2);
    }

    function kill() external onlyAlice() onlyContractAlive() returns (bool) {
        contractAlive = false;
        return true;
    }

}