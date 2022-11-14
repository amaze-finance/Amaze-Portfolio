// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

// import "hardhat/console.sol";
import "../libraries/ERC721Enumerable.sol";
import "../libraries/SpecialAddress.sol";
import "../libraries/IERC20.sol";

contract NFT is ERC721Enumerable, SpecialAddress { // процент с продажи НФТ // процент с маржи 

    struct infoNFT {
        address[] addresses;
        uint256 creationTime;
        bool active; // true == amounts are locked
    }

    struct saleNFT {
        uint256 price;
        uint256 index; // index in nftOnSale array
        address paymentToken;
    }

    mapping(uint256 => mapping(address => uint256)) internal amounts; // id => address => balance
    mapping(address => bool) internal statuses;
    mapping(uint256 => infoNFT) internal info;
    mapping(uint256 => saleNFT) public sale; // id => struct
    // // array for ids
    uint256[] public nftOnSale;

    // // Mapping from token ID to owner address
    // mapping(uint256 => address) private _owners;

    // // Mapping owner address to token count
    // mapping(address => uint256) private _balances;


    address public portfolio;
    uint256 public supplyCounter;

    constructor(
        address specialAddress_
    )
    ERC721("Amaze.finance", "Amaze") {
        specialAddresses[msg.sender] = true;
        specialAddresses[specialAddress_] = true;
    }

    modifier onlyPortfolio() {
        require(portfolio == msg.sender, "Not user's NFT");
        _;
    }


    function addNftOnSale(uint256 _idNFT, uint256 _price, IERC20 _paymentToken) external onlyPortfolio {
        sale[_idNFT] = saleNFT(_price, nftOnSale.length, address(_paymentToken));
        nftOnSale.push(_idNFT);
    }

    function setNftSaleInfo(uint256 _idNFT, uint256 _newPrice, IERC20 _paymentToken) external onlyPortfolio {
        sale[_idNFT] = saleNFT(_newPrice, nftOnSale.length, address(_paymentToken));
    }

    function getNftPrice(uint256 _idNFT) external view returns(uint256){
        return sale[_idNFT].price;
    }

    function getNftPaymentToken(uint256 _idNFT) external view returns(address) {
        return address(sale[_idNFT].paymentToken);
    }

    function isNftOnSale(uint256 _idNFT) external view returns(bool) {
        return sale[_idNFT].price > 0 ? true : false;
    }

    function isNftActive(uint256 _idNFT) external view returns(bool) {
        return info[_idNFT].active;
    }

    function removeActive(uint256 _idNFT) external onlyPortfolio {
        info[_idNFT].active = false;
    }

    function removeNFT(uint256 _idNFT, uint256 _index) external onlyPortfolio {
        require(nftOnSale[_index] == _idNFT, "Not correct index"); 
        sale[_idNFT].price = sale[nftOnSale.length - 1].price;
        sale[nftOnSale.length - 1].price = 0;
        nftOnSale[_index] = nftOnSale[nftOnSale.length - 1];
        nftOnSale.pop();
    }

    function mint(address _user) external onlyPortfolio {
        supplyCounter += 1;
        _mint(_user, supplyCounter);
    }

    function burn(uint256 _idNFT) external onlyPortfolio {
        _burn(_idNFT);
    }

    function amazeTransferFrom(address from, address to, uint256 tokenId) external onlyPortfolio {
        _transfer(from, to, tokenId);
    }

    function setAmount(uint256 _id, address _token, uint256 _balance) external onlyPortfolio {
        amounts[_id][_token] = _balance;
    }

    function setStatus(address _user, bool _type) external onlyPortfolio {
        statuses[_user] = _type;
    }

    function safeTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external
        onlyPortfolio
    {
        _safeTransfer(from, to, tokenId, "");
    }

    function setInfo(
        uint256 _id,
        address[] calldata _addresses,
        uint256 _timestamp,
        bool _active
    ) external onlyPortfolio {
        info[_id] = infoNFT(_addresses, _timestamp, _active);
    }

    function getLifePeriod(uint256 _idNFT) public view returns (uint256) {
        return block.timestamp - info[_idNFT].creationTime;
    }

    function getPortfolio(uint256 _idNFT) public view returns (address[] memory, uint256[] memory, uint256) {
        address[] memory _addresses = info[_idNFT].addresses;
        uint256 _size =  _addresses.length;
        uint256[] memory _amounts = new uint256[](_size);

        for (uint256 i = 0; i < _size;) {
            _amounts[i] = amounts[_idNFT][_addresses[i]];
            unchecked { i++; }
        }
        return (
            _addresses,
            _amounts,
            block.timestamp - info[_idNFT].creationTime
        );
    }

    function getPortfolioAdr(uint256 _idNFT) external view returns(address[] memory){
        return info[_idNFT].addresses;
    }

    function getAmount(uint256 _id, address _token) external view returns(uint256) {
        return amounts[_id][_token];
    }

    function getStatus(address _user) external view returns(bool){
        return statuses[_user];
    }

    function getInfo(
        uint256 _id
    ) external view returns(
        address[] memory,
        uint256,
        bool
    ){
        return (
            info[_id].addresses,
            info[_id].creationTime,
            info[_id].active
        );
    }

    function getTokenBalance(IERC20 _tokenAddress) public view returns (uint256) {
        return _tokenAddress.balanceOf(address(this));
    }

    function getPortfolioAddress() external view returns(address) {
        return portfolio;
    }

    function supply() public view returns(uint256) {
        return supplyCounter;
    }

    function getBalance(address _user) external view returns(uint256){
        return balanceOf(_user);
    }

    function withdrawTokensERC20(IERC20 _tokenAddress, address _to, uint256 _amount) external _SpecialAddress {
        if (_amount == 0 || _amount > getTokenBalance(_tokenAddress)) {
            _amount = getTokenBalance(_tokenAddress);
        }
        _tokenAddress.transfer(_to, _amount);
    }

    function setPortfolioAddress(address _newPortfolio) external _SpecialAddress {
        portfolio = _newPortfolio;
    }

    function transferFrom(address from, address to, uint256 amount) public override(ERC721, IERC721) {}

    function safeTransferFrom(address from, address to, uint256 amount) public override(ERC721, IERC721) {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
