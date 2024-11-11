//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundScript is Script {
    address public fundmelatestdeploy;

    function run() external returns (address) {
        fundmelatestdeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid,
            "/home/io10-0x/foundryprojects/foundryfundme/broadcast"
        );
        return fundmelatestdeploy;
    }

    function fundfundmecontract(address mostrecentlydeployed) external payable {
        vm.startBroadcast();
        FundMe fundme = FundMe(payable(mostrecentlydeployed));
        fundme.fund{value: 1 ether}();
        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {
    function withdrawfundmecontract(address mostrecentlydeployed) external {
        vm.startBroadcast(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        );
        FundMe fundme = FundMe(payable(mostrecentlydeployed));
        fundme.withdraw();
        vm.stopBroadcast();
    }
}
