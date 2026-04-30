//
//  CubikoUnitTests.swift
//  CubikoUnitTests
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import XCTest
import SwiftUI
@testable import Cubiko

final class ViewTests: XCTestCase {
    func testHomeViewInitializes() {
        _ = HomeView()
        // Note: Cannot directly inspect @State var currentState. Ensures no crash on init.
    }
    
    func testLoginViewInitializes() {
        let view = LoginView(currentState: .constant(.login))
        _ = view // Just ensures it can be initialized
    }

    func testRegisterViewInitializes() {
        let view = RegisterView(currentState: .constant(.register))
        _ = view // Just ensures it can be initialized
    }
}

final class DomainModelsTests: XCTestCase {
    func testUserStateCoversAllCases() {
        let allCases: [UserState] = [.login, .register, .main]
        XCTAssertEqual(allCases.count, 3)
    }
}

final class NetworkingModelsTests: XCTestCase {

    @MainActor
    func testLoginResponseDecoding() throws {
        let json = """
        {"success":true,"data":{"access_token":"abc123","expires_in":"3600"},"message":"OK","error":null}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: json)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data?.access_token, "abc123")
        XCTAssertEqual(response.message, "OK")
        XCTAssertNil(response.error)
    }

    @MainActor
    func testRegisterResponseDecoding() throws {
        let json = """
        {"success":true,"data":{"access_token":"xyz456","expires_in":"3600"},"message":"Registro exitoso"}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(RegisterResponse.self, from: json)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data?.access_token, "xyz456")
        XCTAssertEqual(response.message, "Registro exitoso")
    }
}

// MARK: - UserProfile Tests
final class UserProfileTests: XCTestCase {
    func testAuthorizationHeaderValue() {
        var profile = UserProfile(accessToken: "", refreshToken: nil, expiresAt: nil)
        XCTAssertNil(profile.authorizationHeaderValue)
        
        profile.accessToken = "abc123"
        XCTAssertEqual(profile.authorizationHeaderValue, "Bearer abc123")
    }
    
    func testIsTokenValidWithoutExpiry() {
        let valid = UserProfile(accessToken: "token", refreshToken: nil, expiresAt: nil)
        XCTAssertTrue(valid.isTokenValid)
        
        let invalid = UserProfile(accessToken: "", refreshToken: nil, expiresAt: nil)
        XCTAssertFalse(invalid.isTokenValid)
    }
    
    func testIsTokenValidWithExpiry() {
        let future = Date().addingTimeInterval(120)
        let past   = Date().addingTimeInterval(-120)
        
        let p1 = UserProfile(accessToken: "t", refreshToken: nil, expiresAt: future)
        XCTAssertTrue(p1.isTokenValid)
        
        let p2 = UserProfile(accessToken: "t", refreshToken: nil, expiresAt: past)
        XCTAssertFalse(p2.isTokenValid)
    }
}

// MARK: - KeychainManager Tests
final class KeychainManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        KeychainManager.shared.deleteAllTokens()
    }
    
    override func tearDown() {
        KeychainManager.shared.deleteAllTokens()
        super.tearDown()
    }
    
    func testSaveGetDeleteTokens() {
        let km = KeychainManager.shared
        
        XCTAssertTrue(km.saveAccessToken("access-123"))
        XCTAssertTrue(km.saveRefreshToken("refresh-456"))
        
        XCTAssertEqual(km.getAccessToken(), "access-123")
        XCTAssertEqual(km.getRefreshToken(), "refresh-456")
        
        km.deleteAllTokens()
        
        XCTAssertNil(km.getAccessToken())
        XCTAssertNil(km.getRefreshToken())
    }
}

// MARK: - AuthManager Tests
final class AuthManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        KeychainManager.shared.deleteAllTokens()
        AuthManager.shared.logout()
        // Give async state a moment to propagate
        waitBriefly()
    }
    
    override func tearDown() {
        AuthManager.shared.logout()
        KeychainManager.shared.deleteAllTokens()
        waitBriefly()
        super.tearDown()
    }
    
    func testLoginSetsAuthenticatedAndSavesTokens() {
        let auth = AuthManager.shared
        XCTAssertFalse(auth.isAuthenticated)
        
        auth.login(accessToken: "A1", refreshToken: "R1")
        waitBriefly()
        
        XCTAssertTrue(auth.isAuthenticated)
        XCTAssertEqual(KeychainManager.shared.getAccessToken(), "A1")
        XCTAssertEqual(KeychainManager.shared.getRefreshToken(), "R1")
    }
    
    func testLogoutClearsAuthenticationAndTokens() {
        let auth = AuthManager.shared
        auth.login(accessToken: "A2", refreshToken: "R2")
        waitBriefly()
        
        auth.logout()
        waitBriefly()
        
        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertNil(KeychainManager.shared.getAccessToken())
        XCTAssertNil(KeychainManager.shared.getRefreshToken())
    }
}

// MARK: - SessionManager Tests
@MainActor
final class SessionManagerTests: XCTestCase {
    private let profileKey = "current_user_profile"
    
    override func setUp() {
        super.setUp()
        // Clean persistence before each test
        UserDefaults.standard.removeObject(forKey: profileKey)
        KeychainManager.shared.deleteAllTokens()
        AuthManager.shared.logout()
    }
    
    override func tearDown() {
        // Clean persistence after each test
        UserDefaults.standard.removeObject(forKey: profileKey)
        KeychainManager.shared.deleteAllTokens()
        AuthManager.shared.logout()
        super.tearDown()
    }
    
    func testLoginPersistsProfileAndTokens() throws {
        let manager = SessionManager()
        manager.logout()
        
        let profile = UserProfile(accessToken: "tok-1", refreshToken: "ref-1", expiresAt: Date().addingTimeInterval(3600))
        manager.login(with: profile)
        
        XCTAssertEqual(manager.profile, profile)
        XCTAssertEqual(KeychainManager.shared.getAccessToken(), "tok-1")
        XCTAssertEqual(KeychainManager.shared.getRefreshToken(), "ref-1")
        XCTAssertNotNil(UserDefaults.standard.data(forKey: profileKey))
    }
    
    func testLogoutClearsPersistence() {
        let manager = SessionManager()
        let profile = UserProfile(accessToken: "tok-2", refreshToken: "ref-2", expiresAt: nil)
        manager.login(with: profile)
        
        manager.logout()
        
        XCTAssertNil(manager.profile)
        XCTAssertNil(KeychainManager.shared.getAccessToken())
        XCTAssertNil(KeychainManager.shared.getRefreshToken())
        XCTAssertNil(UserDefaults.standard.data(forKey: profileKey))
    }
    
    func testInitLoadsProfileWhenTokensPresent() throws {
        // Arrange persisted profile and tokens
        let saved = UserProfile(accessToken: "tok-3", refreshToken: "ref-3", expiresAt: nil)
        let encoded = try JSONEncoder().encode(saved)
        UserDefaults.standard.set(encoded, forKey: profileKey)
        _ = KeychainManager.shared.saveAccessToken(saved.accessToken)
        if let rt = saved.refreshToken { _ = KeychainManager.shared.saveRefreshToken(rt) }
        
        // Act
        let manager = SessionManager()
        
        // Assert
        XCTAssertEqual(manager.profile?.accessToken, "tok-3")
    }
    
    func testInitClearsProfileWhenNoTokens() throws {
        // Arrange: Save profile but no tokens in Keychain
        let saved = UserProfile(accessToken: "tok-4", refreshToken: "ref-4", expiresAt: nil)
        let encoded = try JSONEncoder().encode(saved)
        UserDefaults.standard.set(encoded, forKey: profileKey)
        KeychainManager.shared.deleteAllTokens()
        
        // Act
        let manager = SessionManager()
        
        // Assert: Manager should have cleared invalid session
        XCTAssertNil(manager.profile)
        XCTAssertNil(UserDefaults.standard.data(forKey: profileKey))
    }
}

// MARK: - APIConfig Tests
final class APIConfigTests: XCTestCase {
    func testBaseURLHostIsExpected() {
        XCTAssertEqual(APIConfig.baseURL.host, "cubiko_api-staging.diegoivan-mae.workers.dev")
    }
}

// MARK: - ReservasViewModel simple tests
final class ReservasViewModelTests: XCTestCase {
    func testFetchReservasWithNilTokenSetsError() {
        let vm = ReservasViewModel()
        vm.fetchReservas(token: nil)
        XCTAssertEqual(vm.error, "No se encontró el token de acceso. Por favor inicie sesión de nuevo.")
        XCTAssertFalse(vm.isLoading)
    }
    
    func testFetchReservasActualesWithNilTokenSetsError() {
        let vm = ReservasViewModel()
        vm.fetchReservasActuales(token: nil)
        XCTAssertEqual(vm.error, "No se encontró el token de acceso. Por favor inicie sesión de nuevo.")
        XCTAssertFalse(vm.isLoading)
    }
}

// MARK: - Additional Networking Model Decoding Tests
final class MoreNetworkingModelsTests: XCTestCase {
    @MainActor
    func testLoginResponseDecodingWithErrorMessage() throws {
        let json = """
        {"success":false,"data":null,"message":"Invalid","error":"invalid_credentials"}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: json)
        XCTAssertFalse(response.success)
        XCTAssertNil(response.data)
        XCTAssertEqual(response.message, "Invalid")
        XCTAssertEqual(response.error, "invalid_credentials")
    }
    
    @MainActor
    func testRegisterResponseDecodingWithoutRefreshToken() throws {
        let json = """
        {"success":true,"data":{"access_token":"zzz","expires_in":"3600"},"message":"OK"}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(RegisterResponse.self, from: json)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data?.access_token, "zzz")
        XCTAssertNil(response.data?.refresh_token)
        XCTAssertEqual(response.message, "OK")
    }
}

// MARK: - Small utility for async waits in tests
private func waitBriefly(_ interval: TimeInterval = 0.1) {
    let exp = XCTestExpectation(description: "wait briefly")
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) { exp.fulfill() }
    let _ = XCTWaiter.wait(for: [exp], timeout: interval + 1.0)
}

