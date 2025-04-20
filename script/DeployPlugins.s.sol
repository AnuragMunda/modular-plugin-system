// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/src/Script.sol";
import {ExamplePlugin} from "../src/plugins/ExamplePlugin.sol";
import {VaultPlugin} from "../src/plugins/VaultPlugin.sol";

contract DeployPlugins is Script {
    ExamplePlugin examplePlugin;
    VaultPlugin vaultPlugin;

    function deployPlugins() public returns (ExamplePlugin, VaultPlugin) {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        examplePlugin = new ExamplePlugin();
        vaultPlugin = new VaultPlugin();
        vm.stopBroadcast();

        return (examplePlugin, vaultPlugin);
    }

    function run() external returns (ExamplePlugin, VaultPlugin) {
        return deployPlugins();
    }
}
