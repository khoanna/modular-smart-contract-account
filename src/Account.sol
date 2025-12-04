// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC6900, PluginManifest} from "./interfaces/IAccount.sol";
import {IPlugin} from "./interfaces/IPlugin.sol";

// We inherit the interface to ensure compliance
contract ModularAccount is IERC6900 {
    address public owner;

    // --- STORAGE ---
    // Maps Function Selector -> Plugin Address
    mapping(bytes4 => address) public selectorToPlugin;
    
    // Maps Plugin Address -> Boolean (Is installed)
    mapping(address => bool) public installedPlugins;

    constructor(address _owner) {
        owner = _owner;
    }

    // --- MODIFIERS ---
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
    
    function _onlyOwner() internal view {
        require(msg.sender == owner, "Auth: Only owner");
    }

    // --- INSTALLATION LOGIC ---
    function installPlugin(address pluginAddr, bytes calldata data) external override onlyOwner {
        require(!installedPlugins[pluginAddr], "Plugin already installed");
        
        // A. Fetch the Manifest
        IPlugin plugin = IPlugin(pluginAddr);
        PluginManifest memory manifest = plugin.pluginManifest();

        // B. Update Router Mappings
        for (uint i = 0; i < manifest.executionFunctions.length; i++) {
            bytes4 sel = manifest.executionFunctions[i].selector;
            require(selectorToPlugin[sel] == address(0), "Selector collision");
            selectorToPlugin[sel] = pluginAddr;
        }

        // C. Mark installed and trigger lifecycle hook
        installedPlugins[pluginAddr] = true;
        try plugin.onInstall(data) {} catch {}

        emit PluginInstalled(pluginAddr, keccak256(abi.encode(manifest)));
    }

    function uninstallPlugin(address pluginAddr) external override onlyOwner {
        require(installedPlugins[pluginAddr], "Plugin not installed");

        // A. Fetch the Manifest
        IPlugin plugin = IPlugin(pluginAddr);
        PluginManifest memory manifest = plugin.pluginManifest();

        // B. Update Router Mappings
        for (uint i = 0; i < manifest.executionFunctions.length; i++) {
            bytes4 sel = manifest.executionFunctions[i].selector;
            require(selectorToPlugin[sel] == pluginAddr, "Selector mismatch");
            selectorToPlugin[sel] = address(0);
        }

        // C. Mark uninstalled and trigger lifecycle hook
        installedPlugins[pluginAddr] = false;
        try plugin.onUninstall("") {} catch {}

        emit PluginUninstalled(pluginAddr, keccak256(abi.encode(manifest)));
    }

    // --- 2. EXECUTION ROUTING ---
    
    // A. Standard Execute (Direct calls from Owner)
    function execute(address target, uint256 value, bytes calldata data) 
        external 
        override 
        onlyOwner 
        returns (bytes memory) 
    {
        (bool success, bytes memory result) = target.call{value: value}(data);
        require(success, "Execute failed");
        return result;
    }

    // B. Fallback Router (Plugin Interactions)
    fallback() external payable {
        // 1. Find the plugin responsible for this selector
        address plugin = selectorToPlugin[msg.sig];
        require(plugin != address(0), "Function not found");

        // 2. Call the plugin (Standard Execution)
        (bool success, bytes memory result) = plugin.call(msg.data);

        // 3. Bubble up the result
        assembly {
            if iszero(success) {
                revert(add(result, 32), mload(result))
            }
            return(add(result, 32), mload(result))
        }
    }
    
    receive() external payable {}
}