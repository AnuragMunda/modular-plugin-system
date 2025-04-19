// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IPlugin} from "../interface/IPlugin.sol";

/**
 * @title Example Plugin
 * @author Anurag Munda
 *
 * @dev A simple plugin implementation that adheres to the IPlugin interface.
 * This plugin demonstrates how a basic plugin can be integrated with the Core system.
 *
 * Example Functionality:
 * - Multiplies the input value by a constant factor (e.g., 2) and returns the result.
 *
 * This plugin serves as a minimal working example for dynamic plugin execution.
 */
contract ExamplePlugin is IPlugin {
    uint256 public constant CONSTANT_FACTOR = 10;

    function performAction(uint256 _input) external pure returns (uint256) {
        return CONSTANT_FACTOR * _input;
    }
}
