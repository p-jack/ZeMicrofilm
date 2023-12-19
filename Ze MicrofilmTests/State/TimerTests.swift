import Foundation

import XCTest
@testable import Ze_Microfilm

final class TimerTests:XCTestCase,TimerDelegate {

  var timer = Timer()
  var fired = false

  override func setUp() async throws {
    timer = Timer()
    timer.seconds = 1
    timer.delegate = self
    fired = false
  }
  
  func timerFired() {
    fired = true
  }
  
  func testFire() async throws {
    timer.now = TimerTests.now
    let fakeNow = timer.now()
    timer.touch()
    let last = Date(timeInterval:1, since:fakeNow)
    XCTAssertEqual(fakeNow...last, timer.interval)
    try await Task.sleep(nanoseconds: 5_100_000_000)
    XCTAssertTrue(fired)
  }

  func testCancel() async throws {
    timer.touch()
    timer.cancel()
    try await Task.sleep(nanoseconds: 5_100_000_000)
    XCTAssertFalse(fired)
  }
  
  static func now() -> Date {
    return Date(timeIntervalSince1970:0)
  }
}

