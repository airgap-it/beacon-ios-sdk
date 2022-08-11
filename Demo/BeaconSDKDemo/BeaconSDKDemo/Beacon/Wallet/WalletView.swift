//
//  WalletView.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel = WalletViewModel()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Pairing Request:").bold()
                TextEditor(text: $viewModel.pairingRequest)
                    .frame(maxHeight: 100)
                    
            }
            
            HStack {
                Button("Unpair") { viewModel.unpair() }
                Button("Pair") { viewModel.pair() }
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

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
