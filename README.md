# Beacon iOS SDK

[![stable](https://img.shields.io/github/v/tag/airgap-it/beacon-ios-sdk?label=stable&sort=semver)](https://github.com/airgap-it/beacon-ios-sdk/releases)
[![latest](https://img.shields.io/github/v/tag/airgap-it/beacon-ios-sdk?color=orange&include_prereleases&label=latest)](https://github.com/airgap-it/beacon-ios-sdk/releases)
[![documentation](https://img.shields.io/badge/documentation-online-brightgreen.svg)](https://docs.walletbeacon.io/wallet/getting-started/ios/installation)
[![license](https://img.shields.io/github/license/airgap-it/beacon-ios-sdk)](https://github.com/airgap-it/beacon-ios-sdk/blob/master/LICENSE)

> Connect Wallets with dApps on Tezos

[Beacon](https://walletbeacon.io) is an implementation of the wallet interaction standard [tzip-10](https://gitlab.com/tzip/tzip/blob/master/proposals/tzip-10/tzip-10.md) which describes the connection of a dApp with a wallet.

## About

The `Beacon iOS SDK` provides iOS developers with tools useful for setting up communication between native wallets supporting Tezos and dApps that implement [`beacon-sdk`](https://github.com/airgap-it/beacon-sdk).

## Installation

See the below guides to learn how to add Beacon into your project.

### SPM

To add `Beacon iOS SDK` with [the Swift Package Manager](https://swift.org/package-manager/), add the `Beacon iOS SDK` package dependency:

#### Xcode

Open the `Add Package Dependency` window (as described in [the official guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)) and enter the `Beacon iOS SDK` GitHub repository URL:
```
https://github.com/airgap-it/beacon-ios-sdk
```

#### Package.swift file

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/airgap-it/beacon-ios-sdk", from: "3.1.2")
```

### CocoaPods

To add `Beacon iOS SDK` using [CocoaPods](https://cocoapods.org/), add the `Beacon iOS SDK` pod to your `Podfile`:

```ruby
target 'MyTarget' do
    use_frameworks!
    
    pod 'BeaconCore', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '3.1.2'

    // optional
    pod 'BeaconClientWallet', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '3.1.2'

    // optional
    pod 'BeaconBlockchainSubstrate', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '3.1.2'
    // optional
    pod 'BeaconBlockchainTezos', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '3.1.2'

    // optional
    pod 'BeaconTransportP2PMatrix', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '3.1.2'
end
```

## Documentation

The documentation can be found [here](https://docs.walletbeacon.io/). 

## Project Overview

The project is divided into the following packages:

### Core

Core packages are the basis for other packages. They are required for the SDK to work as expected.

| Module       | Description            | Dependencies | Required by                                                                                                                          |
| ------------ | ---------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| `BeaconCore` | Base for other modules | ✖️           | `BeaconClientWallet` <br /><br /> `BeaconBlockchainSubstrate` <br /> `BeaconBlockchainTezos` <br /><br /> `BeaconTransportP2PMatrix` |

### Client

Client packages ship with Beacon implementations for different parts of the network.

| Module               | Description                       | Dependencies | Required by |
| -------------------- | --------------------------------- | ------------ | ----------- |
| `BeaconClientWallet` | Beacon implementation for wallets | `BeaconCore` | ✖️          |

### Blockchain

Blockchain packages provide support for different blockchains.

| Module                      | Description                                            | Dependencies | Required by |
| --------------------------- | ------------------------------------------------------ | ------------ | ----------- |
| `BeaconBlockchainSubstrate` | [Substrate](https://substrate.io/) specific components | `BeaconCore` | ✖️          |
| `BeaconBlockchainTezos`     | [Tezos](https://tezos.com/) specific components        | `BeaconCore` | ✖️          |

### Transport

Transport packages provide various interfaces used to establish connection between Beacon clients.

| Module                     | Description                                                                              | Dependencies | Required by |
| -------------------------- | ---------------------------------------------------------------------------------------- | ------------ | ----------- |
| `BeaconTransportP2PMatrix` | Beacon P2P implementation which uses [Matrix](https://matrix.org/) for the communication | `BeaconCore` | ✖️          |

### Demo

Demos provide examples of how to use the library. 

| Module          | Description         |
| --------------- | ------------------- |
| `BeaconSDKDemo` | Example application |

## Examples

The snippets below show how to quickly setup listening for incoming Beacon messages.

For more examples please see our `demo` app (WIP).

### Create a Beacon client and listen for incoming messages

```swift
import BeaconCore
import BeaconBlockchainSubstrate
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

class BeaconController {
    private var client: Beacon.WalletClient?
    
    ...
    
    func startBeacon() {
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
                self.listenForBeaconMessages()
            case let .failure(error):
                /* handle error */
            }
        }
    }
    
    func listenForBeaconMessages() {
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

## Migration

See the below guides to learn how to migrate your existing code to new `Beacon iOS SDK` versions.

### From <v3.0.0

As of `v3.0.0`, `Beacon iOS SDK` has been further split into new packages and has become more generic in terms of supported blockchains and transports. This means that in some parts the values that had been previously set by default now must be configured manually or that various structures have changed their location or definition. To make sure your existing Beacon integration will be set up the same way as it used to be before `v3.0.0` do the following:

1. Replace the old `Beacon.Client` with the new `Beacon.WalletClient` (`BeaocnClientWallet`) and configure it with `Tezos` blockchain (`BeaconBlockchainTezos`) and `Transport.P2P.Matrix` transport (`BeaconTransportP2PMatrix`).

```swift
import BeaconCore
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

/* <v3.0.0: Beacon.Client.create(with: Beacon.Client.Configuration(name: "My App")) { ... } */
Beacon.WalletClient.create(
    with: Beacon.Client.Configuration(
        name: "My App",
        blockchains: [Tezos.factory],
        connections: [try Transport.P2P.Matrix.connection()]
    )
) { /* ... */ }
```

2. Adjust the message handling code.

```swift
/* <v3.0.0:
 * beaconClient.listen { result in
 *     switch result {
 *     case let .success(beaconRequest):
 *         switch beaconRequest {
 *         case let .permission(permission):
 *             ...
 *         case let .operation(operation):
 *             ...
 *         case let .signPayload(signPayload):
 *             ...
 *         case let .broadcast(broadcast):
 *             ...
 *         }
 *    ...
 *    }
 * }
 */

beaconClient.listen { (result: Result<BeaconRequest<Tezos>, Beacon.Error>) in
    switch result {
    case let .success(beaconRequest):
        switch beaconRequest {
        case let .permission(content):
            /* ... */
        case let .blockchain(blockchain):
            switch blockchain {
            case let .operation(operation):
                /* ... */
            case let .signPayload(signPayload):
                /* ... */
            case let .broadcast(broadcast):
                /* ... */
            }
        }
    }
    /* ... */
}
```

```swift
/* <v3.0.0
 * let response = Beacon.Response.Operation(from: operationRequest, transactionHash: transactionHash)
 * beaconClient.respond(with: .operation(response)) { ... }
 */

let response = OperationTezosResponse(
    from: operationRequest, //: OperationTezosRequest 
    transactionHash: transactionHash
)
beaconClient.respond(
    with: BeaconResponse<Tezos>.blockchain(
        .operation(response)
    )
) { /* ... */ }
```

```swift
/* let errorResponse = Beacon.Response.Error(from: broadcastRequest, errorType: .broadcastError)
 * beaconClient.respond(with: BeaconResponse<Tezos>.error(errorResponse)) { ... }
 */
 
let errorResponse = ErrorBeaconResponse<Tezos>(from: broadcastRequest, errorType: .blockchain(.broadcastError))
beaconClient.respond(with: BeaconResponse<Tezos>.error(errorResponse)) { /* ... */ }

```
<!-- TODO: ## Development -->

---
## Related Projects

[Beacon SDK](https://github.com/airgap-it/beacon-sdk) - an SDK for web developers (dApp & wallet)

[Beacon Android SDK](https://github.com/airgap-it/beacon-android-sdk) - an SDK for Android developers (wallet)
