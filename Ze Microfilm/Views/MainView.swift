import SwiftUI

struct MainView: View {
  
  @StateObject var app = AppState()
  
  var body: some View {
    switch app.place {
    case .needsKey:
      SetUpView(app:app)
    case .locked:
      LockedView(app:app)
    case .unlocked:
      ListView(app:app)
    }
  }
}

#Preview {
  MainView()
}


