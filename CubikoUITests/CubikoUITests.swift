//
//  CubikoUITests.swift
//  CubikoUITests
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import XCTest

final class CubikoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // 1. Test that the "Buscar disponibilidad" screen loads and key fields/buttons are present.
    @MainActor
    func testBuscadorViewLoadsAndMainElementsExist() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Look for navigation title and search button
        XCTAssertTrue(app.staticTexts["Buscar disponibilidad"].exists)
        XCTAssertTrue(app.buttons["Buscar disponibilidad"].exists)
        // Check presence of the date and time fields
        XCTAssertTrue(app.buttons["Fecha"].exists)
        XCTAssertTrue(app.buttons["Hora de entrada"].exists)
        XCTAssertTrue(app.buttons["Hora de salida"].exists)
    }

    // 2. Test searching availability (tap fields and button)
    @MainActor
    func testBuscadorViewSearchFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Buscar disponibilidad"].tap()
        // You may want to wait for a result, depending on implementation. This example only checks button tap.
        // Add assertions for expected results here as needed.
    }

    // 3. Test NuevaReservaView: Shows types and Continue button
    @MainActor
    func testNuevaReservaViewMainElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to 'NuevaReservaView' if needed or assert its existence if it is first
        if app.staticTexts["Nueva Reserva"].exists {
            XCTAssertTrue(app.staticTexts["¿Qué tipo de sala buscas?"].exists)
            XCTAssertTrue(app.buttons["Continuar"].exists)
        }
    }

    // 4. Test ReservaView actions exist (assumes navigation to ReservaView, adapt if needed)
    @MainActor
    func testReservaViewActionsExist() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Try to navigate or simulate presence if ReservaView isn't initial screen.
        // Check for action buttons by label
        if app.staticTexts["Mi Reserva"].exists {
            XCTAssertTrue(app.buttons["Cambiar hora de reserva"].exists)
            XCTAssertTrue(app.buttons["Cancelar reserva"].exists)
        }
    }

    // 5. (Optional) Test that PruebaNotificacionesView loads (if accessible from the main UI)
    @MainActor
    func testPruebaNotificacionesViewLoads() throws {
        let app = XCUIApplication()
        app.launch()
        if app.staticTexts["🔔 Prueba de notificaciones"].exists {
            XCTAssertTrue(app.staticTexts["Nueva reserva"].exists)
            XCTAssertTrue(app.buttons["Crear reserva"].exists)
        }
    }
}
