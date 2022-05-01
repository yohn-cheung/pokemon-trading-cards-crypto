// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract PokemonCard {
    event Transfer(string id, string name, string series, string img, uint amount, address buyer, uint256 timestamp);

    struct Card {
        string id; // the card id of the pokemon card
        string name; // title of pokemoncard
        string series; // from which series
        string img; // img url
        uint amount; // the price to pay for the card
        address buyer; // msg.sender of the buyer of the card 
        uint256 timestamp; // The timestamp when the user waved.
    }

    Card[] public cards;
    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
        console.log("Yo yo, I am a contract am I am smart");
    }


    function buyCard(string calldata _id, string calldata _name, string calldata _series, string calldata _img, uint _amount) payable public {
        Card memory card = Card(_id, _name, _series, _img, _amount, msg.sender, block.timestamp);
        cards.push(card);
        
        uint amount = _amount;
       
        require(amount <= address(this).balance, "Trying to withdraw more money than they contract has.");
        (bool success, ) = (msg.sender).call{value: amount}("");
        require(success, "Failed to withdraw money from contract.");
        emit Transfer(_id, _name, _series, _img, _amount, msg.sender, block.timestamp);
    }

    function getAllBoughtCards() public view returns (Card[] memory) {
        return cards;
    }
}