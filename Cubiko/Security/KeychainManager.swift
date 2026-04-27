import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let accessTokenKey = "com.cubiko.accessToken"
    private let refreshTokenKey = "com.cubiko.refreshToken"
    
    private init() {}
    
    // MARK: - Save Tokens
    func saveAccessToken(_ token: String) -> Bool {
        return save(key: accessTokenKey, data: token)
    }
    
    func saveRefreshToken(_ token: String) -> Bool {
        return save(key: refreshTokenKey, data: token)
    }
    
    // MARK: - Get Tokens
    func getAccessToken() -> String? {
        return get(key: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return get(key: refreshTokenKey)
    }
    
    // MARK: - Delete Tokens
    func deleteAllTokens() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }
    
    // MARK: - Private Keychain Helpers
    private func save(key: String, data: String) -> Bool {
        guard let dataFromString = data.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: dataFromString
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            return String(data: retrievedData, encoding: .utf8)
        }
        return nil
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
