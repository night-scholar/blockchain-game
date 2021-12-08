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
        require(bytes(tokenLibrary[tokenAddress]).length == 0 ,"can not find this token");
        require(amount > 0, "amount must be greater than 0");
        Collateral.deposit(tokenAddress,msg.sender, amount);
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
    function withdrawCollateral(address tokenAddress,uint256 amount) public onlyOwner returns(bool){
        //要求取款数量大于0
        require(amount > 0, "amount must be greater than 0");
        //要求系统不在暂停状态
        require(!isPaused,"system paused");
        //要求代币存在于Token库中
        require(bytes(tokenLibrary[tokenAddress]).length == 0,"can not find this token");
        if (PlayerState[msg.sender].inGame){
            //要求代币不在游戏中
            require(GameLibrary[PlayerState[msg.sender].gameName].profitToken!=tokenAddress&&GameLibrary[PlayerState[msg.sender].gameName].lossToken!=tokenAddress,"token in gaming");
        }
        for (uint i =0 ; i<Wallets[msg.sender].tokenAddresses.length ;i++){
            if (Wallets[msg.sender].tokenAddresses[i].tokenAddress == tokenAddress){
                require(Wallets[msg.sender].tokenAddresses[i].amount >= amount,"token not enough");
                Wallets[msg.sender].tokenAddresses[i].amount -= amount;
                Collateral.withdraw(tokenAddress,msg.sender, amount);
                return true;
            }
        }
        return false;
    }


    //存NFT
    function depositEquipment(uint256 tokenId) public payable{
        //要求这件装备已经有对应的游戏记录
        require(bytes(equipmentCorGame[tokenId]).length > 0,"Useless equipment");
        equipmentCorPlayer[tokenId] = msg.sender;
        Equipment.deposit(msg.sender,tokenId);
    }

    //取NFT 
    function withdrawEquipment(uint256 tokenId) public {
        //要求这个NFT是该用户的
        require(equipmentCorPlayer[tokenId] == msg.sender,"You are not the owner of the equipment");
        //要求该NFT不在游戏中
        require(keccak256(abi.encodePacked(PlayerState[msg.sender].gameName)) != keccak256(abi.encodePacked(equipmentCorGame[tokenId])),"this equipment is in game");
        Equipment.withdraw(msg.sender,tokenId);
    }

    //开始游戏
    function startGame(string memory gameName,address player,uint256 tokenId,uint256 lossPerHour,uint256 profitPerHour) public onlyOwner{
        //游戏是否可玩
        require(GameLibrary[gameName].lossToken != address(0),"game not alive");
        //装备是否已经存进来了
        require(equipmentCorPlayer[tokenId] == player,"The equipment was not found");
        //玩家是否正在在进行游戏
        require(!PlayerState[player].inGame,"player is playing");
        //玩家的NFT道具是否能够玩该游戏
        require(keccak256(abi.encodePacked(equipmentCorGame[tokenId])) == keccak256(abi.encodePacked(gameName)),"equipment can not play this game");
        //判断一小时内用户账户是否满足支出
        require(getBalance(GameLibrary[gameName].lossToken,player)>=lossPerHour,"have not enough token");
        //获取当前时间
        uint256 startTime = timeNow();
        uint256 endTime = increaseTime(startTime);
        //记录游戏状态
        PlayerState[player] = (State(true,gameName,startTime,endTime,0,lossPerHour,profitPerHour));
    }

    //继续游戏
    function continueTheGame(address player) external onlyOwner{
        State memory playerState = PlayerState[player];
        //要求玩家在游戏中
        require(!playerState.inGame,"Player not in the game");
        //是否超时
        uint256 endTime = playerState.endTime;
        uint256 timeNow = timeNow();
        //激活时间小于等于结束时间,没有超时，结束时间向后顺延一小时
        if (endTime>= timeNow){
            playerState.endTime = endTime.add(oneHour());
        }else{
        //超时了,暂停时间=当前时间-结束时间，结束时间=当前时间+一小时
            playerState.pauseTime = timeNow.sub(endTime);
            playerState.endTime = timeNow.add(oneHour());
        }
        //要求继续游戏后玩家余额满足支出
        //查看该小时过后的实际游戏时间,小时*10**18
        uint256 gameTime = (playerState.endTime.sub(playerState.startTime).sub(playerState.pauseTime)).div(_ONE_HOUR);
        require(getBalance(GameLibrary[playerState.gameName].lossToken,player)>=gameTime.mul(playerState.lossPerHour).div(_WAD),"have not enough token");
    }

    //结束游戏
    function endGame() external{
        State memory playerState = PlayerState[msg.sender];
        //要求玩家正在进行游戏
        require(playerState.inGame,"is not in game");
        //要求游戏已经结束
        require(playerState.endTime <= timeNow(),"The game is not over yet");
        //获取实际游戏时间,小时*10**18,实际时间（小时）=(结束时间-开始时间-暂停时间)/一小时的时间
        uint256 gameTime = (playerState.endTime.sub(playerState.startTime).sub(playerState.pauseTime)).div(_ONE_HOUR);
        //判断收益
        uint256 profitNum = gameTime.mul(playerState.profitPerHour).div(_WAD);
        //判断支出
        uint256 lossNum = gameTime.mul(playerState.lossPerHour).div(_WAD);
        //增加收益到余额
        increaseBalance(GameLibrary[playerState.gameName].profitToken, msg.sender, profitNum);
        //减少余额
        decreaseBalance(GameLibrary[playerState.gameName].lossToken, msg.sender, lossNum);
    }

    //提取其他币
    function withdrawOtherERC20Tokens(address tokenAddress,uint256 amount,uint256 decimals) public onlyOwner {
        require(decimals != 0 ,"token not in tokenBank");
        require(amount > 0, "amount must be greater than 0");
        Collateral.withdraw(tokenAddress,msg.sender, amount,decimals);
    }
}
