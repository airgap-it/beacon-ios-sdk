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
        VStack {
            Text(viewModel.beaconRequest ?? "-- Request --")
            Button("Send Response") { viewModel.sendResponse() }
            Button("Remove Example Peer") { viewModel.removePeer() }
        }
    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}
