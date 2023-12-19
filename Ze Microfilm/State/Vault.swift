import Foundation
import CryptoKit

@MainActor
protocol VaultDelegate:AnyObject {
  func present(error:String)
  func vaultCreated()
  func vaultUnlocked()
  func vaultLocked()
  func recordSaved()
  func recordDeleted()
}

@MainActor
final class Vault:ObservableObject {
  
  var key:SymmetricKey? = nil
  @Published var records:[Record] = []
  
  weak var delegate:VaultDelegate?

  func by(uuid:Data) -> Record? {
    records.filter{$0.uuid == uuid}.first
  }
  
  private nonisolated func create2(password:String) async throws -> SymmetricKey {
    return try setPassword(password)
  }

  func create(password:String) async {
    do {
      self.key = try await create2(password:password)
      delegate?.vaultCreated()
    } catch {
      delegate?.present(error:error.localizedDescription)
    }
  }
  
  func lock() {
    key = nil
    records = []
    delegate?.vaultLocked()
  }
  
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
        delegate?.vaultUnlocked()
      } else {
        delegate?.present(error:"Incorrect master password. Please try again.")
      }
    } catch {
      delegate?.present(error:"An error occurred.")
    }
  }
  
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
  
  private nonisolated func save2(record:Record) async throws {
    let key = await self.key!
    try record.save(key:key)
  }
  
  func save(record:Record) async {
    do {
      try await save2(record:record)
      insert(record)
      delegate?.recordSaved()
    } catch {
      delegate?.present(error:Alert.standard)
    }
  }
  
  private nonisolated func delete2(record:Record) async throws {
    try record.delete()
  }

  func delete(record:Record) async {
    do {
      try await delete2(record:record)
      if let i = records.firstIndex(where:{$0.uuid == record.uuid}) {
        records.remove(at:i)
        delegate?.recordDeleted()
      }
    } catch {
      delegate?.present(error:Alert.standard)
    }
  }

}
