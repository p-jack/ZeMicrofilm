import Foundation
import CryptoKit
import XCTest
@testable import Ze_Microfilm

final class RecordTests:XCTestCase {

  override func setUpWithError() throws {
    try docs().forEach {
      try FileManager.default.removeItem(at:doc($0))
    }
  }

  func testRecords() throws {
    let key = try setPassword("password")
    var records = try Record.load(key:key)
    XCTAssertTrue(records.isEmpty)
    var record = Record()
    record.site = "site"
    record.user = "user"
    record.password = "password"
    record.memo = "memo"
    try record.save(key:key)
    var data = try Data(contentsOf:record.url)
    var box = try ChaChaPoly.SealedBox(combined:data)
    XCTAssertEqual(0, box.nonce.value)

    records = try Record.load(key:key)
    XCTAssertEqual(1, records.count)
    record = records[0]
    XCTAssertEqual("site", record.site)
    XCTAssertEqual("user", record.user)
    XCTAssertEqual("password", record.password)
    XCTAssertEqual("memo", record.memo)
    try record.save(key:key)
    data = try Data(contentsOf:record.url)
    box = try ChaChaPoly.SealedBox(combined:data)
    XCTAssertEqual(1, box.nonce.value)
    
    try record.delete()
    records = try Record.load(key:key)
    XCTAssertTrue(records.isEmpty)
  }
  
  func testLessThan() {
    let r1 = Record()
    let r2 = Record()
    r1.site = "github.com"
    r2.site = "example.com"
    XCTAssertFalse(r1 < r2)
    XCTAssertTrue(r2 < r1)
    r2.site = "github.com"
    r1.user = "p-jack"
    r2.user = "not-pjack"
    XCTAssertFalse(r1 < r2)
    XCTAssertTrue(r2 < r1)
    r2.user = "p-jack"
    r1.memo = "b"
    r2.memo = "a"
    XCTAssertFalse(r1 < r2)
    XCTAssertTrue(r2 < r1)
    r2.memo = "b"
    r1.uuid = Data([1])
    r2.uuid = Data([0])
    XCTAssertFalse(r1 < r2)
    XCTAssertTrue(r2 < r1)
  }

  func testEmpty() {
    let r = Record()
    XCTAssertTrue(r.empty)
    r.site = "github.com"
    XCTAssertFalse(r.empty)
    r.site = ""
    r.user = "p-jack"
    XCTAssertFalse(r.empty)
    r.user = ""
    r.memo = "abc"
    XCTAssertFalse(r.empty)
  }
  
  func testEquals() {
    let r1 = Record()
    let r2 = Record()
    XCTAssertFalse(r1 == r2)
    XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    r1.uuid = r2.uuid
    XCTAssertTrue(r1 == r2)
    XCTAssertEqual(r1.hashValue, r2.hashValue)

    r1.site = "github.com"
    XCTAssertFalse(r1 == r2)
    XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    r2.site = "github.com"
    XCTAssertTrue(r1 == r2)
    XCTAssertEqual(r1.hashValue, r2.hashValue)

    r1.user = "p-jack"
    XCTAssertFalse(r1 == r2)
    XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    r2.user = "p-jack"
    XCTAssertTrue(r1 == r2)
    XCTAssertEqual(r1.hashValue, r2.hashValue)

    r1.memo = "abc"
    XCTAssertFalse(r1 == r2)
    XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    r2.memo = "abc"
    XCTAssertTrue(r1 == r2)
    XCTAssertEqual(r1.hashValue, r2.hashValue)
  }
  
}
