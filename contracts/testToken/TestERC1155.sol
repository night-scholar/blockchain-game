// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestERC1155 is ERC1155,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => string) public indexToItem;
    mapping(string => uint256) public itemToIndex;

    constructor() public ERC1155("https://game.example/api/item/{id}.json") {

    }

    function addItem(string memory _itemName) external{
        require(itemToIndex[_itemName] == 0,"this item name already exist");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        indexToItem[tokenId] = _itemName;
        itemToIndex[_itemName] = tokenId;
    }

    function mint(address to,uint256 tokenId,uint256 amount) external onlyOwner{
        require(to != address(0), "mint to zero address");
        require(tokenIdExist(tokenId), "tokenId not exist");
        _mint(to,tokenId,amount,"");
    }


    function burn(address to, uint256 tokenId, uint256 amount) external onlyOwner{
        require(to != address(0), "burn zero address");
        require(tokenIdExist(tokenId), "tokenId not exist");
        _burn(to, tokenId, amount);
    }
    
    function tokenIdExist(uint256 tokenId) view public returns(bool){
        if (keccak256(abi.encodePacked(indexToItem[tokenId])) != keccak256(abi.encodePacked(""))) {
            return true;
        }
        return false;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }
}