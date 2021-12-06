// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "./Collateral.sol";
import "./Equipment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GameGovernance is Collateral,Equipment,Ownable{
    //用户游戏状态
    struct State{
        bool inGame;
        string gameName;
        uint256 lossPerHour;
        uint256 profitPerHour;
    }
    mapping(address=>State) public PlayerState;

    //游戏库(游戏名称->游戏属性)
    struct GameAttribute{
        address lossToken;
        address profitToken;
    }
    mapping(string=>GameAttribute) public GameLibrary;

    //代币权限
    

    //token属性，不再需要，都是18位的。
    struct TokenAttribute{
        address tokenAddress;
        uint256 decimals;
    }
    struct TokenAddress{
        address tokenAddress;
        uint256 amount;
    }
    struct Tokens{
        TokenAddress[] tokenAddresses;
    }
    TokenAttribute[] public tokenLibrary;
    bool public isPaused;
    mapping(address => Tokens)  Wallets;
    mapping(uint256 => bool) public equipmentIsAlive;
    mapping(uint256 => string) public equipmentURI;
    //装备id对应的游戏
    mapping(uint256 => string) public equipmentCorGame;

    constructor (address equipment_) Equipment(equipment_){

    }

    //添加代币到代币库
    function addToken(address tokenAddress, uint256 decimals) onlyOwner external {
        //要求代币不存在于Token库中
        require(decimals <= 18,"Precision error");
        require(decimals > 0,"Precision error");
        require(tokenInBank(tokenAddress) == 0,"token already exists");
        tokenLibrary.push(TokenAttribute(tokenAddress,decimals));
    }

    //添加游戏
    function addGame(string memory gameName,address lossToken,address profitToken) external onlyOwner{
        require(lossToken != address(0),"lossToken address can not be address(0)");
        require(profitToken != address(0),"profitToken address can not be address(0)");
        require(GameLibrary[gameName].lossToken == address(0),"game is alive");
        GameLibrary[gameName] = (GameAttribute(lossToken,profitToken));
    }

    //添加NFT对应游戏权限
    function addEquipment(uint256 tokenId,string memory gameName) onlyOwner external{
        equipmentCorGame[tokenId] = gameName;
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
        for (uint256 i =0 ;i< tokenLibrary.length;i++){
            if (tokenAddress == tokenLibrary[i].tokenAddress){
                return tokenLibrary[i].decimals;
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
