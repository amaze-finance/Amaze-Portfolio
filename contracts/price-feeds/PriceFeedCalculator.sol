// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../portfolio/NFT.sol";
import "../libraries/ERC20.sol";
import "./ChainlinkPriceFeed.sol";
import "../interfaces/IUniswapPriceFeed.sol";
import "../libraries/SpecialAddress.sol";

contract Calculator is SpecialAddress {

    ChainlinkPriceFeed public chainlinkPriceFeed;
    IUniswapPriceFeed public uniswapPriceFeed;
    address public usdt;
    uint256 public margin; 
    uint256 public chainlinkDecimals; 
    bool public statusPriceFeedUniswap;

    mapping(address => uint24) internal uniswapFees;
    mapping(address => address) internal chainlinkProxies; // address token => address proxy

    constructor(
        ChainlinkPriceFeed _chainlinkPriceFeed,
        IUniswapPriceFeed _uniswapPriceFeed,
        address _usdt,
        uint256 _margin,
        uint256 _chainlinkDecimals,
        address[] memory _tokens,
        uint24[] memory _fees
    ) {
        chainlinkPriceFeed = _chainlinkPriceFeed;
        uniswapPriceFeed = _uniswapPriceFeed;
        usdt = _usdt;
        margin = _margin;
        chainlinkDecimals = _chainlinkDecimals;
        specialAddresses[msg.sender] = true;

        uint256 _size = _tokens.length;
        require(_size == _fees.length, "Calculator: Different size");
        for (uint256 i = 0; i < _size;) {
            uniswapFees[_tokens[i]] = _fees[i];
            unchecked { i++; }
        }
    }

    function getTokensPrice(
        address[] calldata _tokens
    ) public view 
        returns (uint256[] memory) 
    {
        uint256 _size = _tokens.length;
        uint256[] memory _prices = new uint256[](_size);
        for(uint256 i = 0; i < _size;) {
            if (statusPriceFeedUniswap == false) { 
                _prices[i] = uint(chainlinkPriceFeed.getLatestPrice(chainlinkProxies[_tokens[i]]));
            } else {
                _prices[i] = uint(uniswapPriceFeed.estimateAmountOut(_tokens[i], usdt, 10 ** 18, 10, uniswapFees[_tokens[i]]));
                _prices[i] = editDecimalsTo8(_prices[i]);
            }
            unchecked { i++; }
        }
        return _prices;
    }

    function calculateMargin(
        uint256 _firstPrice,
        uint256 _lastPrice
    ) external view 
        returns (uint256 _margins) 
    {
        if (_lastPrice > _firstPrice) {
            _margins = ((_lastPrice - _firstPrice) * margin / 100) * 100 * 10 ** chainlinkDecimals / _lastPrice;
        } else {
            _margins = 0;
        }
        return _margins;
    }

    function editDecimalsTo8(uint256 _amount) public view returns(uint256) {
        _amount = _amount / 10 ** (18 - chainlinkDecimals);        
        return _amount;
    }

    function editDecimalsToToken(uint256 _amount) public view returns(uint256) {
        _amount = _amount / 10 ** chainlinkDecimals;
        return _amount;
    }

    function setProxyInfo(
        address[] calldata _tokens,
        address[] calldata _proxies
    ) external _SpecialAddress
    {
        uint256 _size = _tokens.length;
        require(
            _size == _proxies.length,
            "Calculator: Different sizes"
        );
        for(uint256 i = 0; i < _size;) {
            chainlinkProxies[_tokens[i]] = _proxies[i];
            unchecked { i++; }
        }
    }

    function setChainlinkPriceFeed(ChainlinkPriceFeed _chainlinkPriceFeed) external _SpecialAddress {
        chainlinkPriceFeed = _chainlinkPriceFeed;
    }

    function setStatusPriceFeedUniswap(bool _statusPriceFeedUniswap) external _SpecialAddress {
        statusPriceFeedUniswap = _statusPriceFeedUniswap;
    }

    function setUniswapPriceFeed(IUniswapPriceFeed _uniswapPriceFeed) external _SpecialAddress {
        uniswapPriceFeed = _uniswapPriceFeed;
    }

    function setUsdt(address _usdt) external _SpecialAddress {
        usdt = _usdt;
    }

    function setMargin(uint256 _margin) external _SpecialAddress {
        margin = _margin;
    }

    function setChainlinkDecimals(uint256 _chainlinkDecimals) external _SpecialAddress {
        chainlinkDecimals = _chainlinkDecimals;
    }

    function getUniswapFees(address _token) public view returns (uint24) {
        return uniswapFees[_token];
    }

    function getChainlinkProxies(address _token) public view returns (address) {
        return chainlinkProxies[_token];
    }
}