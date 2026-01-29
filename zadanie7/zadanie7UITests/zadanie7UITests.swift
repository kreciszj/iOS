import XCTest

final class zadanie7UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testElementsExistence() throws {
        // 1
        XCTAssertTrue(app.images["globeImage"].waitForExistence(timeout: 2))
        // 2
        XCTAssertTrue(app.staticTexts["greetingText"].exists)
        // 3
        XCTAssertTrue(app.buttons["tapButton"].exists)
        // 4
        XCTAssertTrue(app.staticTexts["counterLabel"].exists)
        // 5
        XCTAssertTrue(app.textFields["inputField"].exists)
        // 6
        XCTAssertTrue(app.buttons["submitButton"].exists)
        // 7
        XCTAssertTrue(app.staticTexts["submittedLabel"].exists)
        // 8
        XCTAssertTrue(app.switches["toggleSwitch"].exists || app.toggles["toggleSwitch"].exists)
        // 9
        XCTAssertTrue(app.sliders["volumeSlider"].exists)
        // 10
        XCTAssertTrue(app.segmentedControls["segmentPicker"].exists || app.otherElements["segmentPicker"].exists)
        // 11
        XCTAssertTrue(app.buttons["openDetailButton"].exists)
        // 12
        XCTAssertTrue(app.tables["mainList"].exists)
    }

    func testCounterButtonIncrements() throws {
        let counter = app.staticTexts["counterLabel"]
        // 13
        XCTAssertTrue(counter.label.contains("Counter: 0"))
        app.buttons["tapButton"].tap()
        sleep(1)
        // 14
        XCTAssertTrue(counter.label.contains("Counter: 1"))
        app.buttons["tapButton"].tap()
        sleep(1)
        // 15
        XCTAssertTrue(counter.label.contains("Counter: 2"))
    }

    func testTextFieldSubmitClearsAndShowsValue() throws {
        let input = app.textFields["inputField"]
        let submit = app.buttons["submitButton"]
        let submitted = app.staticTexts["submittedLabel"]

        input.tap()
        input.typeText("abc")
        // 16
        submit.tap()
        sleep(1)
        XCTAssertTrue(submitted.label.contains("Submitted: abc"))
        // 17
        XCTAssertEqual(input.value as? String ?? "", "")
        // 18
        XCTAssertTrue(submit.isHittable)
    }

    func testToggleAndPickerBehavior() throws {
        let toggleStatus = app.staticTexts["toggleStatusLabel"]
        let toggle = app.switches["toggleSwitch"].firstMatch
        // 19
        XCTAssertTrue(toggleStatus.label.contains("OFF"))
        if toggle.exists { toggle.tap() } else { app.buttons["Włącz"].tap() }
        sleep(1)
        // 20
        XCTAssertTrue(toggleStatus.label.contains("ON"))
        // 21
        XCTAssertTrue(app.buttons["A"].exists)
        // 22
        app.buttons["B"].tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["selectionLabel"].label.contains("B"))
        // 23
        app.buttons["C"].tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["selectionLabel"].label.contains("C"))
    }

    func testNavigationAndListRows() throws {
        let table = app.tables["mainList"]
        // 24
        XCTAssertEqual(table.cells.count, 3)
        // 25
        XCTAssertTrue(app.staticTexts["row_1"].exists)
        // 26
        XCTAssertTrue(app.staticTexts["row_2"].exists)
        // 27
        XCTAssertTrue(app.staticTexts["row_3"].exists)
        app.buttons["openDetailButton"].tap()
        sleep(1)
        // 28
        XCTAssertTrue(app.staticTexts["detailViewLabel"].exists)
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
        }
        sleep(1)
        // 29
        table.cells.element(boundBy: 1).tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["rowDetailLabel_2"].exists)
        // 30
        XCTAssertTrue(app.staticTexts["rowDetailLabel_2"].label.contains("Row 2 Detail"))
    }
}

private extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
