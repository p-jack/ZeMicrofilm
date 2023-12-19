import SwiftUI

struct MainView: View {
  
  @ObservedObject var navigation = AppState.shared.navigation
  
  var body: some View {
    switch navigation.place {
    case .needsKey:
      SetUpView()
    case .locked:
      LockedView()
    case .unlocked:
      ListView()
    }
  }
  
}

#Preview {
  MainView()
}
