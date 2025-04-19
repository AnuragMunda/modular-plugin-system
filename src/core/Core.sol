// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";
import {IPlugin} from "../interface/IPlugin.sol";

/**
 * @title Core Contract
 * @author Anurag Munda
 *
 * @dev This contract acts as the central manager for a modular plugin system.
 * It maintains a registry of plugin contracts that adhere to the IPlugin interface,
 * allowing dynamic execution of external plugin logic without modifying the core contract.
 *
 * Key Functionalities:
 * - Plugin Registry: Stores plugin contract addresses mapped by their IDs.
 * - Access Control: Only the owner can add, update, or remove plugins.
 * - Dynamic Dispatch: The `executePlugin` function allows users to pass an input to a specified plugin,
 *   which then returns the result after executing its own logic.
 *
 * This modular architecture promotes flexibility and upgradeability by enabling new features
 * to be added through plugins, without needing to redeploy or upgrade the core contract.
 */
contract Core is Ownable {
    /*==============================================================
                                ERRORS
    ==============================================================*/
    error Core_PluginExists();
    error Core_InvalidPlugin();
    error Core_InvalidId();
    error Core_CannotBeZeroAdress();
    error Core_PluginExecutionFailed(uint256 id);

    /*==============================================================
                            STATE VARIABLES
    ==============================================================*/
    uint256 public s_counter;
    mapping(uint256 id => address plugin) public s_pluginRegistry; // Id mapped to plugin Address. Acts as a plugin registry
    mapping(address plugin => uint256 id) public s_pluginIds; // Plugin address mapped to Id. Acts as Id getter

    /*==============================================================
                                EVENTS
    ==============================================================*/
    event PluginAdded(uint256 indexed pluginId, address pluginAddress);
    event PluginUpdated(
        uint256 indexed pluginId,
        address indexed newPluginAddress
    );
    event PluginRemoved(uint256 indexed pluginId);
    event PluginExecuted(uint256 indexed pluginId, uint256 returnedValue);

    /*==============================================================
                            FUNCTION MODIFIERS
    ==============================================================*/
    /**
     * Checks if the plugin already exists in registry
     */
    modifier newPlugin(address _pluginAddress) {
        require(s_pluginIds[_pluginAddress] == 0, Core_PluginExists());
        _;
    }

    /**
     * Checks if the plugin is present for the given id
     */
    modifier validPlugin(uint256 _pluginId) {
        require(
            s_pluginRegistry[_pluginId] != address(0),
            Core_InvalidPlugin()
        );
        _;
    }

    /**
     * Checks if the input id is within the valid range
     */
    modifier validId(uint256 _pluginId) {
        require(_pluginId > 0 && _pluginId <= s_counter, Core_InvalidId());
        _;
    }

    /**
     * Checks if the input address is a valid address (not zero address)
     */
    modifier notZeroAddress(address _address) {
        require(_address != address(0), Core_CannotBeZeroAdress());
        _;
    }

    /*==============================================================
                                FUNCTIONS
    ==============================================================*/
    constructor() Ownable(msg.sender) {}

    //*----------- External Functions -----------*/

    /**
     * @notice Adds a plugin to the registry
     * @dev Maps the current counter id with input address in `s_pluginRegistry`
     * and vice-versa in `s_pluginIds`
     *
     * @param _pluginAddress The address of the plugin to add
     * @return currentCounter The id of the added plugin
     */
    function addPlugin(
        address _pluginAddress
    )
        external
        onlyOwner
        newPlugin(_pluginAddress)
        notZeroAddress(_pluginAddress)
        returns (uint256 currentCounter)
    {
        unchecked {
            currentCounter = ++s_counter;
        }
        s_pluginRegistry[currentCounter] = _pluginAddress;
        s_pluginIds[_pluginAddress] = currentCounter;

        emit PluginAdded(currentCounter, _pluginAddress);
        return currentCounter;
    }

    /**
     * @notice Updates the plugin address present in the registry
     * @dev This function replaces/updates the address of the id present in `s_pluginRegistry` with the new address
     *
     * @param _pluginId The id of the plugin to update
     * @param _newPluginAddress Address of the updated plugin
     */
    function updatePlugin(
        uint256 _pluginId,
        address _newPluginAddress
    )
        external
        onlyOwner
        newPlugin(_newPluginAddress)
        validId(_pluginId)
        notZeroAddress(_newPluginAddress)
    {
        address oldAddress = s_pluginRegistry[_pluginId];
        s_pluginRegistry[_pluginId] = _newPluginAddress;
        delete s_pluginIds[oldAddress];
        s_pluginIds[_newPluginAddress] = _pluginId;

        emit PluginUpdated(_pluginId, _newPluginAddress);
    }

    /**
     * @notice Removes the plugin address from the registry
     * @dev This function deletes the plugin details from `s_pluginRegistry` and `s_pluginIds`
     *
     * @param _pluginId The id of the plugin to remove
     */
    function removePlugin(
        uint256 _pluginId
    ) external onlyOwner validPlugin(_pluginId) {
        address pluginAddress = s_pluginRegistry[_pluginId];
        delete s_pluginRegistry[_pluginId];
        delete s_pluginIds[pluginAddress];

        emit PluginRemoved(_pluginId);
    }

    /**
     * @notice Executes the required function through plugin
     * @dev (Dynamic Dispatch) This function delegates the call to the desired plugin contract
     *
     * @param _pluginId The id of the plugin to remove
     */
    function executePlugin(
        uint256 _pluginId,
        uint256 _input
    ) external validPlugin(_pluginId) returns (uint256 result) {
        address plugin = s_pluginRegistry[_pluginId];
        (bool success, bytes memory data) = address(plugin).delegatecall(
            abi.encodeCall(IPlugin.performAction, (_input))
        );
        require(success, Core_PluginExecutionFailed(_pluginId));

        result = abi.decode(data, (uint256));
        emit PluginExecuted(_pluginId, result);
        return result;
    }

    function readPluginStorage(
        bytes32 slot,
        uint256 offset
    ) external view returns (bytes32 value) {
        assembly {
            value := sload(add(slot, offset))
        }
    }
}
