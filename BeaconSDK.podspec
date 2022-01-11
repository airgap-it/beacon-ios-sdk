Pod::Spec.new do |spec|
  spec.name         = "BeaconSDK"
  spec.version      = "3.0.1-beta.0"
  spec.summary      = "Beacon is an implementation of the wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet."
  spec.description  = <<-DESC
    Beacon is an implementation of the Tezos wallet interaction standard tzip-10 which describes the connection of a dApp with a wallet.
                   DESC
  spec.homepage     = "https://walletbeacon.io"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Julia Samol" => "j.samol@papers.ch" }
  spec.ios.deployment_target = '13.0'
  spec.source       = { :git => "https://github.com/airgap-it/beacon-ios-sdk.git", :tag => "#{spec.version}" }
  
  spec.subspec 'BeaconCore' do |subspec|
    subspec.dependency  'Sodium', '~> 0.9.1'
    subspec.dependency  'Base58Swift', '~> 2.1.0'
    subspec.source_files = 'Sources/Core/**/*.{swift}'
  end

  spec.subspec 'BeaconBlockchainTezos' do |subspec|
    subspec.dependency 'BeaconSDK/BeaconCore'
    subspec.source_files = 'Sources/BlockchainTezos/**/*.{swift}'
  end
  
  spec.subspec 'BeaconClientWallet' do |subspec|
    subspec.dependency 'BeaconSDK/BeaconCore'
    subspec.source_files = 'Sources/ClientWallet/**/*.{swift}'
  end

  spec.subspec 'BeaconTransportP2PMatrix' do |subspec|
    subspec.dependency 'BeaconSDK/BeaconCore'
    subspec.source_files = 'Sources/TransportP2PMatrix/**/*.{swift}'
  end
end
