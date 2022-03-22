Pod::Spec.new do |spec|
    spec.name                  = "BeaconBlockchainSubstrate"
    spec.version               = "3.1.0-beta.1"
    spec.summary               = "Beacon is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconBlockchainSubstrate provides a set of messages, utility functions and other components specific for Substrate blockchains."
    spec.description           = <<-DESC
      Beacon is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconBlockchainSubstrate provides a set of messages, utility functions and other components specific for Substrate blockchains.
                     DESC
    spec.homepage              = "https://walletbeacon.io"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Julia Samol" => "j.samol@papers.ch" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/airgap-it/beacon-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/BlockchainSubstrate/**/*.{swift}"

    spec.dependency            "BeaconCore", "~> #{spec.version}"
end
