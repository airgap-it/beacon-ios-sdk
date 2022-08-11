//
//  BeaconView.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import SwiftUI

struct BeaconView: View {
    var body: some View {
        TabView {
            WalletView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Wallet")
                }
            DAppView()
                .tabItem {
                    Image(systemName: "icloud.fill")
                    Text("DApp")
                }
        }
    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}
