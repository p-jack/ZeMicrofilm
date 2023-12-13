import Foundation

enum HexError:Error {
  case badDigit
}

extension Data {

  func hex() -> String {
    return self.map{ String(format:"%02X", $0) }.joined()
  }

}

extension StringProtocol {
  
  func hex() throws -> Data {
    var bytes:[UInt8] = []
    var nybble:UInt8 = 0
    var first = true
    try self.forEach{
      if let a = $0.hexDigitValue {
        if (first) {
          nybble = UInt8(a)
        } else {
          bytes.append(nybble << 4 | UInt8(a))
        }
      } else {
        throw HexError.badDigit
      }
      first = !first
    }
    return Data(bytes)
  }
  
}
