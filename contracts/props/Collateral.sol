// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";


import {LibMathSigned, LibMathUnsigned} from "../Lib/LibMath.sol";

contract Collateral {
    using SafeERC20 for IERC20;
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    uint256 private constant MAX_DECIMALS = 18;
    function deposit(address tokenAddress,address trader, uint256 rawAmount) internal {
        uint256 wadAmount = toWad(rawAmount,MAX_DECIMALS);
        pullCollateral(tokenAddress,trader, wadAmount);
    }

    function withdraw(address tokenAddress,address trader, uint256 rawAmount) internal{
        uint256 wadAmount = toWad(rawAmount,MAX_DECIMALS);
        pushCollateral(tokenAddress,trader, wadAmount);
    }

    function withdraw(address tokenAddress,address trader, uint256 rawAmount,uint256 decimals) internal{
        uint256 wadAmount = toWad(rawAmount,decimals);
        pushCollateral(tokenAddress,trader, wadAmount);
    }

    function pullCollateral(address tokenAddress,address trader, uint256 wadAmount) internal {
        require(wadAmount > 0, "amount must be greater than 0");
        IERC20 collateral = IERC20(tokenAddress);
        if (address(collateral) != address(0)) {
            collateral.safeTransferFrom(trader, address(this), wadAmount);
        }
    }

    function pushCollateral(address tokenAddress,address trader, uint256 wadAmount) internal{
        require(wadAmount > 0, "amount must be greater than 0");
        IERC20 collateral = IERC20(tokenAddress);
        if (address(collateral) != address(0)) {
            collateral.safeTransfer(trader, wadAmount);
        } 
    }

    function toWad(uint256 rawAmount,uint256 decimals) internal pure returns (uint256) {
        int256 scaler = (10**(MAX_DECIMALS - decimals)).toInt256();
        return rawAmount.toInt256().div(scaler).toUint256();
    }
}