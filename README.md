# 🔌 Modular Plugin System using Delegatecall

This project demonstrates a modular and upgradeable smart contract architecture using the delegatecall pattern. The Core contract dynamically delegates logic execution to external plugin contracts that share a standard interface.

## 📆 Tech Stack

- [Solidity 0.8.28](https://docs.soliditylang.org)
- [Foundry](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

---

## 🧱 Architecture Overview

- Core.sol – Central contract that manages plugins and delegates calls

- Plugins (e.g., VaultPlugin.sol) – Independent logic units using deterministic storage slots

- IPlugin.sol – Common interface for all plugins

## 📁 Project Structure

```
├── out/                      # Compiled contract ABIs and bytecode
├── broadcast/                # Deployment logs and transactions
│
script/
├── DeployCore.sol            # Deployment script for Core
├── DeployPlugins.sol         # Deployment script for Plugins
│
src/
├── core/
│   └── Core.sol              # The main contract with plugin registry
├── interface/
│   └── IPlugin.sol           # Plugin interface
├── plugins/
│   └── ExamplePlugin.sol     # Plugin to demonstrate dynamic dispatch
│   └── VaultPlugin.sol       # Plugin to manage vaults
│
test/
├── unit/                     # Unit Tests
│   └── VaultPlugin.t.sol     # Foundry tests for VaultPlugin
│
├── foundry.toml
├── remappings.txt
└── README.md
```

> **Note:** The `out/` folder contains compiled contract ABIs and bytecode. The `broadcast/` folder contains details of recently deployed contracts including calldata and receipts. It’s automatically generated during deployment

---

## 🛠 Setup Instructions

### 📦 Prerequisites

- Foundry (install via Foundryup)
  
```bash
forge --version
```

### 1. 📅 Install Foundry

If you haven’t already:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. 🔧 Install Dependencies (Using soldeer for Dependency management)

```bash
forge soldeer install
```

---

## ⚙️ Foundry Configuration (Replace your files with these)

### 🔧 foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib", "dependencies"]

[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"

[etherscan]
sepolia = { key = "${ETHERSCAN_API_KEY}" }

[dependencies]
forge-std = "1.9.6"
"@openzeppelin-contracts" = "5.3.0"
```

### 🔗 remappings.txt

```txt
@openzeppelin-contracts/=dependencies/@openzeppelin-contracts-5.3.0/
forge-std/=dependencies/forge-std-1.9.6/src/
```

---

## ⚙️ Compilation

```bash
forge build
```

---

## 🚀 Deployment

### 🛰 Deploy in Testnet (Sepolia)

Set environment variables:

```bash
export SEPOLIA_RPC_URL=https://...
export PRIVATE_KEY=your_private_key
export ETHERSCAN_API_KEY=your_key (optional)
```
**IMPORTANT**:
Run `source .env` to load these variables into console.

Deploy with:

```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```
> **Note:** If you don't want to verify the contracts on Etherscan, remove `--verify` from the command.

---

## 🧪 Running Tests

```bash
forge test
```

Verbose output (If you want the logs to displayed):

```bash
forge test -vv
```

---

## 📘 Usage Guide

### 🔹 Register Plugin

Call `registerPlugin(pluginAddress)` in Core to register a plugin.

### 🔹 Perform Action

The `Core` contract delegates to a plugin using:

```solidity
core.performPluginAction(pluginId, abi.encode(input));
```

This performs a `delegatecall` into the plugin's `performAction` method.

## 🧼 Cleanup

To clean build artifacts:

```bash
forge clean
```

---

## 👨‍💼 Author

**Anurag Munda**

---
