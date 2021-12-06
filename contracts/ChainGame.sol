// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "./GameGovernance.sol";

contract ChainGame is GameGovernance{
    constructor (address equipment_) GameGovernance(equipment_){} 
    //存款ERC20
    function depositCollateral(address tokenAddress , uint256 amount) public payable returns(bool){
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

    //取款ERC20
    function withdrawCollateral(address tokenAddress,address trader,uint256 amount) public onlyOwner returns(bool){
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


    //存NFT
    function depositEquipment(uint256 tokenId) public payable{
        require(!equipmentIsAlive[tokenId],"tokenId is alived");
        equipmentIsAlive[tokenId] = true;
        equipmentURI[tokenId] = Equipment.getTokenURI(tokenId);
        Equipment.deposit(msg.sender,tokenId);
    }

    //取NFT
    function withdrawEquipment(uint256 tokenId) public {
        require(equipmentIsAlive[tokenId],"tokenId not alived");
        equipmentIsAlive[tokenId] = false;
        delete equipmentURI[tokenId];
        Equipment.withdraw(msg.sender,tokenId);
    }

    //开始游戏
    function startGame(string memory gameName,address player,uint256 tokenId,uint256 lossPerHour,uint256 profitPerHour) public onlyOwner{
        //游戏是否可玩
        require(GameLibrary[gameName].lossToken != address(0),"game not alive");
        //是否已经存进来了，没存进来不能进行游戏
        //玩家是否在进行游戏
        require(!PlayerState[player].inGame,"trader is playing");
        //玩家的NFT道具是否能够玩该游戏
        require(keccak256(abi.encodePacked(equipmentCorGame[tokenId])) == keccak256(abi.encodePacked(gameName)),"equipment can not play this game");
        //记录游戏状态
        PlayerState[player] = (State(true,gameName,lossPerHour,profitPerHour));
    }

    //查看游戏收益
    function getPlayerRevenue(address player) public{

    }


    //提取其他币
    function withdrawOtherERC20Tokens(address tokenAddress,uint256 amount,uint256 decimals) public onlyOwner {
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        Collateral.withdraw(tokenAddress,msg.sender, amount,decimals);
    }
}
