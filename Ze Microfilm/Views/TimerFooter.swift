import SwiftUI

struct LockFooter: View {
  
  @ObservedObject var timer = AppState.shared.timer

  var body:some View {
    HStack {
      Button("Lock Now") {
        AppState.shared.lock()
      }
      Text("Auto-lock in:")
      Text(timerInterval:timer.interval)
    }
  }
}

