import Foundation

import XCTest
@testable import Ze_Microfilm

final class HexTests:XCTestCase {

  func testHex() throws {
    let data = try "001FFF".hex()
    XCTAssertEqual("001FFF", data.hex())
  }
  
  func testBadDigit() throws {
    do {
      let _ = try "....".hex()
      XCTFail()
    } catch HexError.badDigit {
    } catch {
      XCTFail()
    }
  }
  
}
