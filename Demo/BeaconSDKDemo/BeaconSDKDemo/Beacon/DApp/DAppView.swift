//
//  DAppView.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 11.08.22.
//

import SwiftUI

struct DAppView: View {
    @ObservedObject var viewModel = DAppViewModel()
    
    @ViewBuilder
    var body: some View {
        if !viewModel.started {
            VStack(alignment: .center) {
                Button("Start DApp") { viewModel.start() }
            }
        } else {
            VStack(alignment: .trailing, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pairing Request:").bold()
                    Text(viewModel.pairingRequest ?? "-- Pairing Request --")
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Button("Unpair") { viewModel.unpair() }
                    Button("Pair") { viewModel.pair() }
                }.frame(alignment: .trailing)
                
                Button("Request Permission") { viewModel.requestPermission() }
                
                HStack {
                    Button("Start") { viewModel.start() }
                    Button("Stop") { viewModel.stop() }
                    Button("Pause") { viewModel.pause() }
                    Button("Resume") { viewModel.resume() }
                }
                
                Button("Clear Response") { viewModel.clearResponse() }
                
                ScrollView(.vertical) {
                    Text(viewModel.beaconResponse ?? "-- Response --")
                }.frame(maxWidth: .infinity)
                
            }.padding()
        }
    }
}

struct DAppView_Previews: PreviewProvider {
    static var previews: some View {
        DAppView()
    }
}
