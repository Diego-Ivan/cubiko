import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        let token = KeychainManager.shared.getAccessToken()
        isAuthenticated = (token != nil)
    }
    
    func login(accessToken: String, refreshToken: String) {
        _ = KeychainManager.shared.saveAccessToken(accessToken)
        _ = KeychainManager.shared.saveRefreshToken(refreshToken)
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        KeychainManager.shared.deleteAllTokens()
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
