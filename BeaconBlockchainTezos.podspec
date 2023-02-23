Pod::Spec.new do |spec|
    spec.name                  = "BeaconBlockchainTezos"
    spec.version               = "3.2.4"
    spec.summary               = "Beacon is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconBlockchainTezos provides a set of messages, utility functions and other components specific for the Tezos blockchain."
    spec.description           = <<-DESC
      Beacon is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconBlockchainTezos provides a set of messages, utility functions and other components specific for the Tezos blockchain.
                     DESC
    spec.homepage              = "https://walletbeacon.io"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Julia Samol" => "j.samol@papers.ch" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/airgap-it/beacon-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/BlockchainTezos/**/*.{swift}"

    spec.dependency            "BeaconCore", "~> #{spec.version}"
end
