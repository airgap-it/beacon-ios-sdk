// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BeaconSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "BeaconCore", targets: ["BeaconCore"]),
        .library(name: "BeaconBlockchainTezos", targets: ["BeaconBlockchainTezos"]),
        .library(name: "BeaconClientWallet", targets: ["BeaconClientWallet"]),
        .library(name: "BeaconTransportP2PMatrix", targets: ["BeaconTransportP2PMatrix"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/keefertaylor/Base58Swift.git", "2.1.14"..<"3.0.0"),
        .package(name: "Sodium", url: "https://github.com/jedisct1/swift-sodium.git", "0.9.1"..<"1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BeaconCore",
            dependencies: [
                "Sodium",
                 .product(name: "Clibsodium", package: "Sodium"),
                "Base58Swift"
            ]
        ),
        .target(name: "BeaconBlockchainTezos", dependencies: ["BeaconCore"]),
        .target(name: "BeaconClientWallet", dependencies: ["BeaconCore"]),
        .target(name: "BeaconTransportP2PMatrix", dependencies: ["BeaconCore"]),
        
        // Tests
        .target(
            name: "Common",
            dependencies: [
                "BeaconCore",
                "BeaconBlockchainTezos",
                "BeaconClientWallet",
                "BeaconTransportP2PMatrix"
            ],
            path: "Tests/Common"
        ),
        .testTarget(
            name: "BeaconCoreTests",
            dependencies: ["BeaconCore", "Common"]
        ),
        .testTarget(
            name: "BeaconClientWalletTests",
            dependencies: ["BeaconClientWallet", "Common"]
        ),
    ]
)
