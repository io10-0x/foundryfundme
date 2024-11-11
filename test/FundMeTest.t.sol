//SDPX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/Fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    DeployFundMe deployfundme;
    FundMe fundme;
    uint256 constant value = 0.25 ether;
    address user1 = vm.addr(1);

    function setUp() public {
        deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
    }

    function test_minimumUSD() public view {
        console.log("Minimum USD: ", fundme.MINIMUM_USD());
        assertEq(fundme.MINIMUM_USD(), 50000000000000000000);
    }

    function test_RevertIf_lessThanMinimumUSD() public payable {
        vm.expectRevert("You need to spend more ETH!");
        fundme.fund{value: 0.001 ether}();
    }

    function test_contractcanbefunded() public payable {
        vm.prank(user1);
        vm.deal(user1, value);
        fundme.fund{value: value}();
        address pricefeedaddress = deployfundme.pricefeedaddress();
        console.log(
            PriceConverter.getConversionRate(
                value,
                AggregatorV3Interface(pricefeedaddress)
            )
        );
        assertEq(address(fundme).balance, value);
    }

    function test_contractcanbefundedmultiplefunders() public payable {
        uint256 endingindex = 4;

        for (uint i = 1; i < endingindex; i++) {
            uint256 fundval = i * 10 ** 18;
            hoax(vm.addr(i), fundval);
            fundme.fund{value: fundval}();
        }
        uint256 fundvaladdr1 = 1 * 10 ** 18;
        uint256 fundvaladdr2 = 2 * 10 ** 18;
        uint256 fundvaladdr3 = 3 * 10 ** 18;

        uint256 addr1amount = fundme.getamountfunded(vm.addr(1));
        uint256 addr2amount = fundme.getamountfunded(vm.addr(2));
        uint256 addr3amount = fundme.getamountfunded(vm.addr(3));
        assertEq(addr1amount, fundvaladdr1);
        assertEq(addr2amount, fundvaladdr2);
        assertEq(addr3amount, fundvaladdr3);
    }

    modifier beenFunded() {
        vm.prank(user1);
        vm.deal(user1, value);
        fundme.fund{value: value}();
        _;
    }

    modifier multiplefunders() {
        uint256 endingindex = 4;

        for (uint i = 1; i < endingindex; i++) {
            uint256 fundval = i * 10 ** 18;
            hoax(vm.addr(i), fundval);
            fundme.fund{value: fundval}();
        }
        _;
    }

    function test_correctamountfundedretrieve() public payable beenFunded {
        uint256 amount = fundme.getamountfunded(user1);
        assertEq(amount, value);
    }

    function test_RevertIf_notownerwithdraw() public payable beenFunded {
        bytes4 selector = bytes4(keccak256("FundMe__NotOwner()"));

        vm.expectRevert(selector);
        hoax(user1, value);
        fundme.withdraw();
    }

    function test_ownerwithdraw() public payable beenFunded {
        uint256 userstartingbalance = msg.sender.balance;
        vm.prank(msg.sender);
        fundme.withdraw();
        uint256 contractbalance = address(fundme).balance;
        assertGt(msg.sender.balance, userstartingbalance);
        assertEq(contractbalance, 0);
    }
}
