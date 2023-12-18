import Foundation

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
