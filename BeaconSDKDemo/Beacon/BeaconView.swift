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
        Text(viewModel.beaconRequest ?? "-- Request --")
    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}
