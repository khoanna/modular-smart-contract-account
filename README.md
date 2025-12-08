# Modular Smart Contract Account

A flexible and extensible smart contract account implementation that supports plugin-based architecture for modular functionality, built on the ERC-6900 standard.

## Overview

This project implements a modular account system where an owner can install and uninstall plugins to add custom functionality to their smart contract account. The architecture separates concerns between the core account logic and pluggable features, enabling easy feature composition and updates.

### Key Features

- **Plugin Architecture**: Install and uninstall plugins without upgrading the core contract
- **Function Routing**: Automatic routing of function calls to appropriate plugins via selector mapping
- **Lifecycle Hooks**: Plugins receive `onInstall` and `onUninstall` callbacks for initialization and cleanup
- **Manifest System**: Plugins declare their capabilities through structured manifests
- **Modular Design**: Clean separation between account core and plugin features
- **Owner-Controlled**: Only the account owner can manage plugin installations

## Architecture

### Core Components

#### `ModularAccount.sol`
The main smart contract account that implements ERC-6900. Manages plugin installation, function routing, and execution.

**Key Responsibilities:**
- Plugin lifecycle management (install/uninstall)
- Function selector routing to plugins
- Direct execution of owner commands
- ETH receiving capability

**Main Functions:**
- `installPlugin(address, bytes)`: Install a new plugin with optional initialization data
- `uninstallPlugin(address)`: Remove a plugin and clean up function mappings
- `execute(address, uint256, bytes)`: Direct execution by owner
- `fallback()`: Routes plugin function calls via selector lookup

#### `IPlugin.sol`
Interface that all plugins must implement.

**Required Functions:**
- `pluginManifest()`: Returns the plugin's capability manifest
- `onInstall(bytes)`: Called when plugin is installed
- `onUninstall(bytes)`: Called when plugin is uninstalled

#### `Manifest.sol`
Defines the manifest structures that plugins use to declare their capabilities.

**Structures:**
- `ManifestFunction`: Represents a function with selector and permission ID
- `PluginManifest`: Describes all execution functions, validations, and permissions

#### `CounterPlugin.sol`
Example plugin implementation that demonstrates the plugin pattern.

**Features:**
- Implements a counter for each account
- Exposes `increment()` execution function
- Provides `getCount()` view function
- Proper manifest declaration

## Usage

### Build

```shell
forge build
```

### Run Tests

```shell
forge test
```

### Format Code

```shell
forge fmt
```

### Deploy

```shell
forge script script/deploy.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Local Development with Anvil

```shell
# Start local node
anvil

# In another terminal, run tests against local node
forge test --fork-url http://localhost:8545
```

## Project Structure

```
.
├── src/
│   ├── Account.sol              # Main account contract
│   ├── Plugin.sol               # Example counter plugin
│   └── interfaces/
│       ├── IAccount.sol         # ERC-6900 interface
│       ├── IPlugin.sol          # Plugin interface
│       └── Manifest.sol         # Manifest structures
├── test/
│   └── Account.t.sol            # Test suite
├── script/
│   └── deploy.s.sol             # Deployment script
└── lib/
    └── forge-std/               # Foundry standard library
```

## How It Works

### Installing a Plugin

1. Owner calls `installPlugin(pluginAddress, initData)`
2. Account fetches the plugin's manifest
3. All function selectors are registered in `selectorToPlugin` mapping
4. Plugin's `onInstall` hook is called with initialization data
5. `PluginInstalled` event is emitted

### Executing Plugin Functions

1. Owner calls a plugin function through the account
2. `fallback()` intercepts the call and extracts the selector
3. Account looks up which plugin owns this selector
4. Call is delegated to the plugin and result is bubbled back

### Uninstalling a Plugin

1. Owner calls `uninstallPlugin(pluginAddress)`
2. Account fetches the plugin's manifest
3. All function selectors are deregistered
4. Plugin's `onUninstall` hook is called
5. `PluginUninstalled` event is emitted

## Testing

The test suite (`test/Account.t.sol`) covers:

- ✅ Installing plugins
- ✅ Authorization checks (only owner)
- ✅ Plugin uninstallation
- ✅ Function routing and execution
- ✅ Counter functionality through plugins

Run tests with:
```shell
forge test -v
```

## Security Considerations

- **Owner-Only Access**: All plugin management is restricted to the account owner
- **Selector Collision Detection**: Prevents multiple plugins from registering the same function selector
- **Proper Cleanup**: Selectors are deregistered on uninstall to prevent orphaned function pointers
- **Lifecycle Hooks**: Plugins can perform initialization and cleanup operations

## Extending with New Plugins

To create a new plugin:

1. Implement the `IPlugin` interface
2. Define your execution functions
3. Build your manifest declaring function selectors
4. Implement `onInstall()` and `onUninstall()` hooks
5. Install via `account.installPlugin(newPlugin, data)`

Example:
```solidity
contract MyPlugin is IPlugin {
    function myFunction() external {
        // Your logic here
    }
    
    function pluginManifest() external pure override returns (PluginManifest memory) {
        ManifestFunction[] memory funcs = new ManifestFunction[](1);
        funcs[0] = ManifestFunction(this.myFunction.selector, 0);
        return PluginManifest(funcs, new ManifestFunction[](0), false, false);
    }
    
    function onInstall(bytes calldata) external {}
    function onUninstall(bytes calldata) external {}
}
```

## References

- **Foundry Book**: https://book.getfoundry.sh/
- **ERC-6900**: Modular Smart Contract Accounts
- **Solidity Documentation**: https://docs.soliditylang.org/

## License

MIT
