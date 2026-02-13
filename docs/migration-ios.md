# Migration Guide: Beacon iOS SDK → Octez Connect iOS SDK

## Overview

This guide helps you migrate from the **Beacon iOS SDK** (maintained by AirGap/Papers) to the **Octez Connect iOS SDK** (maintained by Trilitech). The migration is necessary because the Beacon Matrix nodes hosted by Papers have been shut down. Octez Connect uses Trilitech-hosted Matrix nodes (`*.octez.io`) and maintains the same core API surface, making migration straightforward.

## Why Migrate?

- **Infrastructure Change**: Beacon Matrix nodes (`*.papers.tech`) have been shut down. Octez Connect uses new Trilitech-hosted nodes (`*.octez.io`).
- **Same Functionality**: The API surface remains largely the same, minimizing code changes.
- **Active Maintenance**: Octez Connect is actively maintained by Trilitech.

## Dependency Changes

### CocoaPods

**Before (Beacon iOS SDK):**
```ruby
target 'MyTarget' do
    use_frameworks!
    
    pod 'BeaconCore', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
    pod 'BeaconClientDApp', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
    pod 'BeaconClientWallet', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
    pod 'BeaconBlockchainTezos', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
    pod 'BeaconBlockchainSubstrate', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
    pod 'BeaconTransportP2PMatrix', :git => 'https://github.com/airgap-it/beacon-ios-sdk', :tag => '4.0.0'
end
```

**After (Octez Connect iOS SDK):**
```ruby
target 'MyTarget' do
    use_frameworks!
    
    pod 'OctezConnectCore', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    pod 'OctezConnectClientDApp', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    pod 'OctezConnectClientWallet', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    pod 'OctezConnectBlockchainTezos', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    pod 'OctezConnectBlockchainSubstrate', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
    pod 'OctezConnectTransportP2PMatrix', :git => 'https://github.com/trilitech/octez-connect-ios-sdk', :tag => '4.0.0'
end
```

### Swift Package Manager (SPM)

**Before (Beacon iOS SDK):**
```swift
dependencies: [
    .package(url: "https://github.com/airgap-it/beacon-ios-sdk", from: "4.0.0")
]
```

**After (Octez Connect iOS SDK):**
```swift
dependencies: [
    .package(url: "https://github.com/trilitech/octez-connect-ios-sdk", from: "4.0.0")
]
```

## Package & Import Mapping

Update your import statements to use the new module names:

| Old Import | New Import |
|------------|------------|
| `import BeaconCore` | `import OctezConnectCore` |
| `import BeaconClientDApp` | `import OctezConnectClientDApp` |
| `import BeaconClientWallet` | `import OctezConnectClientWallet` |
| `import BeaconBlockchainTezos` | `import OctezConnectBlockchainTezos` |
| `import BeaconBlockchainSubstrate` | `import OctezConnectBlockchainSubstrate` |
| `import BeaconTransportP2PMatrix` | `import OctezConnectTransportP2PMatrix` |

### Example

**Before:**
```swift
import BeaconCore
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix
```

**After:**
```swift
import OctezConnectCore
import OctezConnectBlockchainTezos
import OctezConnectClientWallet
import OctezConnectTransportP2PMatrix
```

## API Surface

The public API surface remains **largely unchanged**. The `Beacon` namespace and all public APIs (e.g., `Beacon.WalletClient`, `Beacon.Client.Configuration`, `Transport.P2P.Matrix`) continue to work as before. Your existing code using these APIs should continue to work without changes.

### Example (No Code Changes Required)

```swift
import OctezConnectCore
import OctezConnectBlockchainTezos
import OctezConnectClientWallet
import OctezConnectTransportP2PMatrix

// This code works exactly the same as before
Beacon.WalletClient.create(
    with: Beacon.Client.Configuration(
        name: "My App",
        blockchains: [Tezos.factory],
        connections: [try Transport.P2P.Matrix.connection()]
    )
) { result in
    // Handle result
}
```

## Behavior Changes

### Matrix Nodes

The Matrix relay servers have changed from Papers-hosted nodes to Trilitech-hosted nodes:

- **Old nodes**: `*.papers.tech` (e.g., `beacon-node-1.diamond.papers.tech`)
- **New nodes**: `*.octez.io` (e.g., `beacon-node-1.octez.io` through `beacon-node-8.octez.io`)

This change is transparent to your application code. The SDK automatically uses the new nodes.

## Migration Steps

1. **Update Dependencies**
   - Update your `Podfile` or `Package.swift` to use the new repository and pod/package names (see above).

2. **Update Import Statements**
   - Replace all `import Beacon*` statements with `import OctezConnect*` (see mapping table above).

3. **Run `pod install` (CocoaPods) or Update Package (SPM)**
   - For CocoaPods: Run `pod install` in your project directory.
   - For SPM: Xcode will automatically update packages, or use `swift package update`.

4. **Build and Test**
   - Build your project to ensure all imports resolve correctly.
   - Test your Beacon/Octez Connect integration to verify connectivity.

5. **No Code Changes Required**
   - The public API (`Beacon.*`, `Transport.*`, etc.) remains the same, so your existing code should work without modifications.

## Troubleshooting

### Import Errors

If you see import errors after migration:
- Ensure all `import Beacon*` statements have been updated to `import OctezConnect*`.
- Clean your build folder (Product → Clean Build Folder in Xcode).
- For CocoaPods: Delete `Pods/` and `Podfile.lock`, then run `pod install` again.

### Connection Issues

If you experience connection issues:
- Verify you're using the latest version of Octez Connect iOS SDK.
- Check that your app has network permissions configured.
- Ensure you're not blocking connections to `*.octez.io` domains.

## Support

For issues or questions about the migration:
- **Repository**: [trilitech/octez-connect-ios-sdk](https://github.com/trilitech/octez-connect-ios-sdk)
- **Issues**: Open an issue on the GitHub repository

## Related Resources

- [Octez Connect Web SDK](https://github.com/trilitech/octez-connect-sdk)
- [Octez Connect Android SDK](https://github.com/trilitech/octez-connect-android-sdk)
