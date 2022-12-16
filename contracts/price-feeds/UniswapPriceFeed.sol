// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract UniswapPriceFeed {
    address public factory;

    constructor(
        address factory_
    ) {
        factory = factory_;
    }

    function estimateAmountOut(
        address tokenIn,
        address tokenOut,
        uint128 amountIn,
        uint32 secondsAgo,
        uint24 _fee
    ) external view returns (uint amountOut) {

        require(tokenIn != tokenOut, "invalid token");

        address _pool = IUniswapV3Factory(factory).getPool(
            tokenIn,
            tokenOut,
            _fee
        );
        require(_pool != address(0), "pool doesn't exist");


        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(_pool).observe(
            secondsAgos
        );

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        int24 tick = int24(tickCumulativesDelta / secondsAgo);
        
        if (
            tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)
        ) {
            tick--;
        }

        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            tokenIn,
            tokenOut
        );
    }

    function setFactory(address _newAddress) external {
        factory = _newAddress;
    }

    function getFactory() external view returns(address){
        return factory;
    }
}