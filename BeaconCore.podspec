Pod::Spec.new do |spec|
    spec.name                  = "BeaconCore"
    spec.version               = "3.2.4"
    spec.summary               = "Beacon is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconCore is a common base for other targets."
    spec.description           = <<-DESC
      Beacon is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. BeaconCore is a common base for other targets.
                     DESC
    spec.homepage              = "https://walletbeacon.io"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Julia Samol" => "j.samol@papers.ch" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/airgap-it/beacon-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/Core/**/*.{swift}"

    spec.dependency            "Sodium", "~> 0.9.1"
    spec.dependency            "Base58Swift", "~> 2.1.0"
end
