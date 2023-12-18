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
  
}
