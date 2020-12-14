//
//  Keychain.swift
//  AGUtilities
//
//  Created by Mike Godenzi on 07.08.19.
//  Copyright © 2019 Mike Godenzi. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

enum Keychain {

    class Password {

        var data: Data
        let account: String
        let service: String?
        var accessControl: SecAccessControl
        var accessGroup: String?
        let created: Date?
        let modified: Date?

        init(data: Data, account: String, service: String? = nil, accessControl: SecAccessControlCreateFlags = [], protection: Protection = .whenPasscodeSetThisDeviceOnly, accessGroup: String? = nil) {
            self.data = data
            self.account = account
            self.service = service
            self.accessControl = SecAccessControlCreateWithFlags(nil, protection.value, accessControl, nil)!
            self.accessGroup = accessGroup
            self.created = nil
            self.modified = nil
        }

        init(data: Data, account: String, service: String? = nil, accessControl: SecAccessControl, accessGroup: String? = nil, created: Date? = nil, modified: Date? = nil) {
            self.data = data
            self.account = account
            self.service = service
            self.accessControl = accessControl
            self.accessGroup = accessGroup
            self.created = created
            self.modified = modified
        }
    }

    class PrivateKey {

        private let key: SecKey

        init(tag: Data, accessControl: SecAccessControlCreateFlags = [], protection: Keychain.Protection = .whenPasscodeSetThisDeviceOnly) throws {
            var error: Unmanaged<CFError>? = nil
            
            guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection.value, accessControl, &error) else {
                throw Keychain.Error(error?.autorelease().takeUnretainedValue())
            }

            let attributes: [String: Any] = [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeySizeInBits as String: 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
                kSecPrivateKeyAttrs as String: [
                    kSecAttrIsPermanent as String: true,
                    kSecAttrApplicationTag as String: tag,
                    kSecAttrAccessControl as String: access
                ]
            ]

            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                throw Keychain.Error(error?.autorelease().takeUnretainedValue())
            }

            self.key = key
        }

        private init(_ key: SecKey) {
            self.key = key
        }
    }

    struct Protection {
        static let whenUnlocked = Protection(value: kSecAttrAccessibleWhenUnlocked)
        static let afterFirstUnlock = Protection(value: kSecAttrAccessibleAfterFirstUnlock)
        static let whenPasscodeSetThisDeviceOnly = Protection(value: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        static let whenUnlockedThisDeviceOnly = Protection(value: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        static let afterFirstUnlockThisDeviceOnly = Protection(value: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

        fileprivate let value: CFString

        private init(value: CFString) {
            self.value = value
        }
    }
    
    struct Authentication {

        let context: LAContext
        let ui: UI
        let promptMessage: String?

        init(context: LAContext, ui: UI, promptMessage: String? = nil) {
            self.context = context
            self.ui = ui
            self.promptMessage = promptMessage
        }

        struct UI {
            static let allow = UI(value: kSecUseAuthenticationUIAllow)
            static let fail = UI(value: kSecUseAuthenticationUIFail)
            static let skip = UI(value: kSecUseAuthenticationUISkip)

            fileprivate let value: CFString

            private init(value: CFString) {
                self.value = value
            }
        }
    }

    enum Error: Swift.Error {
        case unknown
        case osStatus(OSStatus)
        case `internal`(Swift.Error)
        case publicKeyCopyFailure

        init(_ error: Swift.Error?) {
            if let error = error {
                self = .internal(error)
            } else {
                self = .unknown
            }
        }
    }
}

extension Keychain.Password {

    func save() throws {
        var attributes: [AnyHashable:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrAccessControl as String: accessControl,
            kSecValueData as String: data as CFData
        ]
        if let service = self.service {
            attributes[kSecAttrService as String] = service
        }
        if let accessGroup = accessGroup {
            attributes[kSecAttrAccessGroup as String] = accessGroup
        }

        var status = SecItemAdd(attributes as CFDictionary, nil)
        guard !status.isSuccess else {
            return
        }
        guard status == errSecDuplicateItem else {
            throw Keychain.Error.osStatus(status)
        }
        var query: [AnyHashable:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        if let service = self.service {
            query[kSecAttrService as String] = service
        }
        var toUpdate: [AnyHashable:Any] = [
            kSecAttrAccessControl as String: accessControl,
            kSecValueData as String: data as CFData
        ]
        if let accessGroup = accessGroup {
            toUpdate[kSecAttrAccessGroup as String] = accessGroup
        }
        status = SecItemUpdate(query as CFDictionary, toUpdate as CFDictionary)
        if !status.isSuccess {
            throw Keychain.Error.osStatus(status)
        }
    }

    func delete() throws {
        try Keychain.Password.delete(account: account, service: service)
    }

    static func load(account: String, service: String? = nil, authentication: Keychain.Authentication? = nil) throws -> Keychain.Password {
        let attributes = try load(account: account, service: service, includeData: true, authentication: authentication)
        return Keychain.Password(
            data: attributes[kSecValueData as String] as! Data,
            account: attributes[kSecAttrAccount as String] as! String,
            service: attributes[kSecAttrService as String] as? String,
            accessControl: attributes[kSecAttrAccessControl as String] as! SecAccessControl,
            accessGroup: attributes[kSecAttrAccessGroup as String] as? String,
            created: attributes[kSecAttrCreationDate as String] as? Date,
            modified: attributes[kSecAttrModificationDate as String] as? Date
        )
    }

    static func load(account: String, service: String? = nil, includeData returnData: Bool, authentication: Keychain.Authentication? = nil) throws -> [AnyHashable:Any] {
        var query: [AnyHashable:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: returnData
        ]
        if let service = service {
            query[kSecAttrService as String] = service
        }
        if let authentication = authentication {
            query[kSecUseAuthenticationContext as String] = authentication.context
            query[kSecUseAuthenticationUI as String] = authentication.ui.value
            if let message = authentication.promptMessage {
                query[kSecUseOperationPrompt as String] = message
            }
        }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status.isSuccess, let attributes = result as? [AnyHashable:Any] else {
            throw Keychain.Error.osStatus(status)
        }

        return attributes
    }

    static func delete(account: String, service: String? = nil) throws {
        var query: [AnyHashable:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        if let service = service {
            query[kSecAttrService as String] = service
        }
    let status = SecItemDelete(query as CFDictionary)
        guard status.isSuccess else {
            throw Keychain.Error.osStatus(status)
        }
    }
}

extension Keychain.PrivateKey {

    static func load(tag: Data, authentication: Keychain.Authentication? = nil) throws -> Keychain.PrivateKey {
        var query: [AnyHashable:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        if let authentication = authentication {
            query[kSecUseAuthenticationContext as String] = authentication.context
            query[kSecUseAuthenticationUI as String] = authentication.ui.value
            if let message = authentication.promptMessage {
                query[kSecUseOperationPrompt as String] = message
            }
        }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status.isSuccess, let key = result else {
            throw Keychain.Error.osStatus(status)
        }

        return Keychain.PrivateKey(key as! SecKey)
    }

    static func delete(tag: Data) -> Bool {
        let query: [AnyHashable:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status.isSuccess || status == errSecItemNotFound
    }

    private func copyPublicKey() throws -> SecKey {
        guard let result = SecKeyCopyPublicKey(key) else {
            throw Keychain.Error.publicKeyCopyFailure
        }
        return result
    }

    func encrypt(data: Data) throws -> Data {
        let publicKey = try copyPublicKey()
        var error: Unmanaged<CFError>? = nil
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, &error) else {
            throw Keychain.Error(error?.autorelease().takeUnretainedValue())
        }
        return encryptedData as Data
    }

    func decrypt(data: Data) throws -> Data {
        var error: Unmanaged<CFError>? = nil
        guard let decryptedData = SecKeyCreateDecryptedData(key, .eciesEncryptionStandardX963SHA256AESGCM, data as CFData, &error) else {
            throw Keychain.Error(error?.autorelease().takeUnretainedValue())
        }
        return decryptedData as Data
    }
}

private extension OSStatus {

    var isSuccess: Bool { return self == errSecSuccess }
}
