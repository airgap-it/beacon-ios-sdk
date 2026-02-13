Pod::Spec.new do |spec|
    spec.name                  = "OctezConnectTransportP2PMatrix"
    spec.version               = "4.0.0"
    spec.summary               = "Octez Connect is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectTransportP2PMatrix provides a P2P implementation which uses Matrix network for the communication."
    spec.description           = <<-DESC
      Octez Connect is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet. OctezConnectTransportP2PMatrix provides a P2P implementation which uses Matrix network for the communication."
                     DESC
    spec.homepage              = "https://github.com/trilitech/octez-connect-ios-sdk"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "Trilitech" => "https://trilitech.xyz" }

    spec.ios.deployment_target = "13.0"

    spec.source                = { :git => "https://github.com/trilitech/octez-connect-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/TransportP2PMatrix/**/*.{swift}"

    spec.dependency            "OctezConnectCore", "~> #{spec.version}"
end
