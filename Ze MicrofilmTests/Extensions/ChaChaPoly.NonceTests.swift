import XCTest
import CryptoKit
@testable import Ze_Microfilm

final class NonceTests:XCTestCase {
  
  func testValue() throws {
    let nonce = ChaChaPoly.Nonce(value:0)
    XCTAssertEqual(0, nonce.value)
    for x:UInt64 in [1, 256, 65535] {
      XCTAssertEqual(x, (nonce + x).value)
    }
  }
  
}
