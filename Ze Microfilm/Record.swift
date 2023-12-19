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
      
  var empty:Bool {
    return site == "" && user == "" && password == "" && memo == ""
  }
  
  var url:URL { files.doc(uuid.hex() + ".pwd") }
  
  static func == (lhs: Record, rhs: Record) -> Bool {
    return lhs.site == rhs.site
    && lhs.user == rhs.user
    && lhs.memo == rhs.memo
    && lhs.uuid == rhs.uuid
  }
  
  static func < (lhs:Record, rhs:Record) -> Bool {
    var x = lhs.site.localizedCompare(rhs.site)
    if x == .orderedAscending { return true }
    if x == .orderedDescending { return false }
    x = lhs.user.localizedCompare(rhs.user)
    if x == .orderedAscending { return true }
    if x == .orderedDescending { return false }
    x = lhs.memo.localizedCompare(rhs.memo)
    if x == .orderedAscending { return true }
    if x == .orderedDescending { return false }
    return lhs.uuid < rhs.uuid
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(site)
    hasher.combine(user)
    hasher.combine(memo)
    hasher.combine(uuid)
  }
  
  func save(key:SymmetricKey) throws {
    let nonce:ChaChaPoly.Nonce
    if files.exists(url) {
      let box = try ChaChaPoly.SealedBox(combined: try files.load(url))
      nonce = box.nonce + 1
    } else {
      nonce = ChaChaPoly.Nonce(value:0)
    }
    let ciphertext = try encrypt(key:key, nonce:nonce, uuid:uuid, item:self)
    try files.save(ciphertext, to:url)
  }
  
  func delete() throws {
    try files.delete(url)
  }
  
  static func load(key:SymmetricKey) throws -> [Record] {
    var records:[Record] = []
    try files.docs().filter{$0.hasSuffix(".pwd")}.forEach{
      do {
        let data = try files.load(files.doc($0))
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

