//
//  BeaconView.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import SwiftUI

struct BeaconView: View {
    @State private var selected: Tab = .wallet
    
    var body: some View {
        TabView(selection: $selected) {
            WalletView()
                .onTapGesture {
                    selected = .wallet
                }
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Wallet")
                }
                .tabTag(.wallet)
            DAppView()
                .onTapGesture {
                    selected = .dapp
                }
                .tabItem {
                    Image(systemName: "icloud.fill")
                    Text("DApp")
                }
                .tabTag(.dapp)
        }
    }
    
    enum Tab: String {
        case wallet
        case dapp
    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}

extension View {
    func tabTag(_ tag: BeaconView.Tab) -> some View {
        self.tag(tag)
    }
}
