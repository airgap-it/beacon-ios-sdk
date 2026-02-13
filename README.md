# Octez Connect iOS SDK

> Connect Wallets with dApps on Tezos

[Octez Connect](https://github.com/trilitech/octez-connect) is an implementation of the wallet interaction standard [tzip-10](https://gitlab.com/tzip/tzip/blob/master/proposals/tzip-10/tzip-10.md) which describes the connection of a dApp with a wallet.

## About

The `Octez Connect iOS SDK` provides iOS developers with tools useful for setting up communication between native wallets supporting Tezos and dApps that implement the Octez Connect protocol.

This SDK is a fork of the Beacon iOS SDK (formerly maintained by AirGap/Papers), migrated to use Trilitech-hosted Matrix infrastructure and rebranded as Octez Connect.

## Installation

### Swift Package Manager (SPM)

To add `Octez Connect iOS SDK` with [the Swift Package Manager](https://swift.org/package-manager/), add the package dependency:

#### Xcode

Open the `Add Package Dependency` window (as described in [the official guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)) and enter the `Octez Connect iOS SDK` GitHub repository URL:
```
https://github.com/trilitech/octez-connect-ios-sdk
```

#### Package.swift file

Add the following dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/trilitech/octez-connect-ios-sdk", from: "4.0.0")
]
```

Then add the products to your target dependencies:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "OctezConnectCore", package: "octez-connect-ios-sdk"),
        .product(name: "OctezConnectBlockchainTezos", package: "octez-connect-ios-sdk"),
        .product(name: "OctezConnectClientWallet", package: "octez-connect-ios-sdk"),
        .product(name: "OctezConnectTransportP2PMatrix", package: "octez-connect-ios-sdk")
    ]
)
```

### CocoaPods

To add `Octez Connect iOS SDK` using [CocoaPods](https://cocoapods.org/), add the pods to your `Podfile`:

```ruby
target 'MyTarget' do
    use_frameworks!
    
    pod 'OctezConnectCore', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    
    # optional
    pod 'OctezConnectClientDApp', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'

    # optional
    pod 'OctezConnectClientWallet', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'

    # optional
    pod 'OctezConnectBlockchainSubstrate', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    # optional
    pod 'OctezConnectBlockchainTezos', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'

    # optional
    pod 'OctezConnectTransportP2PMatrix', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
end
```

## Quickstart

The snippets below show how to quickly setup listening for incoming messages.

### Create a wallet client and listen for incoming messages

```swift
import OctezConnectCore
import OctezConnectBlockchainSubstrate
import OctezConnectBlockchainTezos
import OctezConnectClientWallet
import OctezConnectTransportP2PMatrix

class OctezConnectController {
    private var client: Beacon.WalletClient?
    
    func start() {
        Beacon.WalletClient.create(
            with: Beacon.Client.Configuration(
                name: "My App",
                blockchains: [Tezos.factory, Substrate.factory],
                connections: [try Transport.P2P.Matrix.connection()]
            )
        ) { result in
            switch result {
            case let .success(client):
                self.client = client
                self.listenForMessages()
            case let .failure(error):
                /* handle error */
            }
        }
    }
    
    func listenForMessages() {
        client?.connect { result in
            switch result {
            case .success(_):
                self.client?.listen { request in 
                    /* process messages */ 
                }
            case let .failure(error):
                /* handle error */
            }
        }
    }
}
```

## Project Overview

The project is divided into the following packages:

### Core

Core packages are the basis for other packages. They are required for the SDK to work as expected.

| Module | Description | Dependencies | Required by |
|--------|-------------|--------------|-------------|
| `OctezConnectCore` | Base for other modules | ✖️ | `OctezConnectClientWallet` <br /> `OctezConnectBlockchainSubstrate` <br /> `OctezConnectBlockchainTezos` <br /> `OctezConnectTransportP2PMatrix` |

### Client

Client packages ship with Octez Connect implementations for different parts of the network.

| Module | Description | Dependencies | Required by |
|--------|-------------|--------------|-------------|
| `OctezConnectClientDApp` | Octez Connect implementation for dApps | `OctezConnectCore` | ✖️ |
| `OctezConnectClientWallet` | Octez Connect implementation for wallets | `OctezConnectCore` | ✖️ |

### Blockchain

Blockchain packages provide support for different blockchains.

| Module | Description | Dependencies | Required by |
|--------|-------------|--------------|-------------|
| `OctezConnectBlockchainSubstrate` | [Substrate](https://substrate.io/) specific components | `OctezConnectCore` | ✖️ |
| `OctezConnectBlockchainTezos` | [Tezos](https://tezos.com/) specific components | `OctezConnectCore` | ✖️ |

### Transport

Transport packages provide various interfaces used to establish connection between Octez Connect clients.

| Module | Description | Dependencies | Required by |
|--------|-------------|--------------|-------------|
| `OctezConnectTransportP2PMatrix` | P2P implementation which uses [Matrix](https://matrix.org/) for the communication | `OctezConnectCore` | ✖️ |

## Migration from Beacon iOS SDK

If you're migrating from the Beacon iOS SDK (maintained by AirGap/Papers), see our [Migration Guide](docs/migration-ios.md) for detailed instructions.

**Quick Summary:**
- Update dependencies to use `trilitech/octez-connect-ios-sdk` repository
- Replace `import Beacon*` with `import OctezConnect*`
- The public API (`Beacon.*`, `Transport.*`, etc.) remains the same, so your existing code should work without modifications

## Examples

For more examples, see the `Demo/BeaconSDKDemo` app in this repository.

## Related Projects

- [Octez Connect Web SDK](https://github.com/trilitech/octez-connect-sdk) - SDK for web developers
- [Octez Connect Android SDK](https://github.com/trilitech/octez-connect-android-sdk) - SDK for Android developers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
