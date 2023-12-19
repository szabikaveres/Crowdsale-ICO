// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Token.sol";

contract Crowdsale {
    Token public token; //Token is a smart contract type
    uint public price;
    uint public maxTokens;
    uint public tokensSold;
    
    event Buy(uint amount, address buyer);

    //Need address
    constructor(
        Token _token, 
        uint _price,
        uint _maxTokens
    ) {
        token = _token;
        price = _price; //price = 1 Token / 1 Ether
        maxTokens = _maxTokens;
    }

    function buyTokens(uint _amount) public payable { // payable tells solidity that we send ether in with that transaction 
        require (msg.value ==( _amount / 1e18 ) *  price);//msg.value = the amount of ether being sent in, 1e18 = 10 ** 18
        //above we are making sure, they are sending in enough crypt to setisfy the following condition
       require(token.balanceOf(address(this)) >= _amount);//this corresponds to the address of the current smart contract, that we are writing code inside of
       require (token.transfer(msg.sender, _amount));//transfer is referencing to the transfer function from Token.sol
        //by addig require, telling solidity to make ssure that  condition happends before attempting to do anything else
    
        tokensSold += _amount;

        emit Buy(_amount, msg.sender);
    }

}