// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "./Collateral.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameGovernance is Collateral,Ownable{
    struct tokenBankAttribute{
        address tokenAddress;
        uint256 decimals;
    }
    tokenBankAttribute[] public tokenBank;
    bool public isPaused;
    struct TokenAddress{
        address tokenAddress;
        uint256 amount;
    }
    struct Tokens{
        TokenAddress[] tokenAddresses;
    }
    mapping(address => Tokens)  Wallets;

    //添加代币到代币库
    function addToken(address tokenAddress, uint256 decimals) onlyOwner external {
        //要求代币不存在于Token库中
        require(decimals <= 18,"Precision error");
        require(decimals > 0,"Precision error");
        require(tokenInBank(tokenAddress) == 0,"token already exists");
        tokenBank.push(tokenBankAttribute(tokenAddress,decimals));
    }
 
    function getBalance(address tokenAddress) public view returns (uint256){
        for (uint i =0 ; i<Wallets[msg.sender].tokenAddresses.length ;i++){
            if (Wallets[msg.sender].tokenAddresses[i].tokenAddress == tokenAddress){
                return Wallets[msg.sender].tokenAddresses[i].amount;
            }
        }
        return 0;
    }

    function tokenInBank(address tokenAddress) public view returns(uint256){
        for (uint256 i =0 ;i< tokenBank.length;i++){
            if (tokenAddress == tokenBank[i].tokenAddress){
                return tokenBank[i].decimals;
            }
        }
        return 0;
    }

        //暂停
    function pause() external onlyOwner{
        require(!isPaused,"already pause");
        isPaused = true;
    }

    //取消暂停
    function unPause() external onlyOwner{
        require(isPaused,"not paused");
        isPaused = false;
    }
}
