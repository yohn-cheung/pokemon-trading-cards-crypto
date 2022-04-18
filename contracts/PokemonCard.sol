// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract PokemonCard {
    struct Card {
        uint256 id; // the card id of the pokemon card
        string name; // title of pokemoncard
        string series; // // from which series
        uint256 amount; // the price to pay for the card
        address buyer; // msg.sender of the buyer of the card 
        uint256 timestamp; // The timestamp when the user waved.
    }

    Card[] public cards;

    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
        console.log("Yo yo, I am a contract am I am smart");
    }

     modifier onlyOwner () {
       require(msg.sender == owner, "This can only be called by the contract owner!");
       _;
     }


    function buyCard(uint256 _id, string calldata _name, string calldata _series, uint256 _amount) payable public {
        Card memory card = Card(_id, _name, _series, _amount, msg.sender, block.timestamp);
        cards.push(card);

        // 1, "charizard", "test series", 1
        uint256 amount = _amount * (10 ** 18); // maybe not needed anymore after this is implemented into the contract, problems with the .5
        // maybe the solution: https://ethereum.stackexchange.com/questions/119727/ethers-js-error-invalid-bignumber-string
        require (msg.value == amount, "Amount is not the same");
        require(amount <= address(this).balance, "Trying to withdraw more money than they contract has.");
        (bool success, ) = (msg.sender).call{value: amount}("");
        require(success, "Failed to withdraw money from contract.");
    }


    function getAllBoughtCards() public view returns (Card[] memory) {
        return cards;
    }
}