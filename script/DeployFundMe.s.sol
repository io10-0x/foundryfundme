//SDPX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address public pricefeedaddress;

    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        pricefeedaddress = helperconfig.activeConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(pricefeedaddress);
        vm.stopBroadcast();
        return fundme;
    }
}
