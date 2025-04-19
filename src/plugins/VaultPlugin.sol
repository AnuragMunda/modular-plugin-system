// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IPlugin} from "../interface/IPlugin.sol";

/**
 * @title Vault Creation Plugin
 * @author Anurag Munda
 *
 * @dev This plugin allows users to create vaults by storing relevant data on-chain.
 * It implements the IPlugin interface, enabling it to be dynamically called by the Core contract.
 *
 * Functionality:
 * - Accepts input (e.g., initial deposit or config).
 * - Creates a new vault with a unique ID.
 * - Stores the vault's owner and input data in a mapping.
 * - Returns the vault ID after creation.
 *
 * This plugin demonstrates non-trivial use of contract storage and dynamic plugin logic.
 */
contract VaultPlugin is IPlugin {
    /*==============================================================
                            TYPE DECLARATIONS
    ==============================================================*/
    struct Vault {
        address owner;
        uint256 balance;
    }

    struct Layout {
        uint256 vaultCounter; // Incremental Id to track vaults
        mapping(uint256 id => Vault) vaults; // Vault Id to Vault struct mapping
    }

    /*==============================================================
                            STATE VARIABLES
    ==============================================================*/
    bytes32 public constant STORAGE_SLOT = keccak256("plugin.vault.storage"); // Storage slot to access while performing action

    event ActionPerformed(uint256 vaultId, address owner, uint256 balance);

    /*==============================================================
                                FUNCTIONS
    ==============================================================*/

    /**
     * @notice This function performs the core task of this plugin
     * @dev This is called via `delegatecall` from the `Core.sol` contract
     * to perform the intended action this plugin is meant for
     *
     * @param _input Data to perform action on
     * @return The id of the created vault
     */
    function performAction(uint256 _input) external returns (uint256) {
        Layout storage store = layout();

        uint256 vaultId = ++store.vaultCounter;
        store.vaults[vaultId] = Vault({owner: msg.sender, balance: _input});

        emit ActionPerformed(vaultId, msg.sender, _input);
        return vaultId;
    }

    /**
     * @notice This function provides the data to perform the action on
     * @dev This uses assembly lanuage assign a pointer to the Layout struct
     * present in the `STORAGE_SLOT` which can then be used to modify to storage
     *
     * @return l The Layout struct present in the `STORAGE_SLOT`
     */
    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
