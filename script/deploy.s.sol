// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ModularAccount} from "../src/Account.sol";
import {CounterPlugin} from "../src/Plugin.sol";

contract AccountScript is Script {
    ModularAccount public account;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        account = new ModularAccount(msg.sender);

        vm.stopBroadcast();
    }
}

contract PluginScript is Script {
    CounterPlugin public plugin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        plugin = new CounterPlugin();

        vm.stopBroadcast();
    }
}
