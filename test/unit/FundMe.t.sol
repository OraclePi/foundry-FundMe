// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import Test and console
import {FundMe} from "../../src/FundMe.sol"; // import src contract
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // variable in storage

    modifier funded() {
        vm.prank(fundMe.OWNER());
        fundMe.fund{value: 1e18}();
        _;
    }

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

    function testFundFailWithoutEnoughETH() public {
        vm.prank(fundMe.OWNER());
        vm.expectRevert(); // next line should revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        // vm.prank(fundMe.OWNER());
        // fundMe.fund{value: 1e18}();
        uint256 amountFunded = fundMe.addressToAmountFunded(fundMe.OWNER());
        assertEq(1e18, amountFunded);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        // vm.startPrank(fundMe.OWNER());
        // fundMe.fund{value: 1e18}();
        // vm.stopPrank();
        address funder = fundMe.getFunder(0);
        assertEq(funder, fundMe.OWNER());
    }

    function testOnlyOWNERCanWithdraw() public funded {
        vm.expectRevert();
        // vm.prank(fundMe.OWNER());
        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingFunderBalance = fundMe.OWNER().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.OWNER());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endingFunderBalance = fundMe.OWNER().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFunderBalance + startingFundMeBalance, endingFunderBalance);
        assertEq(0, endingFundMeBalance);
    }

    function testWithDrawFromMultiFunders() public funded {
        //Arrange
        uint256 numberOfFunders = 10;
        uint256 startingFunderIndex = 0;
        vm.txGasPrice(1);
        uint256 gasStart = gasleft();
        for (uint160 i = 0; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), 1e18);
            // vm.startPrank(address(i));
            // vm.deal(address(i), 1e18);
            fundMe.fund{value: 1e18}();
            // vm.stopPrank();
        }
        uint256 gasEnd = gasleft();
        console.log("gasUsed: ", (gasStart - gasEnd));
        uint256 startingOWNERBalance = fundMe.OWNER().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.OWNER());
        fundMe.cheaperWithdraw();
        // fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOWNERBalance + startingFundMeBalance, fundMe.OWNER().balance);
    }
}
