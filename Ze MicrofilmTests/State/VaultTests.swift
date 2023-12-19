import Foundation

import XCTest
@testable import Ze_Microfilm

@MainActor
final class VaultTests:XCTestCase {
  
  struct Events:OptionSet {
    let rawValue:Int
    static let presented = Events(rawValue:1 << 0)
    static let created   = Events(rawValue:1 << 1)
    static let unlocked  = Events(rawValue:1 << 2)
    static let locked    = Events(rawValue:1 << 3)
    static let saved     = Events(rawValue:1 << 4)
    static let deleted   = Events(rawValue:1 << 5)
  }
  
  var vault = Vault()
  var events = Events()
  var presented = ""
  
  override func setUp() async throws {
    try files.docs().forEach {
      try files.delete(files.doc($0))
    }
    vault = Vault()
    vault.delegate = self
    events = Events()
    presented = ""
  }
  
  override func tearDown() async throws {
    files.fail = false
  }
  
  func create() async throws {
    await vault.create(password:"a9870dkva9")
    let record = Record()
    record.site = "github.com"
    record.user = "p-jack"
    record.password = "4780sigha0a"
    await vault.save(record:record)
    events = []
  }
  
  func testCreate() async throws {
    await vault.create(password:"a9870dkva9")
    XCTAssertEqual(events, Events(arrayLiteral:[.created]))
  }
  
  func testBadCreate() async throws {
    await vault.create(password:"")
    XCTAssertEqual(events, Events(arrayLiteral:[.presented]))
    XCTAssertEqual(presented, "Your master password cannot be empty.")
  }
  
  func testLock() async throws {
    try await create()
    vault.lock()
    XCTAssertEqual(events, Events(arrayLiteral:[.locked]))
    XCTAssertNil(vault.key)
    XCTAssertEqual(0, vault.records.count)
  }
  
  func testUnlock() async throws {
    try await create()
    vault.lock()
    events = []
    await vault.unlock(password:"a9870dkva9")
    XCTAssertEqual(events, Events(arrayLiteral:[.unlocked]))
    XCTAssertNotNil(vault.key)
    XCTAssertEqual(1, vault.records.count)
  }
  
  func testUnlockBadPassword() async throws {
    try await create()
    await vault.unlock(password:"a9870dkva")
    XCTAssertEqual(events, Events(arrayLiteral:[.presented]))
    XCTAssertEqual(presented, "Incorrect master password. Please try again.")
  }
  
  func testSaveExisting() async throws {
    try await create()
    let record = vault.records[0]
    record.memo = "abc"
    await vault.save(record:record)
    XCTAssertEqual(events, Events(arrayLiteral:[.saved]))
    vault.lock()
    await vault.unlock(password:"a9870dkva9")
    XCTAssertEqual(1, vault.records.count)
    let loaded = vault.records[0]
    XCTAssertEqual("abc", loaded.memo)
  }
  
  func testSaveNew() async throws {
    try await create()
    let record = Record()
    record.site = "example.com"
    record.user = "user@example.com"
    record.password = "qwet09a3309"
    await vault.save(record:record)
    XCTAssertEqual(events, Events(arrayLiteral:[.saved]))
    vault.lock()
    await vault.unlock(password:"a9870dkva9")
    XCTAssertEqual(2, vault.records.count)
  }
  
  func testSaveBad() async throws {
    try await create()
    let record = Record()
    files.fail = true
    await vault.save(record:record)
    XCTAssertEqual(events, Events(arrayLiteral:[.presented]))
    XCTAssertEqual(presented, "An error occurred.")
  }
  
  func testDelete() async throws {
    try await create()
    let record = vault.records[0]
    await vault.delete(record:record)
    XCTAssertEqual(events, Events(arrayLiteral:[.deleted]))
    vault.lock()
    await vault.unlock(password:"a9870dkva9")
    XCTAssertEqual(0, vault.records.count)
  }

  func testDeleteBad() async throws {
    try await create()
    let record = vault.records[0]
    files.fail = true
    await vault.delete(record:record)
    XCTAssertEqual(events, Events(arrayLiteral:[.presented]))
    XCTAssertEqual(presented, "An error occurred.")
  }

}

extension VaultTests:VaultDelegate {
  
  func present(error:String) {
    events.insert(.presented)
    presented = error
  }
  
  func vaultCreated() {
    events.insert(.created)
  }
  
  func vaultUnlocked() {
    events.insert(.unlocked)
  }
  
  func vaultLocked() {
    events.insert(.locked)
  }
  
  func recordSaved() {
    events.insert(.saved)
  }
  
  func recordDeleted() {
    events.insert(.deleted)
  }

}
