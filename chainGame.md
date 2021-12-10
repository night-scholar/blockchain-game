# 链游

## 操作流程

1. 部署TestERC20和TestERC721合约。
2. 部署GameChain合约，构造参数TestERC721.address。
3. 添加erc20代币到代币库，参数包含代币名称，代币地址。管理员权限。
4. 添加游戏，参数包含游戏名称，消耗代币地址，收益代币地址。管理员权限。
5. 存储erc20代币到合约。管理员权限。
6. 铸造TestERC20和TestERC721给玩家。管理员权限。
7. 添加NFT对应游戏名称。参数包含NFT的id，游戏名称。管理员权限。
8. 玩家在TestERC20和TestERC721中对GameChain合约进行授权。
9. 开始游戏，参数包含游戏名称，玩家地址，NFT的id，每小时失去代币数量，每小时收益代币数量。管理员权限。
10. 继续游戏，参数包含玩家地址。管理员权限。
10. 结束游戏，要求游戏时间已经到了，参数包含玩家地址。玩家权限。

## 剩余工作

IPFS文件夹批量储存哈希https://forum.openzeppelin.com/t/how-to-erc-1155-id-substitution-for-token-uri/3312/6

如果使用`uri`，则需要存储 ipfs 哈希，但可以使用文件夹批量存储（每批次一个哈希）。这就是我们为[https://sandbox.game](https://sandbox.game/)所做的。

https://www.its304.com/article/weixin_29491885/112389373#3__28 IPFS和IPNS

## 测试

1. 测试存取ERC20
2. 测试存取ERC721

## 地址及参数

GASOLINE（汽油）

```
0x64DC3Dd854C2f982af20ff93e0Cd4F9348218eCa
```

WOOD（木头）

```
0xBD23CD14C1Bf747425d578DA43c2eC3Be19E3Bc4
```

AXE（斧子）

```
0xbcc5ae7e71f24E42b78d02cb764331B82a83125E
```

ChainGame（游戏）

```
0x8831355C59DEde867e54D158F8fBC8B96444f0C9
```

游戏名称：CutDownTrees

使用GASOLINE（1个每小时），获得WOOD（1个每小时）。
