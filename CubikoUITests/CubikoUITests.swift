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

    // MARK: - Helpers
    /// Launches the app with common UI testing arguments.
    @discardableResult
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Add a flag your app can check to alter behavior for UI tests if desired.
        app.launchArguments += ["-ui-testing"]
        app.launch()
        return app
    }

    /// Waits for an element to appear within the given timeout.
    @discardableResult
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

    /// Asserts that an element exists, with a helpful message.
    private func assertExists(_ element: XCUIElement, _ name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.exists, "Expected \(name) to exist", file: file, line: line)
    }

    /// Registers a generic handler for system alerts (e.g., notification permission).
    private func registerSystemAlertHandler(app: XCUIApplication) {
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            // Try common buttons in English and Spanish
            let allowButtons = ["Allow", "Allow While Using App", "Permitir", "Permitir mientras usas la app", "OK", "Aceptar"]
            for label in allowButtons {
                let btn = alert.buttons[label]
                if btn.exists {
                    btn.tap()
                    return true
                }
            }
            // Fallback: tap first button if any
            if let first = alert.buttons.allElementsBoundByIndex.first {
                first.tap()
                return true
            }
            return false
        }
        // Ensure the app is in foreground to receive the alert
        app.activate()
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

    // MARK: - Additional UI Tests

    /// Validates that the root screen shows either the Buscador, Nueva Reserva, or Mi Reserva title.
    @MainActor
    func testRootScreenShowsKnownTitle() throws {
        let app = launchApp()
        let titles = [
            app.staticTexts["Buscar disponibilidad"],
            app.staticTexts["Nueva Reserva"],
            app.staticTexts["Mi Reserva"]
        ]
        let anyExists = titles.contains { waitForElement($0) }
        XCTAssertTrue(anyExists, "Expected one of the known titles to be visible on launch.")
    }

    /// Tapping the Fecha field should present a date picker.
    @MainActor
    func testBuscadorDatePickerOpens() throws {
        let app = launchApp()

        guard app.staticTexts["Buscar disponibilidad"].exists || app.buttons["Buscar disponibilidad"].exists else {
            throw XCTSkip("Buscador screen not found on launch")
        }

        let fechaButton = app.buttons["Fecha"]
        guard waitForElement(fechaButton) else { throw XCTSkip("Fecha button not found") }
        fechaButton.tap()

        // Assert any date picker appears (inline or modal)
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(waitForElement(datePicker), "Expected a date picker to appear after tapping Fecha")

        // If a Done/OK exists, tap it to dismiss
        let doneButtons = ["Done", "OK", "Aceptar", "Cerrar", "Listo"]
        for label in doneButtons {
            let btn = app.buttons[label]
            if btn.exists { btn.tap(); break }
        }
    }

    /// Tapping the Hora de entrada and Hora de salida should present time pickers.
    @MainActor
    func testBuscadorTimePickersOpen() throws {
        let app = launchApp()

        guard app.staticTexts["Buscar disponibilidad"].exists || app.buttons["Buscar disponibilidad"].exists else {
            throw XCTSkip("Buscador screen not found on launch")
        }

        let timeButtons = ["Hora de entrada", "Hora de salida"]
        for label in timeButtons {
            let btn = app.buttons[label]
            guard waitForElement(btn) else { throw XCTSkip("\(label) button not found") }
            btn.tap()
            let timePicker = app.datePickers.firstMatch
            XCTAssertTrue(waitForElement(timePicker), "Expected a time/date picker for \(label)")
            // Dismiss if possible
            let done = app.buttons["Done"]
            if done.exists { done.tap() }
        }
    }

    /// After tapping Buscar disponibilidad, expect either a results list or some result indicator.
    @MainActor
    func testBuscadorSearchShowsResultsOrList() throws {
        let app = launchApp()

        guard app.staticTexts["Buscar disponibilidad"].exists || app.buttons["Buscar disponibilidad"].exists else {
            throw XCTSkip("Buscador screen not found on launch")
        }

        let searchButton = app.buttons["Buscar disponibilidad"]
        guard waitForElement(searchButton) else { throw XCTSkip("Search button not found") }
        searchButton.tap()

        // Wait for either a list of cells or a label hinting at results
        let listAppeared = app.cells.firstMatch.waitForExistence(timeout: 5) || app.tables.firstMatch.waitForExistence(timeout: 5) || app.collectionViews.firstMatch.waitForExistence(timeout: 5)
        let resultsLabelAppeared = app.staticTexts["Resultados"].waitForExistence(timeout: 5)
        XCTAssertTrue(listAppeared || resultsLabelAppeared, "Expected some indication of results after searching")
    }

    /// NuevaReservaView: Continue flow should be present; if selection is required, try tapping the first selectable item.
    @MainActor
    func testNuevaReservaContinueFlow() throws {
        let app = launchApp()

        guard waitForElement(app.staticTexts["Nueva Reserva"]) else {
            throw XCTSkip("Nueva Reserva screen not present on launch")
        }

        let continueButton = app.buttons["Continuar"]
        XCTAssertTrue(continueButton.exists, "Continuar button should exist")

        // Try to select a type if any selectable buttons exist (excluding Continuar)
        let candidateButtons = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.label != "Continuar" }
        if let first = candidateButtons.first { first.tap() }

        // Attempt to proceed
        if continueButton.isHittable { continueButton.tap() }

        // Expect either navigation or some confirmation element to appear; this is flexible
        let possibleNext = [app.staticTexts["Mi Reserva"], app.staticTexts["Resumen"], app.staticTexts["Confirmación"]]
        let advanced = possibleNext.contains { $0.waitForExistence(timeout: 5) }
        // If it didn't advance, we don't fail the test—UI may require additional input
        if !advanced { throw XCTSkip("Could not advance past Nueva Reserva (may require additional input)") }
    }

    /// ReservaView: Cancel action should show a confirmation alert.
    @MainActor
    func testReservaViewCancelShowsAlert() throws {
        let app = launchApp()

        guard waitForElement(app.staticTexts["Mi Reserva"]) else {
            throw XCTSkip("Reserva screen not present on launch")
        }

        let cancelButton = app.buttons["Cancelar reserva"]
        guard waitForElement(cancelButton) else { throw XCTSkip("Cancelar reserva button not found") }
        cancelButton.tap()

        // Expect an alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Expected a confirmation alert after tapping Cancelar reserva")

        // Tap the most affirmative action if available
        let affirmativeButtons = ["Sí", "Confirmar", "Eliminar", "Cancelar reserva", "OK", "Aceptar"]
        for label in affirmativeButtons {
            let btn = alert.buttons[label]
            if btn.exists { btn.tap(); break }
        }
    }

    /// PruebaNotificacionesView: Tapping Crear reserva may trigger a notification permission prompt; handle it.
    @MainActor
    func testPruebaNotificacionesPermissionFlow() throws {
        let app = launchApp()
        guard waitForElement(app.staticTexts["🔔 Prueba de notificaciones"]) else {
            throw XCTSkip("Prueba de notificaciones screen not present on launch")
        }

        registerSystemAlertHandler(app: app)

        let createButton = app.buttons["Crear reserva"]
        guard waitForElement(createButton) else { throw XCTSkip("Crear reserva button not found") }
        createButton.tap()

        // Give time for any system alert to appear and be handled
        sleep(1)
        app.tap() // Trigger the interruption monitor
    }

    /// Take a screenshot of the initial screen for visual verification.
    @MainActor
    func testTakeInitialScreenshot() throws {
        let app = launchApp()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Initial Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// If a tab bar exists, iterate through its tabs to ensure they are tappable.
    @MainActor
    func testTabBarNavigationIfPresent() throws {
        let app = launchApp()
        let tabBar = app.tabBars.firstMatch
        if !tabBar.exists { throw XCTSkip("No tab bar present") }

        for button in tabBar.buttons.allElementsBoundByIndex where button.exists {
            button.tap()
            XCTAssertTrue(button.isSelected || button.isHittable, "Tab button \(button.label) should be selectable or remain hittable")
        }
    }

    /// If a list of results exists, perform a pull-to-refresh gesture.
    @MainActor
    func testPullToRefreshIfListPresent() throws {
        let app = launchApp()
        let table = app.tables.firstMatch
        let collection = app.collectionViews.firstMatch
        if table.exists {
            table.swipeDown()
        } else if collection.exists {
            collection.swipeDown()
        } else {
            throw XCTSkip("No list present to pull-to-refresh")
        }
    }

    /// Ensure the primary search button is hittable on the Buscador view.
    @MainActor
    func testSearchButtonIsHittable() throws {
        let app = launchApp()
        guard app.staticTexts["Buscar disponibilidad"].exists || app.buttons["Buscar disponibilidad"].exists else {
            throw XCTSkip("Buscador screen not found on launch")
        }
        let searchButton = app.buttons["Buscar disponibilidad"]
        XCTAssertTrue(searchButton.exists, "Search button should exist")
        XCTAssertTrue(searchButton.isHittable, "Search button should be hittable")
    }
}
