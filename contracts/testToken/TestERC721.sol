// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestERC721 is ERC721, Ownable {
    string private nftName;
    string private nftSymbol;
    constructor(string memory name_,string memory symbol_,string memory _uri) ERC721(name_, symbol_) {
        nftName = name_;
        nftSymbol = symbol_;
        _setBaseURI(_uri);
    }

  function mint(address _to, uint256 _tokenId, string calldata _uri) external onlyOwner {
    super._mint(_to, _tokenId);
    super._setTokenURI(_tokenId, _uri);
  }

  function setURI(string memory _uri) external onlyOwner{
    super._setBaseURI(_uri);
  }
}