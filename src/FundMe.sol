// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {priceConverter} from "./priceConverter.sol";

error notOwner();
error notEnoughUsd();
error callFailed();

contract FundMe {
    using priceConverter for uint256;

    uint256 public constant MINIUM_USD = 1e18;
    uint256 public version;
    uint256 public priceToUsd;
    address[] public funders;
    address public immutable OWNER;
    AggregatorV3Interface private s_priceFeed;

    mapping(address => uint256) public addressToAmountFunded;

    constructor(address priceFeed) {
        OWNER = msg.sender; // executed once the contract deployed
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOWNER() {
        // require(msg.sender == OWNER,"owner required");

        // a more gas friendly way
        if (msg.sender != OWNER) {
            revert notOwner();
        }
        _; // code executed after the above line
    }

    event receiveCalled(address sender, uint256 value);

    event fallbackCalled(address sender, uint256 value, bytes data);

    function fund() public payable onlyOWNER {
        if (msg.value.getConversionRate(s_priceFeed) <= MINIUM_USD) {
            revert notEnoughUsd();
        }
        funders.push(msg.sender);
        version = priceConverter.getVersion(s_priceFeed);
        priceToUsd = priceConverter.getPrice(s_priceFeed);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOWNER {
        // reset the addressToAmountFunded
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // re-initialize the funders
        funders = new address[](0);

        // // withdraw the fund using transfer , send , call
        // // transfer , limited up to 2300 gas , pop up failure
        // payable(msg.sender).transfer(address(this).balance);

        // //send , limited up to 2300 gas , returns bool
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"send failed");

        //call , no limited , returns bool and bytes
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert callFailed();
        }
    }

    function getPriceFeedVersion() public view returns (uint256) {
        return priceConverter.getVersion(s_priceFeed);
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    receive() external payable {
        emit receiveCalled(msg.sender, msg.value);
        fund();
    }

    fallback() external payable {
        emit fallbackCalled(msg.sender, msg.value, msg.data);
        fund();
    }
}
