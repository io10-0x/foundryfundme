//SDPX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../src/test/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address pricefeedaddress;
    }
    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getsepoliapricefeedaddress();
        } else if (block.chainid == 31337) {
            activeConfig = getanvilpricefeedaddress();
        }
    }

    function getsepoliapricefeedaddress()
        public
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getanvilpricefeedaddress() public returns (NetworkConfig memory) {
        uint8 decimals = 8;
        int256 initialPrice = 200000000000;
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            decimals,
            initialPrice
        );
        vm.stopBroadcast();
        return NetworkConfig(address(mockV3Aggregator));
    }
}
