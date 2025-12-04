// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPlugin, PluginManifest, ManifestFunction} from "./interfaces/IPlugin.sol";

contract CounterPlugin is IPlugin {
    // STORAGE: Maps Account Address -> Count
    mapping(address => uint256) public counts;

    // --- EXECUTION FUNCTION ---
    function increment() external {
        counts[msg.sender] += 1;
    }

    // --- VIEW FUNCTION ---
    function getCount(address account) external view returns (uint256) {
        return counts[account];
    }

    // --- THE MANIFEST ---
    function pluginManifest() external pure override returns (PluginManifest memory) {
        PluginManifest memory manifest;
        
        // Define execution functions
        manifest.executionFunctions = new ManifestFunction[](1);
        manifest.executionFunctions[0] = ManifestFunction({
            selector: this.increment.selector,
            permissionId: 0 
        });
        
        // Defaults for other fields
        manifest.permitAnyExternalAddress = false;
        manifest.canSpendNativeToken = false;

        return manifest;
    }

    function onInstall(bytes calldata) external {}
    
    function onUninstall(bytes calldata) external {}
}