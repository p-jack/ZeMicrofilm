import XCTest
import CryptoKit
@testable import Ze_Microfilm

final class CryptoTests:XCTestCase {
  
  override func setUpWithError() throws {
    try docs().forEach {
      try FileManager.default.removeItem(at:doc($0))
    }
  }

  func testCrypto() throws {
    let key = try password2Key("password")
    let uuid = randomData(32)
    let d = Record()
    d.user = "name"
    d.site = "site"
    d.password = "password"
    d.memo = "memo"
    let ciphertext = try encrypt(key:key, uuid:uuid, item:d)
    let plaintext:Record = try decrypt(key:key, uuid:uuid, ciphertext:ciphertext)
    XCTAssertEqual(d.user, plaintext.user)
    XCTAssertEqual(d.site, plaintext.site)
    XCTAssertEqual(d.password, plaintext.password)
    XCTAssertEqual(d.memo, plaintext.memo)
  }
  
  func testTrySetPassword() async throws {
    let _ = try setPassword("password")
    XCTAssertNil(try tryPassword("pwd"))
    XCTAssertNotNil(try tryPassword("password"))
  }
  
}
