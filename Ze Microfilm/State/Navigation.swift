import Foundation
import SwiftUI

enum Place {
  case needsKey, locked, unlocked
}

@MainActor
final class Navigation:ObservableObject {
  
  @Published var place:Place = try! hasPassword() ? .locked : .needsKey
  @Published var record:Record? = nil
  
}
