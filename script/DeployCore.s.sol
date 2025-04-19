// SPDX-License-Identifier: MIT 
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {Core} from "../src/core/Core.sol";

contract DeployCore is Script {
    Core core;

    function deployCore() public returns (Core) {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        core = new Core();
        vm.stopBroadcast();

        return core;
    }

    function run() external returns (Core) {
        return deployCore();
    }
}