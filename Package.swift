// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OctezConnectSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "OctezConnectCore", targets: ["OctezConnectCore"]),
        .library(name: "OctezConnectBlockchainSubstrate", targets: ["OctezConnectBlockchainSubstrate"]),
        .library(name: "OctezConnectBlockchainTezos", targets: ["OctezConnectBlockchainTezos"]),
        .library(name: "OctezConnectClientDApp", targets: ["OctezConnectClientDApp"]),
        .library(name: "OctezConnectClientWallet", targets: ["OctezConnectClientWallet"]),
        .library(name: "OctezConnectTransportP2PMatrix", targets: ["OctezConnectTransportP2PMatrix"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jedisct1/swift-sodium.git", "0.9.1"..<"1.0.0"),
        .package(url: "https://github.com/alja7dali/swift-bits.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OctezConnectCore",
            dependencies: [
                .product(name: "Sodium", package: "swift-sodium"),
                .product(name: "Clibsodium", package: "swift-sodium"),
                .product(name: "Bits", package: "swift-bits"),
            ],
            path: "Sources/Core"
        ),
        .target(name: "OctezConnectBlockchainSubstrate", dependencies: ["OctezConnectCore"], path: "Sources/BlockchainSubstrate"),
        .target(name: "OctezConnectBlockchainTezos", dependencies: ["OctezConnectCore"], path: "Sources/BlockchainTezos"),
        .target(name: "OctezConnectClientDApp", dependencies: ["OctezConnectCore"], path: "Sources/ClientDApp"),
        .target(name: "OctezConnectClientWallet", dependencies: ["OctezConnectCore"], path: "Sources/ClientWallet"),
        .target(name: "OctezConnectTransportP2PMatrix", dependencies: ["OctezConnectCore"], path: "Sources/TransportP2PMatrix"),
        
        // Tests
        .target(
            name: "Common",
            dependencies: [
                "OctezConnectCore",
                "OctezConnectBlockchainSubstrate",
                "OctezConnectBlockchainTezos",
                "OctezConnectClientDApp",
                "OctezConnectClientWallet",
                "OctezConnectTransportP2PMatrix"
            ],
            path: "Tests/Common"
        ),
        .testTarget(
            name: "OctezConnectCoreTests",
            dependencies: ["OctezConnectCore", "Common"],
            path: "Tests/BeaconCoreTests"
        ),
        .testTarget(
            name: "OctezConnectClientDAppTests",
            dependencies: ["OctezConnectClientDApp", "Common"],
            path: "Tests/BeaconClientDAppTests"
        ),
        .testTarget(
            name: "OctezConnectClientWalletTests",
            dependencies: ["OctezConnectClientWallet", "Common"],
            path: "Tests/BeaconClientWalletTests"
        ),
        .testTarget(
            name: "OctezConnectBlockchainTezosTests",
            dependencies: ["OctezConnectCore", "OctezConnectBlockchainTezos", "Common"],
            path: "Tests/BeaconBlockchainTezosTests"
        )
    ]
)
