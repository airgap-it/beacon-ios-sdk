Pod::Spec.new do |spec|
    spec.name                  = "OctezConnectBlockchainTezos"
    spec.version               = "4.0.0"
    spec.summary               = "Octez Connect is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectBlockchainTezos provides a set of messages, utility functions and other components specific for the Tezos blockchain."
    spec.description           = <<-DESC
      Octez Connect is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectBlockchainTezos provides a set of messages, utility functions and other components specific for the Tezos blockchain.
                     DESC
    spec.homepage              = "https://github.com/trilitech/octez-connect-ios-sdk"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Trilitech" => "https://trilitech.xyz" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/trilitech/octez-connect-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/BlockchainTezos/**/*.{swift}"

    spec.dependency            "OctezConnectCore", "~> #{spec.version}"
end
