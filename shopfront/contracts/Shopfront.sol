pragma solidity ^0.4.4;

contract Shopfront {
    address owner;

    event LogProductPurchased(uint id, uint stock, string name, uint price);
    event LogProductAdded(uint id, uint stock, string name, uint price);
    event LogWithdrawSuccess(bool success);

    struct Product {
        uint price;
        uint stock;
        string name;
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

    function addProduct(uint id, uint stock, string name, uint price)
              onlyMe()
              external
              returns (bool success){
        products[id] = Product(price, stock, name);
        ids.push(id);
        LogProductAdded(id, products[id].stock, products[id].name, products[id].price);
        return true;
    }

    function getOwner() external constant returns (address) {
      return owner;
    }

    function getProductCount() external constant returns (uint) {
        return ids.length;
    }

    function getProductAt(uint index) external constant returns (uint id, uint stock, string name, uint price) {
        Product memory product = products[ids[index]];
        return (ids[index], product.stock, product.name, product.price);
    }

    function buyProduct(uint id)
                payable
                external {
        require(products[id].price == msg.value);
        require(products[id].stock > 0);
        products[id].stock --;
        LogProductPurchased(id, products[id].stock, products[id].name, products[id].price);
    }

    function withdraw() onlyMe() external {
      owner.transfer(this.balance);
      LogWithdrawSuccess(true);
    }
}
