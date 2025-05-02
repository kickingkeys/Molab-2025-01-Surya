//
//  KeychainManager.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 02/05/25.
//

import Foundation
import Security

enum KeychainManager {
    enum Keys: String {
        case claudeAPIKey = "com.thoughtsort.claudeAPIKey"
    }

    static func saveAPIKey(_ key: String) {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Keys.claudeAPIKey.rawValue,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Keys.claudeAPIKey.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr,
           let data = dataTypeRef as? Data,
           let key = String(data: data, encoding: .utf8) {
            return key
        }

        return nil
    }
}
