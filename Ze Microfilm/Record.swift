import Foundation
import CryptoKit

final class Record:Codable,Identifiable,Hashable,Comparable {
  
  var id:Data { uuid }
  
  var uuid:Data
  var user:String = ""
  var site:String = ""
  var password:String = ""
  var memo:String = ""
  var noise:String = ""
  
  enum CodingKeys: String, CodingKey {
    case uuid
    case user = "user"
    case site = "site"
    case password = "password"
    case memo = "memo"
  }
  
  init() {
    self.uuid = randomData(32)
    self.noise = genNoise()
  }
  
  init(uuid:Data) {
    self.uuid = uuid
    self.noise = genNoise()
  }
  
  var empty:Bool {
    return site == "" && user == "" && password == "" && memo == ""
  }
  
  var url:URL { doc(uuid.hex() + ".pwd") }
  
  static func == (lhs: Record, rhs: Record) -> Bool {
    return lhs.site == rhs.site
    && lhs.user == rhs.user
    && lhs.memo == rhs.user
  }
  
  static func < (lhs:Record, rhs:Record) -> Bool {
    var x = lhs.site.localizedCompare(rhs.site)
    if x == .orderedDescending { return true }
    if x == .orderedAscending { return true }
    x = lhs.user.localizedCompare(rhs.user)
    if x == .orderedDescending { return true }
    if x == .orderedAscending { return true }
    x = lhs.memo.localizedCompare(rhs.memo)
    if x == .orderedDescending { return true }
    if x == .orderedAscending { return true }
    return lhs.uuid < rhs.uuid
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(site)
    hasher.combine(user)
    hasher.combine(memo)
  }
  
  func save(key:SymmetricKey) throws {
    let ciphertext = try encrypt(key:key, uuid:uuid, item:self)
    try ciphertext.write(to:url)
  }
  
  func delete() throws {
    try FileManager.default.removeItem(at:url)
  }
  
  static func load(key:SymmetricKey) throws -> [Record] {
    var records:[Record] = []
    try docs().filter{$0.hasSuffix(".pwd")}.forEach{
      do {
        let data = try Data(contentsOf:doc($0))
        let uuid = try $0.dropLast(4).hex()
        let record:Record = try decrypt(key: key, uuid: uuid, ciphertext: data)
        record.uuid = uuid
        records.append(record)
      } catch {
        print($0, error)
      }
    }
    return records
  }
  
  private func genNoise() -> String {
    let data = randomData(2)
    let size = (Int(data[0]) << 8 | Int(data[1])) & 1023 + 16
    return randomData(size).base64EncodedString()
  }
  
}

extension Data {
  static func < (lhs:Data, rhs:Data) -> Bool {
    let a = Array(lhs)
    let b = Array(rhs)
    let n = Swift.min(a.count, b.count)
    let i = 0
    while i < n {
      if a[i] < b[i] { return true }
      if a[i] > b[i] { return false }
    }
    return a.count < b.count
  }
}
