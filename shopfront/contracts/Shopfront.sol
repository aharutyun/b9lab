pragma solidity ^0.4.4;

contract Shopfront {
    address owner;

    event LogProductPurchased(uint id, uint stock, string name, uint price);
    event LogProductAdded(uint id, uint stock, string name, uint price);
    event LogSuccess(bool success);

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
              external{
        require(price != 0 && products[id].price == 0); //check already added product
        products[id] = Product(price, stock, name);
        ids.push(id);
        LogProductAdded(id, products[id].stock, products[id].name, products[id].price);
        LogSuccess(true);
    }

    function addStock(uint productId, uint additionalStockAmount) external {
        require(products[productId].price != 0);
        products[productId].stock += additionalStockAmount;
        LogSuccess(true);
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
      LogSuccess(true);
    }
}
