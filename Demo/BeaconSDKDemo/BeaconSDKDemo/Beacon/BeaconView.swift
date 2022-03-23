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
    @ObservedObject var viewModel = BeaconViewModel()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Text("ID:").bold()
                TextField("ID", text: $viewModel.id)
            }
            
            HStack {
                Text("Name:").bold()
                TextField("dApp", text: $viewModel.name)
            }
            
            HStack {
                Text("Public Key:").bold()
                TextField("0x", text: $viewModel.publicKey)
            }
            
            HStack {
                Text("Relay Server:").bold()
                TextField("https://", text: $viewModel.relayServer)
            }
            
            HStack {
                Text("Version:").bold()
                TextField("version", text: $viewModel.version)
            }
            
            HStack {
                Button("Remove Peer") { viewModel.removePeer() }
                Button("Add Peer") { viewModel.addPeer() }
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
            Button("Respond") { viewModel.sendResponse() }
            
            HStack {
                Button("Start") { viewModel.startBeacon() }
                Button("Stop") { viewModel.stop() }
                Button("Pause") { viewModel.pause() }
                Button("Resume") { viewModel.resume() }
            }
            
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
