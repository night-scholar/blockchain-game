// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import "./GameStorage.sol";
import "./Collateral.sol";
import "./Equipment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GameGovernance is GameStorage,Collateral,Equipment,Ownable{

    constructor (address equipment_) Equipment(equipment_){}

    //添加代币到代币库
    function addToken(string memory tokenName,address tokenAddress) onlyOwner external {
        //要求代币不存在于Token库中
        require( keccak256(abi.encodePacked(tokenLibrary[tokenAddress])) == keccak256(abi.encodePacked(tokenName)),"token already exists");
        tokenLibrary[tokenAddress] = tokenName;
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
