//
//  BeaconApplication.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

extension Beacon {
    struct Application {
        let keyPair: KeyPair
        let name: String
        let icon: String?
        let url: String?
        
        init(keyPair: KeyPair, name: String, icon: String? = nil, url: String? = nil) {
            self.keyPair = keyPair
            self.name = name
            self.icon = icon
            self.url = url
        }
    }
}
