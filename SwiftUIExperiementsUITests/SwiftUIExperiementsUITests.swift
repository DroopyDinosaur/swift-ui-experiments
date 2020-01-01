//
//  SwiftUIExperiementsUITests.swift
//  SwiftUIExperiementsIUITests
//
//  Created by Cory Loken on 12/8/19.
//  Copyright © 2019 Crunchy Bananas, LLC. All rights reserved.
//

import XCTest

class SwiftUIExperiementsUITests: XCTestCase {
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()
    
    let tablesQuery = app.tables
    tablesQuery.textFields["Edit"].tap()
    
    let textInput = tablesQuery.staticTexts["Display: yoyo"]
    textInput.tap()
    
    let tKey = app.keys["t"]
    tKey.tap()
    XCTAssert(tablesQuery.staticTexts["Display: yoyot"].exists)
    XCTAssert(tablesQuery.staticTexts["Child view value with @Binding: yoyot"].exists)
    XCTAssert(tablesQuery.staticTexts["Child view with parent -> child binding yoyot"].exists)
  }
  
  func testLaunchPerformance() {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
        XCUIApplication().launch()
      }
    }
  }
}
