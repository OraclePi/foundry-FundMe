// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import Test and console
import {FundMe} from "../../src/FundMe.sol"; // import src contract
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionTests is Test {
    FundMe fundMe; // variable in storage
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testUserCanFundInteractions() public {
        FundFundMe _fundFundMe = new FundFundMe();
        _fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe _withdrawFundMe = new WithdrawFundMe();
        _withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
