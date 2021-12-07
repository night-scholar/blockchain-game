// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract GameStorage {
    using SafeMath for uint256;
    uint256 internal _WAD = 10**18;
    uint256 internal _ONE_HOUR = 3600;
    //用户游戏状态
    struct State{
        bool inGame;
        string gameName;
        uint256 startTime;
        uint256 endTime;
        uint256 lastActivationTime;
        uint256 lossPerHour;
        uint256 profitPerHour;
    }
    mapping(address=>State) internal PlayerState;
    //用户游戏收益
    struct PlayerRevenue{
        string gameName;
        uint256 startTime;
        uint256 endTime;
        address profitTokenAddress;
        uint256 profitPerHour;
        uint256 profitNum;
        address lossTokenAddress;
        uint256 lossPerHour;
        uint256 lossNum;
        uint256 pauseTime;
    }

    //游戏库(游戏名称->游戏属性)
    struct GameAttribute{
        address lossToken;
        address profitToken;
    }
    mapping(string=>GameAttribute) public GameLibrary;

    
    struct TokenAddress{
        address tokenAddress;
        uint256 amount;
    }
    struct Tokens{
        TokenAddress[] tokenAddresses;
    }
    //用户对应的token地址的余额
    mapping(address => Tokens)  Wallets;

    //erc20 token库 token地址->token名称
    mapping(address => string) tokenLibrary;
    //系统是否暂停
    bool public isPaused;
    
    //装备id对应的游戏
    mapping(uint256 => string) public equipmentCorGame;
    //装备id对应的用户
    mapping(uint256 => address) public equipmentCorPlayer;

    function oneHour() internal view returns(uint256){
        return _ONE_HOUR.mul(_WAD);
    } 

    function timeNow() internal view returns(uint256){
        return block.timestamp.mul(_WAD);
    }

    function increaseTime(uint256 time) internal view returns(uint256){
        return time.add(oneHour());
    }
}