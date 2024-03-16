// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import Test and console
import {FundMe} from "../src/FundMe.sol"; // import src contract
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // variable in storage

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMiniumUSD() public view {
        console.log("check if minium usd");
        console.log(fundMe.MINIUM_USD());
        assertEq(fundMe.MINIUM_USD(), 1e18); // assert equal
    }

    function testIsOWNER() public view {
        console.log("check if owner");
        console.log(fundMe.OWNER());
        console.log(address(this));
        console.log(msg.sender);
        assertEq(fundMe.OWNER(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        console.log("check if version accurate");
        uint256 version = fundMe.getPriceFeedVersion();
        console.log(version);
        console.log(fundMe.getPriceFeedVersion());
        assertEq(version, 4);
    }
}
