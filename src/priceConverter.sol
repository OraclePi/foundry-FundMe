// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library priceConverter {
    function getPrice(AggregatorV3Interface v3Interface) internal view returns (uint256) {
        (, int256 price,,,) = v3Interface.latestRoundData();
        // 8 after dot
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface v3Interface) internal view returns (uint256) {
        uint256 ethPrice = getPrice(v3Interface);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion(AggregatorV3Interface v3Interface) internal view returns (uint256) {
        return v3Interface.version();
    }
}
