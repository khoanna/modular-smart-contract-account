// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Manifest.sol";

interface IPlugin {
    function pluginManifest() external pure returns (PluginManifest memory);

    function onInstall(bytes calldata data) external;
    function onUninstall(bytes calldata data) external;
}