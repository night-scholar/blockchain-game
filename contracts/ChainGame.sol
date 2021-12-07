// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import "./GameGovernance.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ChainGame is GameGovernance{
    constructor (address equipment_) GameGovernance(equipment_){} 
    using SafeMath for uint256;
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
        return false;
    }


    //存NFT
    function depositEquipment(uint256 tokenId) public payable{
        equipmentCorPlayer[tokenId] = msg.sender;
        Equipment.deposit(msg.sender,tokenId);
    }

    //取NFT 
    function withdrawEquipment(uint256 tokenId) public {
        require(equipmentCorPlayer[tokenId] == msg.sender,"You are not the owner of the equipment");
        Equipment.withdraw(msg.sender,tokenId);
    }

    //开始游戏
    function startGame(string memory gameName,address player,uint256 tokenId,uint256 lossPerHour,uint256 profitPerHour) public onlyOwner{
        //游戏是否可玩
        require(GameLibrary[gameName].lossToken != address(0),"game not alive");
        //装备是否已经存进来了
        require(equipmentCorPlayer[tokenId] == player,"The equipment was not found");
        //玩家是否正在在进行游戏
        require(!PlayerState[player].inGame,"trader is playing");
        //玩家的NFT道具是否能够玩该游戏
        require(keccak256(abi.encodePacked(equipmentCorGame[tokenId])) == keccak256(abi.encodePacked(gameName)),"equipment can not play this game");
        //获取当前时间戳
        uint256 startTime = timeNow();
        uint256 endTime = increaseTime(startTime);
        //判断一小时内用户账户是否满足支出
        //记录游戏状态
        PlayerState[player] = (State(true,gameName,startTime,endTime,lossPerHour,profitPerHour));
    }

    function getPlayerRevenue(address player) view public returns(PlayerRevenue memory param){
        State memory playerState = PlayerState[player];
        //判断玩家是否在进行游戏
        if (!playerState.inGame){
            return param;
        }
        GameAttribute memory gameAttribute = GameLibrary[playerState.gameName];

        //获取当前时间
        uint256 timeNow = timeNow();
        //如果当前时间超过了结束时间，则按结束时间计算
        uint256 realEndTime;
        if (playerState.endTime<timeNow){
            realEndTime = playerState.endTime;
        }else{
        //如果结束时间超过了当前时间，则按当前时间计算
            realEndTime = timeNow;
        }
        //获取游戏时间,小时*10**18
        uint256 gameTime = realEndTime.sub(playerState.startTime).div(_ONE_HOUR);
        //判断收益
        uint256 profitNum = gameTime.mul(playerState.profitPerHour).div(_WAD);
        //判断支出
        uint256 lossNum = gameTime.mul(playerState.lossPerHour).div(_WAD);
        //获取当前游戏收益情况
        param.gameName = playerState.gameName;
        param.startTime = playerState.startTime.div(oneHour());
        param.endTime = playerState.endTime.div(oneHour());
        param.profitTokenAddress = gameAttribute.profitToken;
        param.profitPerHour = playerState.profitPerHour;
        param.profitNum = profitNum;
        param.lossTokenAddress = gameAttribute.lossToken;
        param.lossPerHour = playerState.lossPerHour;
        param.lossNum = lossNum;
    }


    //提取其他币
    function withdrawOtherERC20Tokens(address tokenAddress,uint256 amount,uint256 decimals) public onlyOwner {
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        Collateral.withdraw(tokenAddress,msg.sender, amount,decimals);
    }
}
