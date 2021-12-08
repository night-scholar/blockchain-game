// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import "./GameStorage.sol";
import "./Collateral.sol";
import "./Equipment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract GameGovernance is GameStorage,Collateral,Equipment,Ownable{
    using SafeMath for uint256;
    constructor (address equipment_) Equipment(equipment_){}

    //添加代币到代币库
    function addToken(string memory tokenName,address tokenAddress) onlyOwner external {
        //要求代币不存在于Token库中
        require( keccak256(abi.encodePacked(tokenLibrary[tokenAddress])) == keccak256(abi.encodePacked(tokenName)),"token already exists");
        tokenLibrary[tokenAddress] = tokenName;
    }

    //添加游戏
    function addGame(string memory gameName,address profitToken,address lossToken) external onlyOwner{
        require(lossToken != address(0),"lossToken address can not be address(0)");
        require(profitToken != address(0),"profitToken address can not be address(0)");
        require(GameLibrary[gameName].lossToken == address(0),"game is alive");
        //要求代币库中有这两个代币
        require(bytes(tokenLibrary[profitToken]).length > 0,"profitToken is not in the tokenLibrary");
        require(bytes(tokenLibrary[lossToken]).length > 0,"lossToken is not in the tokenLibrary");
        GameLibrary[gameName] = (GameAttribute(lossToken,profitToken));
    }

    //添加NFT对应游戏权限
    function addEquipment(uint256 tokenId,string memory gameName) onlyOwner external{
        equipmentCorGame[tokenId] = gameName;
    }
 
    //获取代币余额
    function getBalance(address tokenAddress,address player) public view returns (uint256){
        for (uint i =0 ; i<Wallets[player].tokenAddresses.length ;i++){
            if (Wallets[player].tokenAddresses[i].tokenAddress == tokenAddress){
                return Wallets[player].tokenAddresses[i].amount;
            }
        }
        return 0;
    }

    function increaseBalance(address tokenAddress,address player,uint256 amount) internal{
        for (uint i =0 ; i<Wallets[player].tokenAddresses.length ;i++){
            if (Wallets[player].tokenAddresses[i].tokenAddress == tokenAddress){
                Wallets[player].tokenAddresses[i].amount = Wallets[player].tokenAddresses[i].amount.add(amount);
            }
        }
    }

    function decreaseBalance(address tokenAddress,address player,uint256 amount) internal{
        for (uint i =0 ; i<Wallets[player].tokenAddresses.length ;i++){
            if (Wallets[player].tokenAddresses[i].tokenAddress == tokenAddress){
                Wallets[player].tokenAddresses[i].amount = Wallets[player].tokenAddresses[i].amount.sub(amount);
            }
        }
    }
    //获取玩家收益
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
        //获取实际游戏时间,小时*10**18,实际时间（小时）=(结束时间-开始时间-暂停时间)/一小时的时间
        uint256 gameTime = (realEndTime.sub(playerState.startTime).sub(playerState.pauseTime)).div(_ONE_HOUR);
        //判断收益
        uint256 profitNum = gameTime.mul(playerState.profitPerHour).div(_WAD);
        //判断支出
        uint256 lossNum = gameTime.mul(playerState.lossPerHour).div(_WAD);
        //获取当前游戏收益情况
        param.gameName = playerState.gameName;
        param.startTime = playerState.startTime;
        param.endTime = playerState.endTime;
        param.pauseTime = playerState.pauseTime;
        param.profitTokenAddress = gameAttribute.profitToken;
        param.profitPerHour = playerState.profitPerHour;
        param.profitNum = profitNum;
        param.lossTokenAddress = gameAttribute.lossToken;
        param.lossPerHour = playerState.lossPerHour;
        param.lossNum = lossNum;
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
