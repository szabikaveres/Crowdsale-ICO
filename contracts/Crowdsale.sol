// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Token.sol";

contract Crowdsale {
    address public owner;
    Token public token; //Token is a smart contract type
    uint public price;
    uint public maxTokens;
    uint public tokensSold;
    
    event Buy(uint amount, address buyer);
    event Finalize(uint tokensSold, uint ethRaised);

    constructor(
        Token _token, 
        uint _price,
        uint _maxTokens
    ) {
        owner = msg.sender;
        token = _token;
        price = _price; //price = 1 Token / 1 Ether
        maxTokens = _maxTokens;
    }

        modifier onlyOwner() {
        require(msg.sender == owner, 'Caller is not the owner');//only the deployer can call the function, this is to protect the function. String is to see what is the error if failes
        _; //_ is a function body of finalise().Basically saying execute the(require(msg.sender == owner, 'caller must be owner'); before doing the function body (finalize())
    }

    receive() external payable{ //special function which lets you send/ receive either directly- 
    //by sending ether the contract automatically spits out tokens and sends it to our account, or to the account which used to buy from 
    uint amount = msg.value / price; //calculate the amount they want to purchase
    buyTokens(amount * 1e18);
    } 

    function buyTokens(uint _amount) public payable { // payable tells solidity that we send ether in with that transaction 
        require (msg.value ==( _amount / 1e18 ) *  price);//msg.value = the amount of ether being sent in, 1e18 = 10 ** 18
        //above we are making sure, they are sending in enough crypto to satisfy the following condition
       require(token.balanceOf(address(this)) >= _amount);//this corresponds to the address of the current smart contract, that we are writing code inside of
       require (token.transfer(msg.sender, _amount));//transfer is referencing to the transfer function from Token.sol
        //by addig require, telling solidity to make sure that  condition happends before attempting to do anything else
    
        tokensSold += _amount;

        emit Buy(_amount, msg.sender);

    }

    function setPrice(uint _price) public onlyOwner {
        price = _price;
    }

    function finalize() public onlyOwner {
        //Send remainig tokens to crowdsale creator
       // uint remainingTokens = token.balanceOf(address(this)); //how many tokens are held inside the smart contract(this)
        require(token.transfer(owner, token.balanceOf(address(this))));

        //Send ETH to crowdsale creator
        uint value = address(this).balance;// we check the ether balance for (this)special contract and save it to value 
        (bool sent, ) = owner.call{value: value}("") ;  //low level function that let's you send message inside of a transaction to an account. It can be a SC or a user address
                                    //we send the entire balance saved in value
                                    //call function returns 2 variables : bool sent, and bytes data
        require(sent);

        emit Finalize(tokensSold, value);



    }

}