Pod::Spec.new do |spec|
    spec.name                  = "BeaconTransportP2PMatrix"
    spec.version               = "3.1.0"
    spec.summary               = "Beacon is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconTransportP2PMatrix provides a P2P implementation which uses Matrix network for the communication."
    spec.description           = <<-DESC
      Beacon is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconTransportP2PMatrix provides a P2P implementation which uses Matrix network for the communication."
                     DESC
    spec.homepage              = "https://walletbeacon.io"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Julia Samol" => "j.samol@papers.ch" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/airgap-it/beacon-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/TransportP2PMatrix/**/*.{swift}"

    spec.dependency            "BeaconCore", "~> #{spec.version}"
end
