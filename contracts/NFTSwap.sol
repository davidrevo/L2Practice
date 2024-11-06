// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract NFTSwap is IER721Receiver {
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    // 定义order结构体
    struct Order {
        address owner;
        uint256 price;
    }

    // NFT Order映射
    mapping(address => mapping(uint256 => Order)) public orders;

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IER721Receiver.onERC721Received.selector;
    }

    // 挂单: 卖家上架NFT，合约地址为_nftAddr，tokenId为_tokenId，价格_price为以太坊（单位是wei）
    funciton list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);   // 声明IERC721接口合约变量
        require(_nft.getterApproved(_tokenId) == address(this), "Need Approval");  // 合约得到授权
        require(_price > 0);  // 价格大于0

        Order storage order = orders[_nftAddr][_tokenId];  //设置NFT持有人和价格
        _order.owner = msg.sender;
        _order.price = _price;
        // 将NFT转账到合约
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        // 释放List事件
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // 撤单： 卖家取消挂单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage order = orders[_nftAddr][_tokenId];
        require(order.owner == msg.sender, "Not Owner");

        IERC721 _nft = IERC721(_nftAddr);
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // 释放Revoke事件
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // 调整价格: 卖家调整挂单价格
    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price");    // NFT价格大于0
        Order storage order = orders[_nftAddr][_tokenId];   // 取得Order
        require(order.owner == msg.sender, "Not Owner");    // 必须由持有人发起
        
        // 声明IERC721接口合约变量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中


        // 设置新的价格
        order.price = _newPrice;

        // 释放Update事件
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    // 购买: 买家购买NFT，合约为_nftAddr，tokenId为_tokenId，调用函数时要附带ETH
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage order = orders[_nftAddr][_tokenId];   // 取得Order  
        require(order.price > 0, "Invalid Price");  // NFT价格大于0
        require(msg.value >= order.price, "Not Enough ETH"); // 买家支付ETH大于等于NFT价格

        // 声明IERC721接口合约变量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        // 将NFT转给买家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 将ETH转给卖家，多余ETH给买家退款
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddr][_tokenId];  // 删除Order

        // 释放Purchase事件
        emit Purchase(msg.sender, _nftAddr, _tokenId, order.price);
    }

    fallback() external payable {}
}