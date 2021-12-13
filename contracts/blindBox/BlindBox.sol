// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BlindBox{
    uint256 public BoxUnitPrice;


    function setBlindBoxUnitPrice(uint256 price) external {
        require(price > 0,"price must bigger than zero");
        BoxUnitPrice = price;
    }

     
}