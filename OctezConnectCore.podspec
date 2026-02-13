Pod::Spec.new do |spec|
    spec.name                  = "OctezConnectCore"
    spec.version               = "4.0.0"
    spec.summary               = "Octez Connect is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectCore is a common base for other targets."
    spec.description           = <<-DESC
      Octez Connect is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectCore is a common base for other targets.
                     DESC
    spec.homepage              = "https://github.com/trilitech/octez-connect-ios-sdk"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Trilitech" => "https://trilitech.xyz" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/trilitech/octez-connect-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/Core/**/*.{swift}"

    spec.dependency            "Sodium", "~> 0.9.1"
end
