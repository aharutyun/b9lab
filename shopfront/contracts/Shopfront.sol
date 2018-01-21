pragma solidity ^0.4.4;

contract Shopfront {
    address owner;

    event LogProductPurchased(uint id, string stock, uint price);
    event LogProductAdded(uint id, string stock, uint price);
    event LogWithdrawSuccess(bool success);

    struct Product {
        uint price;
        string stock;
    }

    mapping(uint => Product) products;
    uint[] ids;

    function Shopfront() public {
        owner = msg.sender;
    }

    modifier onlyMe() {
        require(owner == msg.sender);
        _;
    }

    function addProduct(uint id, string stock, uint price)
              onlyMe()
              external
              returns (bool success){
        products[id] = Product(price, stock);
        ids.push(id);
        LogProductAdded(id, products[id].stock, products[id].price);
        return true;
    }

    function getOwner() external constant returns (address) {
      return owner;
    }

    function getProductCount() external constant returns (uint) {
        return ids.length;
    }

    function getProductAt(uint index) external constant returns (uint id, string stock, uint price) {
        Product memory product = products[ids[index]];
        return (ids[index], product.stock, product.price);
    }

    function buyProduct(uint id)
                payable
                external {
        require(products[id].price == msg.value);
        LogProductPurchased(id, products[id].stock, products[id].price);
    }

    function getBalance() external constant returns (uint) {
        return this.balance;
    }

    function withdraw() onlyMe() external {
      owner.transfer(this.balance);
      LogWithdrawSuccess(true);
    }
}
