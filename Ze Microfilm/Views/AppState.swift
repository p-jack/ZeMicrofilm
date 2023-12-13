import Foundation
import SwiftUI
import CryptoKit

enum Place {
  case needsKey, locked, unlocked
}

@MainActor
final class AppState:ObservableObject {

  // Models
  var key:SymmetricKey? = nil
  @Published var records:[Record] = []

  // Navigation
  @Published private(set) var place:Place = try! hasPassword() ? .locked : .needsKey
  @Published var record:Record? = nil
  
  // Alerts
  @Published var showAlert = false
  @Published var alertError = true
  @Published var alertText = "An error ocurred."
  
  func by(uuid:Data) -> Record? {
    records.filter{$0.uuid == uuid}.first
  }
  
  func move(to place:Place) {
    withAnimation {
      self.place = place
    }
  }
  
  private func presentError() {
    alertError = true
    alertText = "An error occurred."
    showAlert = true
  }
  
  // -----
  
  private nonisolated func save2(password:String) async throws -> SymmetricKey {
    return try setPassword(password)
  }

  func save(password:String) async {
    do {
      self.key = try await save2(password:password)
      move(to:.unlocked)
    } catch {
      presentError()
    }
  }
  
  // -----

  private nonisolated func attempt(_ password:String) async throws -> SymmetricKey? {
    return try tryPassword(password)
  }
  
  private nonisolated func load(_ key:SymmetricKey) async throws -> [Record] {
    return try Record.load(key:key).sorted()
  }

  func unlock(password:String) async {
    do {
      self.key = try await attempt(password)
      if let key = key {
        self.records = try await load(key)
        move(to:.unlocked)
      } else {
        showAlert = true
        alertError = true
        alertText = "Incorrect master password. Please try again."
      }
    } catch {
      presentError()
    }
  }

  // -----

  private func insert(_ record:Record) {
    for (i, x) in records.enumerated() {
      if record.uuid == x.uuid {
        return
      }
      if record < x {
        records.insert(record, at:i)
        return
      }
    }
    records.append(record)
  }

  private nonisolated func save(record:Record) async throws {
    let key = await self.key!
    try record.save(key:key)
  }
  
  func save() async {
    let record = self.record!
    do {
      try await save(record:record)
      insert(record)
    } catch {
      presentError()
    }
  }

  // -----
  
  private nonisolated func delete(record:Record) async throws {
    try record.delete()
  }

  func delete() async {
    let record = self.record!
    do {
      try await delete(record:record)
      if let i = records.firstIndex(where:{$0.uuid == record.uuid}) {
        records.remove(at:i)
      }
    } catch {
      presentError()
    }
  }

  // -----

  static func preview(with record:Record?) -> AppState {
    let app = AppState()
    app.key = SymmetricKey(data:Data(count:32))
    if let record = record {
      app.records = record.empty ? [] : [record]
    } else {
      app.records = []
    }
    return app
  }
  
}
