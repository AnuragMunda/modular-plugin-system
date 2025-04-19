// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IPlugin Interface
 * @author Anurag Munda
 *
 * @dev This is the standard interface that all plugins must implement
 * in order to be compatible with the Core contract.
 *
 * The interface defines a single function:
 * - `performAction(uint256 input)`: Executes the plugin's logic and returns a uint256 result.
 *
 * This ensures that the Core contract can interact with any plugin
 * in a consistent and predictable way using dynamic dispatch.
 */
interface IPlugin {
    function performAction(uint256 _input) external returns (uint256);
}
