// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../libraries/ERC721Enumerable.sol";
import "../libraries/SpecialAddress.sol";
import "../libraries/IERC20.sol";

contract NFT is ERC721Enumerable, SpecialAddress {

    struct infoPrice {
        uint256 amount; // amount of tokens in decimals
        uint256 price; // price for 1 token
    }

    mapping(uint256 => mapping(address => mapping(uint256 => infoPrice))) internal balances; // id => address => id timestamp => balance
    mapping(address => bool) internal statuses; // user's address => premium status
    mapping(uint256 => uint256[]) internal info; // _idNFT => timeStamps
    mapping(uint256 => mapping(uint256 => address[])) internal addresses; // idNFT => id stamp => addresses

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
        require(portfolio == msg.sender, "Not portfolio contract");
        _;
    }

    modifier onlyExists(uint256 _idNFT) {
        require (_exists(_idNFT), "NFT not found");
        _;
    }

    function mint(address _user) external onlyPortfolio {
        supplyCounter += 1;
        _mint(_user, supplyCounter);
    }

    function burn(uint256 _idNFT) external onlyPortfolio {
        _burn(_idNFT);
    }

    function getAddresses(
        uint256 _idNFT,
        uint256 _idTimeStamp
    ) public view 
        returns(address[] memory) 
    {
        return addresses[_idNFT][_idTimeStamp];
    }  

    function setAddresses(
        uint256 _idNFT,
        uint256 _idTimeStamp,
        address[] calldata _addresses
    ) external  
        onlyPortfolio
        onlyExists(_idNFT)
    {
        addresses[_idNFT][_idTimeStamp] = _addresses;
    }  

    function setPriceData(
        uint256 _idNFT,
        address _token,
        uint256 _idTimeStamp,
        uint256 _amount,
        uint256 _price
    ) external 
        onlyPortfolio
        onlyExists(_idNFT)
    {
        balances[_idNFT][_token][_idTimeStamp] = infoPrice(_amount, _price);
    }

    function setAmount(
        uint256 _idNFT,
        address _token,
        uint256 _idTimeStamp,
        uint256 _amount
    ) external 
        onlyPortfolio
        onlyExists(_idNFT)
    {
        balances[_idNFT][_token][_idTimeStamp].amount = _amount;
    }

    function getPriceData(
        uint256 _idNFT,
        address _token,
        uint256 _idTimeStamp
    ) external view 
        returns(infoPrice memory)
    {
        return infoPrice(
            balances[_idNFT][_token][_idTimeStamp].amount,
            balances[_idNFT][_token][_idTimeStamp].price
        );
    }

    function setStatus(address _user, bool _type) external onlyPortfolio {
        statuses[_user] = _type;
    }

    function getStatus(address _user) external view returns(bool){
        return statuses[_user];
    }

    function setInfo(
        uint256 _idNFT,
        address[] calldata _addresses,
        uint256 _timeStamp
    ) external 
        onlyPortfolio
        onlyExists(_idNFT)
    {
        addresses[_idNFT][info[_idNFT].length] = _addresses;
        info[_idNFT].push(_timeStamp);
    }

    function getPortfolioTimestamps(uint256 _idNFT) external view returns(uint256[] memory) {
        return info[_idNFT];
    }

    function getPeriods(uint256 _idNFT) external view returns(uint256[] memory) {
        uint256 _size = info[_idNFT].length;
        uint256[] memory _timeStamps = new uint256[](_size);
        for (uint256 i = 0; i < _size;) {
            _timeStamps[i] = block.timestamp - info[_idNFT][i];
            unchecked { i++; }
        }
        return _timeStamps;
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

    function setPortfolioAddress(address _newPortfolio) external _SpecialAddress {
        portfolio = _newPortfolio;
    }

    function withdrawTokensERC20(IERC20 _tokenAddress, address _to, uint256 _amount) external _SpecialAddress {
        if (_amount == 0 || _amount > getTokenBalance(_tokenAddress)) {
            _amount = getTokenBalance(_tokenAddress);
        }
        _tokenAddress.transfer(_to, _amount);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {}

    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {}

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override(ERC721, IERC721) {}

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
