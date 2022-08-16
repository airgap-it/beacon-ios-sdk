//
//  SodiumCryptoProvider.swift
//
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Clibsodium

class SodiumCryptoProvider: CryptoProvider {
    
    // MARK: Random
    
    func randomBytes(length: Int) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: length)
        randombytes_buf(&result, length)
        
        return result
    }
    
    // MARK: Hash
    
    func hash(message: [UInt8], size: Int) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: size)
        let status = crypto_generichash(&result, size, message, UInt64(message.count), nil, 0)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    // MARK: Keys
    
    func ed25519KeyPair(from seed: [UInt8]) throws -> KeyPair {
        var pk = [UInt8](repeating: 0, count: crypto_sign_publickeybytes())
        var sk = [UInt8](repeating: 0, count: crypto_sign_secretkeybytes())
        
        let status = crypto_sign_seed_keypair(&pk, &sk, seed)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return KeyPair(secretKey: sk, publicKey: pk)
    }
    
    func convertToCurve25519(ed25519SecretKey key: [UInt8]) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: crypto_scalarmult_curve25519_bytes())
        let status = crypto_sign_ed25519_sk_to_curve25519(&result, key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    func convertToCurve25519(ed25519PublicKey key: [UInt8]) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: crypto_scalarmult_curve25519_bytes())
        let status = crypto_sign_ed25519_pk_to_curve25519(&result, key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    func serverSessionKeyPair(serverPublicKey: [UInt8], serverSecretKey: [UInt8], clientPublicKey: [UInt8]) throws -> SessionKeyPair {
        var rx = [UInt8](repeating: 0, count: crypto_kx_sessionkeybytes())
        var tx = [UInt8](repeating: 0, count: crypto_kx_sessionkeybytes())
        
        let status = crypto_kx_server_session_keys(&rx, &tx, serverPublicKey, serverSecretKey, clientPublicKey)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return SessionKeyPair(rx: rx, tx: tx)
    }
    
    func clientSessionKeyPair(serverPublicKey: [UInt8], serverSecretKey: [UInt8], clientPublicKey: [UInt8]) throws -> SessionKeyPair {
        var rx = [UInt8](repeating: 0, count: crypto_kx_sessionkeybytes())
        var tx = [UInt8](repeating: 0, count: crypto_kx_sessionkeybytes())
        
        let status = crypto_kx_client_session_keys(&rx, &tx, serverPublicKey, serverSecretKey, clientPublicKey)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return SessionKeyPair(rx: rx, tx: tx)
    }
    
    // MARK: Signature
    
    func signDetached(message: [UInt8], with key: [UInt8]) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: crypto_sign_bytes())
        let status = crypto_sign_detached(&result, nil, message, UInt64(message.count), key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    // MARK: Encryption
    
    func validate(encrypted: String) -> Bool {
        do {
            return try HexString(from: encrypted).count() >= crypto_box_noncebytes() + crypto_box_macbytes()
        } catch {
            return false
        }
    }
    
    func encrypt(message: [UInt8], withPublicKey key: [UInt8]) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: message.count + crypto_box_sealbytes())
        let status = crypto_box_seal(&result, message, UInt64(message.count), key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    func decrypt(message: [UInt8], withPublicKey publicKey: [UInt8], andSecretKey secretKey: [UInt8]) throws -> [UInt8] {
        var result = [UInt8](repeating: 0, count: message.count - crypto_box_sealbytes())
        let status = crypto_box_seal_open(&result, message, UInt64(message.count), publicKey, secretKey)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result
    }
    
    func encrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8] {
        let nonce = try randomBytes(length: crypto_box_noncebytes())
        var result = [UInt8](repeating: 0, count: message.count + crypto_box_macbytes())
        let status = crypto_secretbox_easy(&result, message, UInt64(message.count), nonce, key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return nonce + result
    }
    
    func decrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8] {
        let nonce = message[0..<crypto_box_noncebytes()]
        let cypher = message[crypto_box_noncebytes()...]
        var result = [UInt8](repeating: 0, count: message.count - crypto_box_macbytes())
        let status = crypto_secretbox_open_easy(&result, [UInt8](cypher), UInt64(cypher.count), [UInt8](nonce), key)
        guard status == 0 else {
            throw Error.sodium(Int(status))
        }
        
        return result.reversed().drop(while: { $0 == 0 }).reversed()
    }
    
    enum Error: Swift.Error {
        case sodium(Int)
    }
}
