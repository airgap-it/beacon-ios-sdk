//
//  BeaconApplication.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

extension Beacon {
    public struct Application {
        public let keyPair: KeyPair
        public let name: String
        public let icon: String?
        public let url: String?
        
        init(keyPair: KeyPair, name: String, icon: String? = nil, url: String? = nil) {
            self.keyPair = keyPair
            self.name = name
            self.icon = icon
            self.url = url
        }
    }
}
