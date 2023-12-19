import CryptoKit
import Foundation

enum CryptoError:LocalizedError {
  
  case emptyPassword
  
  public var errorDescription: String? {
    switch self {
    case .emptyPassword: return "Your master password cannot be empty."
    }
  }
}

func randomData(_ bytes:Int) -> Data {
  var data = Data(count:bytes)
  let result = data.withUnsafeMutableBytes {
    SecRandomCopyBytes(kSecRandomDefault, bytes, $0.baseAddress!)
  }
  assert(result == 0)
  return data
}

let chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

private func charIndex() throws -> Int {
  var result:Int
  repeat {
    let data = randomData(1)
    result = Int(data.first! & 63)
  } while result >= 62
  return result
}

private func randomChar() throws -> Character {
  let index = chars.index(chars.startIndex, offsetBy:try charIndex())
  return chars[index]
}

func generate() throws -> String {
  var pieces:[String] = []
  for _ in 1...4 {
    var piece = ""
    for _ in 1...5 {
      piece += String(try randomChar())
    }
    pieces.append(piece)
  }
  return pieces.joined(separator:"-")
}


func loadSalt() throws -> Data {
  let url = files.doc("salt.bin")
  if files.exists(url) {
    return try files.load(url)
  }
  let data = randomData(32)
  try files.save(data, to:url)
  return data
}

func hasPassword() throws -> Bool {
  return try files.docs().filter{$0.hasSuffix(".key")}.first != nil
}

func password2Key(_ password:String) throws -> SymmetricKey {
  if password.isEmpty {
    throw CryptoError.emptyPassword
  }
  let keyMat = SymmetricKey(data:Array(password.utf8))
  let salt = try loadSalt()
  let key = HKDF<SHA512>.deriveKey(inputKeyMaterial:keyMat, salt:salt, outputByteCount:32)
  return key
}

func setPassword(_ password:String) throws -> SymmetricKey {
  let key = try password2Key(password)
  let data = randomData(256)
  let uuid = randomData(32)
  let ciphertext = try encrypt(key:key, nonce:ChaChaPoly.Nonce(value:0), uuid:uuid, item:data)
  try files.save(ciphertext, to:files.doc(uuid.hex() + ".key"))
  return key
}

func tryPassword(_ password:String) throws -> SymmetricKey? {
  let key = try password2Key(password)
  let path = try files.docs().filter{$0.hasSuffix(".key")}.first!
  print(path)
  let uuid = try path.dropLast(4).hex()
  let ciphertext = try files.load(files.doc(path))
  do {
    let _:Data = try decrypt(key:key, uuid:uuid, ciphertext:ciphertext)
    return key
  } catch {
    return nil
  }
}

func encrypt(key:SymmetricKey, nonce:ChaChaPoly.Nonce, uuid:Data, item:Codable) throws -> Data {
  let plaintext = try JSONEncoder().encode(item)
  let derivedKey = HKDF<SHA512>.deriveKey(inputKeyMaterial:key, info:uuid, outputByteCount:32)
  return try ChaChaPoly.seal(plaintext, using:derivedKey, nonce:nonce, authenticating:uuid).combined
}

func decrypt<T:Codable>(key:SymmetricKey, uuid:Data, ciphertext:Data) throws -> T {
  let box = try ChaChaPoly.SealedBox(combined:ciphertext)
  let derivedKey = HKDF<SHA512>.deriveKey(inputKeyMaterial:key, info:uuid, outputByteCount:32)
  let data = try ChaChaPoly.open(box, using:derivedKey, authenticating:uuid)
  return try JSONDecoder().decode(T.self, from:data)
}
