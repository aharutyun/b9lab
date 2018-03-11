Hello, 

I want to introduce the format of how I solve the debugging exercises. 
First, I've commented the code, what is wrong with contract.
Second, wrote the contract solution, that is my opinion right one.

All 3 exercises are here.

### Sources of recommendations

1. b9lab training best practices
2. consensys - https://consensys.github.io/smart-contract-best-practices/recommendations/
3. security considerations - http://solidity.readthedocs.io/en/develop/security-considerations.html
 

## Exercise 

### What is wrong

````
/*
  1. After release 0.4.0 it is best practice to have strict pragma version in order to avoid compiler compatibility issues
  2. This contract can be compiled only after pragma solidity version 0.4.10, because revert() function was intorduced in 0.4.10  
 */
 contract PiggyBank {
     address owner;
     
     /*
         1. balance is a redundant and should be removed, contract has its own balance, 
            which is accessible via this.balance
         2. balance has a type of uint248, again it is not right, because this.balance has type of uint256
            and value which will be greater than uint248 will be trimmed, 
            and this is dangerous because people will loose money   
     */
     uint248 balance; // 
     bytes32 hashedPassword;
 
     /*
         piggyBank should be constructor, and there is a typo on function name, should be PiggyBank and must be payable.
         In this case, after creating contract, owner field won't be initialized, and the person,
           who created contract won't be able to send any ether to contract, he will get revert exception.
         This is dangerous, because in some cases, naive person can call function piggyBank with zero value(because function is not payabe) to become owner,
           in order to somehow send ether to contract, and start sending ether to contract.
          Attacker can call piggyBank function and becomes owner, and then call kill function, all ethers will go to Attacker.
     */
     function piggyBank(bytes32 _hashedPassword) {
         owner = msg.sender;
         balance += uint248(msg.value);
         hashedPassword = _hashedPassword;
     }
 
     function () payable {
         if (msg.sender != owner) revert();
         balance += uint248(msg.value);
     }
 
     function kill(bytes32 password) {
         if (keccak256(owner, password) != hashedPassword) revert();
         selfdestruct(owner);
     }
 }
 
````

### Solution

````
pragma solidity 0.4.13;

contract PiggyBank {
    address owner;
    bytes32 hashedPassword;
    
    event LogPiggyBankKilled(bool success);
    event LogPiggyBankCreated(bool success);

    function PiggyBank(bytes32 _hashedPassword) public { //consructor not payable, because of check balance
        require(_hashedPassword != 0); // in case if deployer accidantly missed to provide password hash
        require(this.balance == 0); //make sure, the contract balance is zero, see https://github.com/ConsenSys/smart-contract-best-practices/issues/61
        owner = msg.sender;
        hashedPassword = _hashedPassword;
        LogPiggyBankCreated(true);
    }

    function () public payable {
        if (msg.sender != owner) revert();
    }

    function kill(bytes32 password) public returns (bool success) {
        if (keccak256(owner, password) != hashedPassword) revert();
        LogPiggyBankKilled(true);
        selfdestruct(owner);
        return true;
    }
}
````

## Exercise 2

### What is wrong

````
/*
    it is best practice to have version strict, to avoid version compatbility issues
*/
pragma solidity ^0.4.5;
/*
"interface:/"pure abstract contract" support starts from 0.4.11, so it won't work with 0.4.5
*/
contract WarehouseI {
    function setDeliveryAddress(string where);
    function ship(uint id, address customer) returns (bool handled);
}

contract Store {
    address wallet;
    WarehouseI warehouse;
     /*
        _wallet and _warehouse can be ommited
     */
    function Store(address _wallet, address _warehouse) {
        wallet = _wallet;
        warehouse = WarehouseI(_warehouse);
    }

    /*
        1. function is not marked as payable so it cannot receive ether
        2. multiple interactions with different addresses/contracts, we need to have only one interaction per function, can be a problem here.
           i.e. wallet.send can be failed or/and warehouse.ship can be failed.
        3. wallet.send is not bubble exception, it only returns true/false, in this case, if send failes, shipment will be done in any case
        4. the price of purchase is not defined, in this case value always be 0, because function is not payable
    */
    function purchase(uint id) returns (bool success) {
        wallet.send(msg.value);
        return warehouse.ship(id, msg.sender);
    }
}
````

### Solution

````
pragma solidity 0.4.11;

contract WarehouseI {
    function setDeliveryAddress(string where);
    function ship(uint id, address customer) returns (bool handled);
}

contract Store {
    address wallet;
    WarehouseI warehouse;
    
    mapping(uint => mapping(address => bool)) purchased; //indicated, who purchased
    
    event LogPurchased(uint id, address who);
    event LogShipment(uint id, address whom);

    function Store(address _wallet, address _warehouse) {
        require(_wallet != 0 && _warehouse != 0);// in case, if person missed to pass input params
        wallet = _wallet;
        warehouse = WarehouseI(_warehouse);
    }
    
    /*
        set who and what purchased flag to true, and send ether to wallet, 
    */
    function purchase(uint id) public payable returns (bool success) {
        require(msg.value > 0);
        
        purchased[id][msg.sender] = true;
        LogPurchased(id, msg.sender);
        
        assert(wallet.send(msg.value));
        return true;
    }
    
    /*
        do shipment, in case if sender already purchased product
    */
    function ship(uint id) returns (bool success) {
        //checks, whether product has been payed
        require(purchased[id][msg.sender]);
        
        purchased[id][msg.sender] = false;
        LogShipment(id, msg.sender);
        
        assert(warehouse.ship(id, msg.sender));
        return true;
    }
}

````

## Exercise 3

### What is wrong

````
/*
revert and require functions available from 0.4.10, so it won't work on 0.4.9, at least 0.4.10
*/
pragma solidity ^0.4.9;

contract Splitter {
    address one;
    address two;

    function Splitter(address _two) {
        /*
            Constructor is not payable, so this is redundant, 
            you can't call constructor with msg.value other than 0 
        */
        if (msg.value > 0) revert();
        one = msg.sender;
        two = _two;
    }

    /*
        1. Totally wrong calculation, and contract balance can be drained.
           Let's say contract(balance) has already 9 ether, 
           and 12 ether has been sent to contract, it means the calculation will be (9 + 12) / 3 instead of 12 / 3.
           msg.value should splitted into 3 pieces
        2. there were cases, when msg.value cannot be splitted into 3 equally, it means contract will take more.
           i.e. 10/3 will be 3,3 and 4. 4 ether will be remained to contract, it is not fair.
        3. multiple interactions in one function
        4. possible risk, that first address can be malicious contract, which will call fallback function recursively
           and will drain all the contract balance till gas limit all call stack will be exceeded.
        5. call.value is not a safe against reentrancy, send and transfer can be used instead
        6. Withdraw function would be good to use for getting money from contract
    */
    function () payable {
        uint amount = this.balance / 3;
        require(one.call.value(amount)());
        require(two.call.value(amount)());
    }
}
````

### Solution

````
pragma solidity 0.4.10;

contract Splitter {
    address one;
    address two;
    
    mapping(address => uint) balances;
    
    event LogWithdraw(address who, uint amount);
    event LogSplitterFallback(uint amount, uint balance);

    function Splitter(address _two) public {
        require(_two != 0);
        one = msg.sender;
        two = _two;
    }
    
    function withdraw() public {
        require(one == msg.sender || two == msg.sender);
        
        uint amount = balances[msg.sender];
        require(amount > 0);
        
        balances[msg.sender] = 0;
        
        LogWithdraw(msg.sender, amount);
        
        msg.sender.transfer(amount); 
    }

    function () public payable {
        require(msg.value % 3 == 0); // must be divided into 3 equal pieces
        
        uint amount = msg.value / 3;
        
        balances[one] += amount;
        balances[two] += amount;
        LogSplitterFallback(amount, this.balance);
    }
}
````

