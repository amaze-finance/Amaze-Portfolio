// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./NFT.sol";
import "../price-feeds/PriceFeedCalculator.sol";

contract Portfolio is SpecialAddress {

    struct removeData {
        uint256 amount;
        uint256 margin;
    }

    struct data {
        uint256 size;
        uint256[] prices;
    }
    
    NFT public amaze;
    IERC20 public paymentToken;
    Calculator public calculator;
    address public native; // '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"';
    address payable public feeKeeper;
    uint256 public cost; // price of premium status

    mapping(address => uint256) internal balanceFee; // address token => available balance to withdraw

    event Create(
        address indexed owner,
        uint256 indexed id,
        address[] tokens,
        uint256[] amounts,
        uint256[] prices,
        uint256 timestamp
    );

    event AddLiquidity(
        address indexed owner,
        uint256 indexed id,
        address[] tokens,
        uint256[] amounts,
        uint256[] prices,
        uint256 timestamp
    );

    event EtherFee(address indexed from, uint256 indexed amountFee);
    event TokenFee(address indexed token, address indexed from, uint256 indexed amountFee);
    event Fallback(address indexed sender, uint256 indexed value);

    constructor (
        NFT amaze_,
        IERC20 paymentToken_,
        Calculator calculator_,
        address native_,
        address payable feeKeeper_,
        uint256 cost_,
        address specialAddress_
    ) {
        amaze = amaze_;
        paymentToken = paymentToken_;
        calculator = calculator_;
        native = native_;
        feeKeeper = feeKeeper_;
        cost = cost_;
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

    function buyPremium() external {
        require(
            !amaze.getStatus(msg.sender),
            "You alredy get premium status"
        );
        paymentToken.transferFrom(msg.sender, address(this), cost);
        amaze.setStatus(msg.sender, true);
    }

    function createPortfolio (
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) external payable {
        if (amaze.balanceOf(msg.sender) == 1) {
            require(
                amaze.getStatus(msg.sender),
                "You should by premium"
            );
        }
        data memory _data = getData(_tokens, _amounts);
        uint256 i;
        uint256 _supply = amaze.supply() + 1;
        amaze.mint(msg.sender);
        if (msg.value > 0) {
            setEtherInfo(_supply, 0, msg.value, _data.prices[0], _tokens[0]);
            i ++;
        }
        _addLiquidity(_tokens, _amounts, _data.prices, i, _data.size, _supply, 0);
        emit Create(
            msg.sender,
            _supply,
            _tokens,
            _amounts,
            _data.prices,
            block.timestamp
        );
    }

    function addLiquidity (
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        uint256 _idNFT
    ) external payable 
        onlyNftOwner(_idNFT) 
    {
        data memory _data = getData(_tokens, _amounts);
        uint256 i;
        uint256 _amountTimestamps = amaze.getPortfolioTimestamps(_idNFT).length;
        if (msg.value > 0) {
            setEtherInfo(_idNFT, _amountTimestamps, msg.value, _data.prices[0], _tokens[0]);
            i ++;
        }
        _addLiquidity(_tokens, _amounts, _data.prices, i, _data.size, _idNFT, _amountTimestamps);
        emit AddLiquidity(
            msg.sender,
            _idNFT,
            _tokens,
            _amounts,
            _data.prices,
            block.timestamp
        );
    }

    function _addLiquidity (
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        uint256[] memory _prices,
        uint256 i,
        uint256 _size,
        uint256 _idNFT,
        uint256 _idTimestamp
    ) internal 
    {
        for (i ; i < _size;) {
            IERC20(_tokens[i])
                .transferFrom(
                    msg.sender,
                    address(this),
                    _amounts[i]
            );
            amaze.setPriceData(
                _idNFT,
                _tokens[i],
                _idTimestamp,
                _amounts[i],
                _prices[i]
            );
            unchecked { i++; }
        }
        amaze.setInfo(_idNFT, _tokens, block.timestamp);
    }

    function getData(
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) internal view  returns (data memory)
    {
        uint256 _size = _tokens.length;
        require(_size == _amounts.length, "Not same length");
        uint256[] memory _prices = 
            calculator.getTokensPrice(_tokens);
        return data(
            _size,
            _prices
        );
    }

    function setEtherInfo(
        uint256 _idNFT,
        uint256 _idTimestamp,
        uint256 _value,
        uint256 _price,
        address _token
    ) internal {
        require(_token == native, "Wrong data");
        amaze.setPriceData(
            _idNFT,
            native,
            _idTimestamp,
            _value,
            _price
        );
    }

    function removeLiquidity (
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        uint256 _idNFT
    ) external payable
        onlyNftOwner(_idNFT)
    {
        address _tokenAddress;
        uint256[] memory _memory = new uint256[](5);
        _memory[0] = _tokens.length;
        require(_memory[0] == _amounts.length, "Not same length");
        uint256[] memory _timeStamps = 
            amaze.getPortfolioTimestamps(_idNFT);
        uint256[] memory _prices =
            calculator.getTokensPrice(_tokens);
        _memory[1] = _timeStamps.length;
        for (uint256 i = 0; i <_memory[0];) {
            _memory[2] = _amounts[i];
            _memory[3] = 0;
            _tokenAddress = _tokens[i];
            removeData memory _data = _removeLiquidity(
                _memory[1],
                _idNFT,
                _tokenAddress,
                _memory[3],
                _prices[i],
                _memory[2]
            );
            if (_data.amount == 0 ) {
                _memory[4] = _amounts[i];
            } else {
                _memory[4] = _amounts[i] - _data.amount;
            }
            if (_tokenAddress == native) {
                payable(msg.sender).transfer(_memory[4] - _data.margin);
                if (_data.margin > 0) {
                    balanceFee[native] += _data.margin;
                    emit EtherFee(msg.sender, _data.margin);
                } 
            } else {
                IERC20(_tokenAddress).transfer(msg.sender, _memory[4] - _data.margin);
                if (_data.margin > 0) {
                    balanceFee[_tokenAddress] += _data.margin;
                    emit TokenFee(_tokenAddress, msg.sender, _data.margin);
                }
            }
            unchecked { i++; }
        }
    }

    function _removeLiquidity(
        uint256 _sizeStamps,
        uint256 _idNFT,
        address _tokenAddress,
        uint256 _tokenMargin,
        uint256 _price,
        uint256 _amountCounter
    ) internal  returns(
        removeData memory 
    )
    {
        for (uint256 j = 0; j < _sizeStamps;) {
                if (amaze.getPriceData(_idNFT, _tokenAddress, j).amount > 0 && _amountCounter > 0) {
                    _tokenMargin += calculator.editDecimalsToToken(
                        (calculator.calculateMargin(
                            amaze.getPriceData(
                                _idNFT,
                                _tokenAddress,
                                j
                            ).price, _price) *
                        amaze.getPriceData(_idNFT, _tokenAddress, j).amount) / 100);
                    if (_amountCounter <= amaze.getPriceData(_idNFT, _tokenAddress, j).amount) {
                        amaze.setAmount(
                            _idNFT,
                            _tokenAddress,
                            j,
                            amaze.getPriceData(_idNFT, _tokenAddress, j).amount - _amountCounter
                        );
                        _amountCounter = 0;
                    } else {
                        _amountCounter -= amaze.getPriceData(_idNFT, _tokenAddress, j).amount;
                        amaze.setAmount(
                            _idNFT,
                            _tokenAddress,
                            j,
                            0
                        );
                    }
                }
                unchecked { j++; } 
        }
        return removeData(
            _amountCounter,
            _tokenMargin
        );
    }


    function removePortfolio (
        uint256 _idNFT
    ) external payable 
        onlyNftOwner(_idNFT) 
    {
        uint256[] memory _timeStamps = 
            amaze.getPortfolioTimestamps(_idNFT);
        uint256 _tokenMargin;
        uint256 _sizeStamps = _timeStamps.length;
        uint256 _sizeTokens;
        uint256 _id = _idNFT;
        for (uint256 i = 0; i < _sizeStamps;) {
            address[] memory _addresses =  amaze.getAddresses(_id, i);
            _sizeTokens = _addresses.length;
            uint256[] memory _prices =
                calculator.getTokensPrice(_addresses);
            for (uint256 j = 0; j < _sizeTokens;) {
                _tokenMargin = calculator.editDecimalsToToken(
                        (calculator.calculateMargin(
                            amaze.getPriceData(
                                _id,
                                _addresses[j],
                                i
                            ).price, _prices[j]) *
                        amaze.getPriceData(_id, _addresses[j], i).amount) / 100);
                if (_addresses[j] == native) {
                    payable(msg.sender).transfer(
                        amaze.getPriceData(
                            _id,
                            _addresses[j],
                            i
                        ).amount - _tokenMargin);
                    if (_tokenMargin > 0) {
                        balanceFee[native] += _tokenMargin;
                        emit EtherFee(msg.sender, _tokenMargin);
                    }
                } else {
                    IERC20(_addresses[j]).transfer(
                        msg.sender,
                        amaze.getPriceData(
                            _id,
                            _addresses[j],
                            i
                        ).amount - _tokenMargin);
                    if (_tokenMargin > 0) {
                        balanceFee[_addresses[j]] += _tokenMargin;
                        emit TokenFee(_addresses[j], msg.sender, _tokenMargin);
                    }
                }
                unchecked { j++; }
            }
            unchecked { i++; }
        }
        amaze.burn(_id);
    }

    function withdrawTokens(
        IERC20[] calldata _tokenAddress,
        uint256[] memory _amount,
        uint256 _amountETH
    ) external payable
        _SpecialAddress 
    {
        uint256 _size = _tokenAddress.length;
        require(_size == _amount.length, "Not same size");
        if (_amountETH > 0) {
            payable(msg.sender).transfer(_amountETH);
        }
        for (uint256 i = 0; i < _size;) {
            if (_amount[i] == 0 ||
                _amount[i] > getTokenBalance(_tokenAddress[i])
            ) {
                _amount[i] = getTokenBalance(_tokenAddress[i]);
            }
            _tokenAddress[i].transfer(msg.sender, _amount[i]);
            unchecked {i++;}
        }
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

    function getTokenBalance(
        IERC20 _tokenAddress
    ) public view returns (uint256) {
        return _tokenAddress.balanceOf(address(this));
    }

    function getBalanceFee(address _token) external view returns(uint256){
        return balanceFee[_token];
    }

    fallback() external payable
    {
        emit Fallback(msg.sender, msg.value);
    }

    receive() external payable {}
}