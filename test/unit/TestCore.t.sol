// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/src/Test.sol";
import {Core} from "../../src/core/Core.sol";
import {VaultPlugin} from "../../src/plugins/VaultPlugin.sol";
import {ExamplePlugin} from "../../src/plugins/ExamplePlugin.sol";
import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";

contract VaultPluginTest is Test {
    Core core;
    VaultPlugin vaultPlugin;
    ExamplePlugin examplePlugin;
    address owner = makeAddr("owner"); // Genrating a random address
    address tom = makeAddr("tom");
    address alex = makeAddr("alex");
    uint256 initialBalance = 1000;

    // Events
    event PluginAdded(uint256 indexed pluginId, address pluginAddress);
    event PluginUpdated(uint256 indexed pluginId, address indexed newPluginAddress);
    event PluginRemoved(uint256 indexed pluginId);
    event PluginExecuted(uint256 indexed pluginId, uint256 returnedValue);
    event ActionPerformed(uint256 vaultId, address owner, uint256 balance);

    //** This function is called initially before every test function */
    function setUp() external {
        vm.deal(owner, 2);
        vm.deal(tom, 2);
        vm.deal(alex, 2);

        vm.prank(owner);
        core = new Core();
        vaultPlugin = new VaultPlugin();
        examplePlugin = new ExamplePlugin();
    }

    //** Test if owner is the one who deployed the Core */
    function test_OwnerIsSetCorrectly() external view {
        assertEq(core.owner(), owner);
        console.log(unicode"Owner is correclty set.✅");
    }

    //** Test if owner is able to add plugin */
    function test_OwnerCanAddPlugin() external {
        vm.prank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        address vaultPluginAddress = core.s_pluginRegistry(id);
        assertEq(vaultPluginAddress, address(vaultPlugin));

        uint256 newId = core.s_pluginIds(address(vaultPlugin));
        assertEq(newId, id);
        console.log(unicode"Owner can Add plugin.✅");
    }

    //** Test if the counter increase after adding a plugin */
    function test_AddingPluginIncreasesCounter() external {
        uint256 initialCounter = core.s_counter();
        assertEq(initialCounter, 0);

        vm.prank(owner);
        core.addPlugin(address(vaultPlugin));
        assertEq(core.s_counter(), initialCounter + 1);

        vm.prank(owner);
        core.addPlugin(address(examplePlugin));
        assertEq(core.s_counter(), initialCounter + 2);
        console.log(unicode"Counter is increasing after adding plugin.✅");
    }

    //** Test access control for adding plugin (only owner is allowed to add) */
    function test_OnlyOwnerCanAddPlugin() external {
        vm.prank(tom);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, tom));
        core.addPlugin(address(vaultPlugin));
        console.log(unicode"Access control working for addPlugin.✅");
    }

    //** Test if the validations are working correctly before adding plugin */
    function test_AddPluginValidations() external {
        vm.startPrank(owner);
        vm.expectRevert(Core.Core_CannotBeZeroAdress.selector);
        core.addPlugin(address(0));

        core.addPlugin(address(vaultPlugin));

        vm.expectRevert(Core.Core_PluginExists.selector);
        core.addPlugin(address(vaultPlugin));
        vm.stopPrank();
        console.log(unicode"Validations are working for addPlugin.✅");
    }

    //** Test if after adding plugin an event is emitted */
    function test_AddingPluginEmitsEvent() external {
        vm.expectEmit(true, true, false, false);
        emit PluginAdded(core.s_counter() + 1, address(vaultPlugin));
        vm.prank(owner);
        core.addPlugin(address(vaultPlugin));
        console.log(unicode"Adding plugin emits event.✅");
    }

    //** Test if owner can update the address of an existing plugin */
    function test_OwnerCanUpdatePlugin() external {
        vm.startPrank(owner);
        uint256 vaultPluginId = core.addPlugin(address(vaultPlugin));

        address pluginAddress = core.s_pluginRegistry(vaultPluginId);
        assertEq(pluginAddress, address(vaultPlugin));

        core.updatePlugin(vaultPluginId, address(examplePlugin));
        pluginAddress = core.s_pluginRegistry(vaultPluginId);
        assertEq(pluginAddress, address(examplePlugin));

        uint256 examplePluginId = core.s_pluginIds(address(examplePlugin));
        assertEq(vaultPluginId, examplePluginId);

        vaultPluginId = core.s_pluginIds(address(vaultPlugin));
        assertEq(vaultPluginId, 0);

        vm.stopPrank();
        console.log(unicode"Owner can Update plugin.✅");
    }

    //** Test access control to update a plugin (Only owner can update) */
    function test_onlyOwnerCanUpdatePlugin() external {
        vm.prank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        vm.prank(tom);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, tom));
        core.updatePlugin(id, address(examplePlugin));
        console.log(unicode"Access control working for updatePlugin.✅");
    }

    //** Test if an event is emitted after updating a plugin */
    function test_UpdatingPluginEmitsEvent() external {
        vm.prank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        vm.expectEmit(true, true, false, false);
        emit PluginUpdated(id, address(examplePlugin));
        vm.prank(owner);
        core.updatePlugin(id, address(examplePlugin));
        console.log(unicode"Updating a plugin emits event.✅");
    }

    //** Test if the validations are working correctly before updating plugin */
    function test_ValidationsForUpdatePlugin() external {
        vm.startPrank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        vm.expectRevert(Core.Core_CannotBeZeroAdress.selector);
        core.updatePlugin(id, address(0));

        vm.expectRevert(Core.Core_PluginExists.selector);
        core.updatePlugin(id, address(vaultPlugin));

        vm.expectRevert(Core.Core_InvalidId.selector);
        core.updatePlugin(9, address(examplePlugin));
        vm.stopPrank();
        console.log(unicode"Validations are working correctly for updatePlugin.✅");
    }

    //** Test if owner can remove an existing plugin */
    function test_OwnerCanRemovePlugin() external {
        vm.startPrank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        core.removePlugin(id);

        address verifiableAddress = core.s_pluginRegistry(id);
        assertEq(verifiableAddress, address(0));

        uint256 verifiableId = core.s_pluginIds(address(vaultPlugin));
        assertEq(verifiableId, 0);

        vm.stopPrank();
        console.log(unicode"Owner is able to remove a plugin.✅");
    }

    //** Test the access control for removing plugin (Only owner can remove) */
    function test_OnlyOwnerCanRemovePlugin() external {
        vm.prank(owner);
        uint256 id = core.addPlugin(address(examplePlugin));

        vm.prank(alex);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alex));
        core.removePlugin(id);
        console.log(unicode"Access control working for removePlugin.✅");
    }

    //** Test if the validations are working correctly before removing plugin */
    function test_ValidationsForRemovingPlugin() external {
        vm.startPrank(owner);
        uint256 id = core.addPlugin(address(examplePlugin));
        core.removePlugin(id);

        vm.expectRevert(Core.Core_InvalidPlugin.selector);
        core.removePlugin(id);

        vm.stopPrank();
        console.log(unicode"Validations are working for removePlugin.✅");
    }

    //** Test if an event is emitted after removing a plugin */
    function test_RemovingPluginEmitsEvent() external {
        vm.prank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));

        vm.expectEmit(true, false, false, false);
        emit PluginRemoved(id);
        vm.prank(owner);
        core.removePlugin(id);
        console.log(unicode"Removing plugin emits an event.✅");
    }

    //** Test if the Vault plugin is getting executed correctly via Core */
    function test_executeVaultPlugin() external {
        uint256 input = 150;

        vm.startPrank(owner);
        uint256 id = core.addPlugin(address(vaultPlugin));
        core.addPlugin(address(examplePlugin));
        vm.stopPrank();

        vm.prank(alex);
        vm.expectEmit(true, true, true, false);
        emit ActionPerformed(1, owner, input); // This check if the data is correctly set in the vault by checking the emitted event
        vm.expectEmit(true, true, false, false);
        emit PluginExecuted(id, 1);
        uint256 firstVaultId = core.executePlugin(id, input);
        assertEq(firstVaultId, 1);
        console.log("First vault Id: ", firstVaultId);

        vm.prank(tom);
        vm.expectEmit(true, true, true, false);
        emit ActionPerformed(2, owner, input); // This check if the data is correctly set in the vault by checking the emitted event
        vm.expectEmit(true, true, false, false);
        emit PluginExecuted(id, 2);
        uint256 secondVaultId = core.executePlugin(id, input);
        assertEq(secondVaultId, 2);
        console.log("Second vault Id: ", secondVaultId);

        // Checking if vault creation returns unique vault IDs
        assertTrue(firstVaultId != secondVaultId);

        console.log(unicode"Dynamic dispatch working for vault plugin.✅");
        console.log(unicode"The vault plugin correctly creates vaults and returns unique vault IDs.✅");
    }

    //** Test if the Example plugin is getting executed correctly via Core */
    function test_executeExamplePlugin() external {
        uint256 input = 50;
        uint256 factor = examplePlugin.CONSTANT_FACTOR();

        vm.startPrank(owner);
        core.addPlugin(address(vaultPlugin));
        uint256 id = core.addPlugin(address(examplePlugin));
        vm.stopPrank();

        vm.prank(alex);
        vm.expectEmit(true, true, false, false);
        emit PluginExecuted(id, input * factor);
        uint256 product = core.executePlugin(id, input);
        assertEq(product, input * factor);
        console.log(unicode"Dynamic dispatch working for exapmle plugin.✅");
        console.log("Returned value/product: ", product);
    }

    //** Test if the validations are working correctly before executing */
    function test_ValidationForExecutinPlugin() external {
        uint256 input = 150;
        uint256 invalidId = 1;

        vm.prank(alex);
        vm.expectRevert(Core.Core_InvalidPlugin.selector);
        core.executePlugin(invalidId, input);
        console.log(unicode"Validations are working for executePlugin.✅");
    }
}
