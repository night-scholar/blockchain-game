// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "./GameGovernance.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

contract ChainGame is GameGovernance{
    //存款
    function deposit(address tokenAddress , uint256 amount) public payable returns(bool){
        require(!isPaused,"system paused");
        //要求代币存在于Token库中
        uint256 decimals = tokenInBank(tokenAddress);
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        Collateral.deposit(tokenAddress,msg.sender, amount,decimals);
        for (uint i =0 ; i<Wallets[msg.sender].tokenAddresses.length ;i++){
            if (Wallets[msg.sender].tokenAddresses[i].tokenAddress == tokenAddress){
                Wallets[msg.sender].tokenAddresses[i].amount += amount;
                return true;
            }
        }
        Wallets[msg.sender].tokenAddresses.push(TokenAddress(tokenAddress,amount));
        return true;
    }

    //取款
    function withdraw(address tokenAddress,address trader,uint256 amount) public onlyOwner returns(bool){
        require(!isPaused,"system paused");
        //要求代币存在于Token库中
        uint256 decimals = tokenInBank(tokenAddress);
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        for (uint i =0 ; i<Wallets[trader].tokenAddresses.length ;i++){
            if (Wallets[trader].tokenAddresses[i].tokenAddress == tokenAddress){
                require(Wallets[trader].tokenAddresses[i].amount >= amount,"token not enough");
                Wallets[trader].tokenAddresses[i].amount -= amount;
                Collateral.withdraw(tokenAddress,trader, amount,decimals);
                return true;
            }
        }
        revert("error");
    }

    //提取其他币
    function withdrawOtherTokens(address tokenAddress,uint256 amount,uint256 decimals) public onlyOwner returns(bool){
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        Collateral.withdraw(tokenAddress,msg.sender, amount,decimals);
    }
}
