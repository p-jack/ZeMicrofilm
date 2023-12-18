import Foundation
import CryptoKit

extension ChaChaPoly.Nonce {
  
  init(value:UInt64) {
    var v = value
    var bytes:[UInt8] = []
    while v > 0 {
      bytes.append(UInt8(v & 0xFF))
      v = v >> 8
    }
    while bytes.count < 12 {
      bytes.append(0)
    }
    bytes.reverse()
    try! self.init(data:Data(bytes))
  }
  
  var value:UInt64 {
    var result:UInt64 = 0
    for v in self {
      result = (result << 8) | UInt64(v)
    }
    return result
  }
  
  static func +(_ nonce:ChaChaPoly.Nonce, _ value:UInt64) -> ChaChaPoly.Nonce {
    ChaChaPoly.Nonce(value:nonce.value + value)
  }
  
}
