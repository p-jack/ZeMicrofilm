import XCTest
import CryptoKit
@testable import Ze_Microfilm

final class CryptoTests:XCTestCase {
  
  override func setUpWithError() throws {
    try files.docs().forEach {
      try files.delete(files.doc($0))
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
    let ciphertext = try encrypt(key:key, nonce:ChaChaPoly.Nonce(value:0), uuid:uuid, item:d)
    let plaintext:Record = try decrypt(key:key, uuid:uuid, ciphertext:ciphertext)
    XCTAssertEqual(d.user, plaintext.user)
    XCTAssertEqual(d.site, plaintext.site)
    XCTAssertEqual(d.password, plaintext.password)
    XCTAssertEqual(d.memo, plaintext.memo)
  }
  
  func testTrySetPassword() throws {
    let _ = try setPassword("password")
    XCTAssertNil(try tryPassword("pwd"))
    XCTAssertNotNil(try tryPassword("password"))
  }
  
  func testGenerate() throws {
    let password = try generate()
    let pieces = password.split(separator:"-")
    XCTAssertEqual(4, pieces.count)
    for piece in pieces {
      XCTAssertEqual(5, piece.count)
      for ch in piece {
        XCTAssertTrue(ch.isASCII)
        XCTAssertTrue(ch.isLetter || ch.isNumber)
      }
    }
    let password2 = try generate()
    XCTAssertNotEqual(password, password2)
  }
  
}
