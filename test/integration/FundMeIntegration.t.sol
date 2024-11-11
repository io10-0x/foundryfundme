//SDPX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundScript, WithdrawScript} from "../../script/FundandWithdraw.s.sol";
import {FundMe} from "../../src/Fundme.sol";

contract FundMeIntegration is Test {
    FundScript fundscript;
    WithdrawScript withdrawscript;
    address latestfundmedeploy;
    FundMe fundme;
    uint256 value = 1 ether;

    function setUp() external {
        fundscript = new FundScript();
        withdrawscript = new WithdrawScript();
        latestfundmedeploy = fundscript.run();
    }

    function test_usercanfundandownercanwithdraw() external payable {
        fundme = FundMe(payable(latestfundmedeploy));
        fundscript.fundfundmecontract(latestfundmedeploy);
        assertEq(address(fundme).balance, value);
        withdrawscript.withdrawfundmecontract(latestfundmedeploy);
        assertEq(address(fundme).balance, 0);
    }
}
