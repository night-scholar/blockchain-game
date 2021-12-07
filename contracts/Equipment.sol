// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";


contract Equipment is IERC721Receiver, ERC165, ERC721Holder{
    address public equipmentAddress;
    IERC721Metadata equipment;
    constructor(address equipment_) {
        equipmentAddress = equipment_;
        equipment = IERC721Metadata(equipment_);
        _registerInterface(IERC721Receiver.onERC721Received.selector);
    }


    function deposit(address trader, uint256 tokenId) internal{
        equipment.safeTransferFrom(trader,address(this),tokenId);
    }

    function withdraw(address trader,uint256 tokenId) internal{
        equipment.safeTransferFrom(address(this),trader,tokenId);
    }

}