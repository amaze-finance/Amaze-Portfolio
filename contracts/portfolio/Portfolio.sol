// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./NFT.sol";

contract Portfolio is SpecialAddress {
    
    NFT public amaze;
    IERC20 public paymentToken;
    address public native; // = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
    address payable public feeKeeper;
    uint256 public cost;
    uint256 public fee;

    constructor (
        NFT amaze_,
        IERC20 paymentToken_,
        address native_,
        address payable feeKeeper_,
        uint256 cost_,
        uint256 fee_,
        address specialAddress_
    ) {
        amaze = amaze_;
        paymentToken = paymentToken_;
        native = native_;
        feeKeeper = feeKeeper_;
        cost = cost_;
        fee = fee_;
        specialAddresses[specialAddress_] = true;
        specialAddresses[msg.sender] = true;
    }

    modifier onlyNftOwner(uint256 _idNFT) {
        require(
            amaze.ownerOf(_idNFT) == msg.sender,
            "Not user's NFT"
        );
        _;
    }

    modifier nftOnSale(uint256 _idNFT) {
        require(
            amaze.isNftOnSale(_idNFT),
            "This NFT not on sale"
        );
        _;
    }

     modifier onlyActive(uint256 _idNFT) {
        require(
            amaze.isNftActive(_idNFT),
            "This NFT not active"
        );
        _;
    }

    function buyPremium() external {
        paymentToken.transferFrom(msg.sender, address(this), cost);
        amaze.setStatus(msg.sender, true);
    }

    // баланс передается
    // проверка на владение токеном проекта скорее всего выкатываем во второй версии проекта
    // создание портфелей за токен проекта 
    function create(
        IERC20[] calldata _tokens,
        uint256[] calldata _amounts
    ) external payable {
        uint256 _size = _tokens.length;
        require(_size == _amounts.length, "Not same length");
        if (amaze.balanceOf(msg.sender) == 1) {
            require(amaze.getStatus(msg.sender), "You should by premium");
        }
        _size += 1;
        uint256 i = 1;
        uint256 _supply = amaze.supply() + 1;
        address[] memory _addresses = new address[](_size);
        amaze.setAmount(_supply, native, msg.value);
        _addresses[0] = native;

        for (i ; i < _size;) {
            _tokens[i].transferFrom(msg.sender, address(this), _amounts[i]);
            amaze.setAmount(_supply, address(_tokens[i]), _amounts[i]);
            _addresses[i] = address(_tokens[i]);
            unchecked { i++; }
        }
        amaze.setInfo(_supply, _addresses, block.timestamp, true);
        amaze.mint(msg.sender);
    }
    // _feeAmount ???
    function remove (
        uint256 _idNFT,
        uint256[] memory _feeAmount
    ) external payable
        onlyNftOwner(_idNFT)
        onlyActive(_idNFT)
    {
        _remove(_idNFT, _feeAmount);
        amaze.burn(_idNFT);
    }
 
    function setToSale(
        uint256 _idNFT,
        uint256 _price,
        IERC20 _token
    ) external
        onlyNftOwner(_idNFT)
    {
        require(_price > 0, "Zero price");
        require(
            !amaze.isNftOnSale(_idNFT),
            "This NFT already on sale"
        );
        require(
            amaze.ownerOf(_idNFT) == msg.sender,
            "Not user's NFT"
        );
        amaze.addNftOnSale(_idNFT, _price, _token);
    }
 
    function changeSaleInfo(
        uint256 _idNFT,
        uint256 _newPrice,
        IERC20 _token
        ) external
        onlyNftOwner(_idNFT)
        nftOnSale(_idNFT)
    {
        amaze.setNftSaleInfo(_idNFT, _newPrice, _token);
    }

    function deleteFromSale(
        uint256 _idNFT,
        uint256 _index
    ) external
        onlyNftOwner(_idNFT)
        nftOnSale(_idNFT)
    {
        amaze.removeNFT(_idNFT, _index);
    }
    // просмотреть еще раз и после этого просмотреть все функции еще раз
    // price = 0
    function buy(
        uint256 _idNFT,
        uint256 _index,
        uint256[] memory _feeAmount
    ) external
        nftOnSale(_idNFT) 
    {   
        uint256 comission = amaze.getNftPrice(_idNFT) * fee / 100;
        IERC20(amaze.getNftPaymentToken(_idNFT)).transferFrom(msg.sender, amaze.ownerOf(_idNFT), amaze.getNftPrice(_idNFT) - comission);
        IERC20(amaze.getNftPaymentToken(_idNFT)).transferFrom(msg.sender, feeKeeper, comission);
        if (amaze.isNftActive(_idNFT)) {
            _remove(_idNFT, _feeAmount);
        }
        amaze.safeTransfer(amaze.ownerOf(_idNFT), msg.sender, _idNFT);
        amaze.removeNFT(_idNFT, _index);
    }

    function withdrawTokens(IERC20[] calldata _tokenAddress, uint256[] memory _amount, uint256 _amountETH) external payable _SpecialAddress {
        uint256 _size = _tokenAddress.length;
        require(_size == _amount.length, "Not same size");
        if (_amountETH > 0) {
            payable(msg.sender).transfer(_amountETH);
        }
        for (uint256 i = 0; i < _size;) {
            if (_amount[i] == 0 || _amount[i] > getTokenBalance(_tokenAddress[i])) {
                _amount[i] = getTokenBalance(_tokenAddress[i]);
            }
            _tokenAddress[i].transfer(msg.sender, _amount[i]);
            unchecked {i++;}
        }
    }

    function _remove(
        uint256 _idNFT,
        uint256[] memory _feeAmount
    ) internal   
    {
        uint256 i = 1;
        address[] memory _addresses = amaze.getPortfolioAdr(_idNFT);
        if (amaze.getAmount(_idNFT, native) > 0) {
            payable(msg.sender).transfer(amaze.getAmount(_idNFT, native) - _feeAmount[0]);
            feeKeeper.transfer(_feeAmount[0]);
            // amaze.setAmount(_idNFT, native, 0);
        }
        for (i ; i < _addresses.length;) {
            IERC20(_addresses[i]).transfer(
                msg.sender,
                amaze.getAmount(_idNFT, address(_addresses[i])) - _feeAmount[i]
            );
            IERC20(_addresses[i]).transfer(
                feeKeeper,
                _feeAmount[i]
            );
            // amaze.setAmount(_idNFT, address(_addresses[i]), 0);
            unchecked { i++; }
        }
        amaze.removeActive(_idNFT);
        // amaze.burn(_idNFT);
    }

    function setPaymentToken(IERC20 _newToken) external _SpecialAddress {
        paymentToken = _newToken;
    }

    function setAmaze(NFT _newAmaze) external _SpecialAddress {
        amaze = _newAmaze;
    }

    function setNativeToken(address _newNative) external _SpecialAddress {
        native = _newNative;
    }

    function setCost(uint256 _newCost) external _SpecialAddress {
        cost = _newCost;
    }

    function setFee(uint256 _newFee) external _SpecialAddress {
        fee = _newFee;
    }

    function getPaymentToken() external view returns(address){
        return address(paymentToken);
    }

    function getAmaze() external view returns(address) {
        return address(amaze);
    }

    function getNativeToken() external view returns(address) {
        return address(native);
    }

    function getCost() external view returns(uint256){
        return cost;
    }

    function getFee() external view returns(uint256){
        return fee;
    }

    function getTokenBalance(IERC20 _tokenAddress) public view returns (uint256) {
        return _tokenAddress.balanceOf(address(this));
    }

    // function getOnSaleNFTs(uint256 _firstIndex, uint256 _secondIndex) external view returns(uint256[] memory, uint256[] memory) {
    //     uint256 _size = _secondIndex - _firstIndex;
    //     uint256[] memory _prices = new uint256[](_size);
    //     for (uint256 i = _firstIndex; i < _size;) {
    //         _prices[i] = saleInfo[nftOnSale[i]];
    //         unchecked { i++; }
    //     }
    //     return (nftOnSale, _prices);
    // }
}