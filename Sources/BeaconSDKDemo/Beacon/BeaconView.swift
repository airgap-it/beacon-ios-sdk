//
//  BeaconView.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import SwiftUI

struct BeaconView: View {
    private static let examplePeerName = "Beacon Example Dapp"
    private static let examplePeerPublicKey = "6ea44166eb624b875ecb24100b426afba89fdd95eee7d95d8c8d8d6da38fe7fa"
    private static let examplePeerRelayServer = "matrix.papers.tech"
    
    @ObservedObject var viewModel = BeaconViewModel()
    
    @State var name: String = BeaconView.examplePeerName
    @State var publicKey: String = BeaconView.examplePeerPublicKey
    @State var relayServer: String = BeaconView.examplePeerRelayServer
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Text("Name:").bold()
                TextField("dApp", text: $name)
            }
            
            HStack {
                Text("Public Key:").bold()
                TextField("0x", text: $publicKey)
            }
            
            HStack {
                Text("Relay Server:").bold()
                TextField("https://", text: $relayServer)
            }
            
            HStack {
                Button("Remove Peer") { viewModel.removePeer(name: name, publicKey: publicKey, relayServer: relayServer) }
                Button("Add Peer") { viewModel.addPeer(name: name, publicKey: publicKey, relayServer: relayServer) }
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
            Button("Respond") { viewModel.sendResponse() }
            
            ScrollView(.vertical) {
                Text(viewModel.beaconRequest ?? "-- Request --")
            }.frame(maxWidth: .infinity)
            
        }.padding()
    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}
