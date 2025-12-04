// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct ManifestFunction {
    bytes4 selector;      // The function signature (e.g. transfer(address,uint256))
    uint8 permissionId;   // 0 = Public, 1 = Owner Only, etc. 
}

struct PluginManifest {
    // List of execution functions this plugin adds to the account
    ManifestFunction[] executionFunctions;
    
    // List of validation functions 
    ManifestFunction[] validationFunctions;

    // Does this plugin need permission to call external contracts?
    bool permitAnyExternalAddress;
    
    // Can this plugin spend the Account's ETH?
    bool canSpendNativeToken;
}