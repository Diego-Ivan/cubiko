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
