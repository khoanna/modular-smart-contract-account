// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {ModularAccount} from "../src/Account.sol";
import {CounterPlugin} from "../src/Plugin.sol";

contract BaseSetup is Test {
    Vm internal constant VM = Vm(VM_ADDRESS);

    ModularAccount internal account;
    CounterPlugin internal plugin;

    uint256 internal _aliceKey=1;
    address internal _aliceAddress = VM.addr(_aliceKey);

    uint256 internal _bobKey=2;
    address internal _bobAddress = VM.addr(_bobKey);

    function setUp() public {
        account = new ModularAccount(_aliceAddress);
        plugin = new CounterPlugin();
    }
}

contract AccountTest is BaseSetup {
    function testInstallPlugin() public {
        VM.prank(_aliceAddress);
        account.installPlugin(address(plugin), "");

        assert(account.installedPlugins(address(plugin)) == true);

        bytes4 selector = bytes4(keccak256("increment()"));
        assert(account.selectorToPlugin(selector) == address(plugin));
    }

    function testInstallPluginByNonOwner() public {
        VM.prank(_bobAddress);

        VM.expectRevert(bytes("Auth: Only owner"));
        account.installPlugin(address(plugin), "");
    }

    function testUninstallPlugin() public {
        VM.prank(_aliceAddress);
        account.installPlugin(address(plugin), "");

        VM.prank(_aliceAddress);
        account.uninstallPlugin(address(plugin));

        assert(account.installedPlugins(address(plugin)) == false);

        bytes4 selector = bytes4(keccak256("increment()"));
        assert(account.selectorToPlugin(selector) == address(0));
    }

    function testModularExecution() public {
        VM.prank(_aliceAddress);
        account.installPlugin(address(plugin), "");

        VM.prank(_aliceAddress);
        (bool success, ) = address(account).call(abi.encodeWithSignature("increment()"));
        assert(success);

        uint256 count = plugin.getCount(address(account));
        assertEq(count, 1);
    }
}

