// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

interface IAggregatorV3Interface{

function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

contract ChainlinkPriceFeed {

    /**
     * Returns the latest price
     */
    function getLatestPrice(address priceFeed) public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = IAggregatorV3Interface(priceFeed).latestRoundData();
        return price;
    }
}
