// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Manifest.sol";

interface IERC6900 {
    event PluginInstalled(address indexed plugin, bytes32 manifestHash);
    event PluginUninstalled(address indexed plugin, bytes32 manifestHash);
    
    function installPlugin(address plugin, bytes calldata data) external;
    function uninstallPlugin(address plugin) external;
    
    function execute(address target, uint256 value, bytes calldata data) external returns (bytes memory);
}