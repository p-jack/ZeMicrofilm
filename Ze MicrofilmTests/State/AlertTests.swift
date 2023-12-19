import Foundation

import XCTest
@testable import Ze_Microfilm

@MainActor
final class AlertTests:XCTestCase {

  func testPresent() throws {
    let alert = Alert()
    XCTAssertFalse(alert.show)
    XCTAssertEqual(Alert.standard, alert.text)
    alert.present(error:"abc")
    XCTAssertTrue(alert.show)
    XCTAssertEqual("abc", alert.text)
  }
  
}


