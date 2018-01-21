import { Component } from '@angular/core';
import BigNumber from 'web3/bower/bignumber.js/bignumber';

const Web3 = require('web3');
const contract = require('truffle-contract');
const shopfrontArtifact = require('../../build/contracts/Shopfront.json');

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  web3: any;
  contract: any;
  account: any;

  id: number;
  stock: string;
  price: number;

  productId: number;
  productPrice: number;

  contractBalance: number;

  products: Array<any>;

  shopfront = contract(shopfrontArtifact);

  buyerAddress: string;

  ownerBalance: number;

  constructor() {
    this.initializeShopfront();

    this.shopfront.deployed().then(_contract => {
      this.contract = _contract;
      this.refreshOwnerBalance();
      this.refreshProducts();
      this.refreshBalance();
    });
  }

  private refreshOwnerBalance() {
    this.contract.getOwner.call({from: this.account})
      .then(_owner => {
        const that = this;
        that.account = _owner;
        return this.web3.eth.getBalance(_owner, this.web3.eth.defaultBlock, function(error, result) {
          that.ownerBalance = result;
        });
      });
  }

  private refreshProducts() {
    this.contract.getProductCount.call({from: this.account})
      .then(_productsCount => {
        this.products = [];
        this.extractProductByIndex(0, this.toNumber(_productsCount));
      });
  }

  private extractProductByIndex(_currentProductIndex: number, _productsCount: number) {
    if (_currentProductIndex < _productsCount) {
      this.contract.getProductAt.call(_currentProductIndex, {from: this.account})
        .then(_product => {
          const product = {
            id: this.toNumber(_product[0]),
            stock: _product[1],
            price: this.toNumber(_product[2])
          };
          this.products.push(product);
          this.extractProductByIndex(_currentProductIndex + 1, _productsCount);
        });
    }
  }

  private initializeShopfront() {
    this.initializeWeb3();
    const that = this;
    this.shopfront.setProvider(this.web3.currentProvider);
    this.web3.eth.getAccounts(function(error, accounts) {
      that.buyerAddress = accounts[1];
    });
  }

  private initializeWeb3() {
    /*if (typeof window['web3'] !== 'undefined') {
      // Don't lose an existing provider, like Mist or Metamask
      this.web3 = new Web3(window['web3'].currentProvider);
    } else {
      // set the provider you want from Web3.providers
      this.web3 = new Web3(
        new Web3.providers.HttpProvider('http://localhost:8545')
      );
    }*/
    this.web3 = new Web3(
      new Web3.providers.HttpProvider('http://localhost:8545')
    );
  }

  withdraw() {
    this.contract.withdraw({from: this.account}).then(txObject => {
      if (this.errorHandler(txObject)) {
        this.refreshBalance();
        this.refreshOwnerBalance();
      }
    }).catch(error => {
      alert('Failed: ' + error);
    });
  }


  addProduct() {
    console.log('Account: ' + this.account);
    /*this.contract.addProduct.estimateGas(this.id, this.stock, this.price).then(_gas => {
      console.log('Gas: ' + _gas);
    });*/
    this.contract
      .addProduct(this.id, this.stock, this.price, {from: this.account, gas: 200000})
      .then(txProductAdded => {
        if (this.errorHandler(txProductAdded)) {
          this.id = null;
          this.stock = null;
          this.price = null;
          this.refreshProducts();
        }
      }).catch(error => {
        alert('Failed: ' + error);
      });
  }

  buyProduct() {
    this.contract.buyProduct(this.productId, {from: this.buyerAddress, value: this.productPrice})
      .then((txObject) => {
        if (this.errorHandler(txObject)) {
          this.refreshBalance();
        }
      }).catch(error => {
        alert('Failed: ' + error);
      });
  }

  private errorHandler(txObject): boolean {
    if (txObject.logs.length === 0) {
      alert('something gone wrong. Please, open developer console for debugging');
      return false;
    }
    return true;
  }

  private refreshBalance() {
    this.contract.getBalance.call({from: this.account}).
    then(balance => {
      this.contractBalance = balance;
    }).catch(error => {
      alert('Failed: ' + error);
    });
  }

  private toNumber(bigNumber: BigNumber): number {
    return Number(bigNumber.toString(10));
  }
}

