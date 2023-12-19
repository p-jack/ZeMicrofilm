import SwiftUI

struct TimerFooter: View {
  
  @ObservedObject var timer = AppState.shared.timer

  var body:some View {
    HStack {
      Text("Auto-lock in")
      Text(timerInterval:timer.interval)
      Spacer()
      Button("Lock Now") {
        AppState.shared.lock()
      }
    }.padding()
  }
}

