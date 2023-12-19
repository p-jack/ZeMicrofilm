import SwiftUI

struct LockedView:View {
  
  @ObservedObject var alert = AppState.shared.alert
  @ObservedObject var vault = AppState.shared.vault
  
  @State private var password:String = ""
  @State private var spinner = false
  
  var body: some View {
    VStack {
      Text("Enter your master password to unlock.")
      SecureField("Master Password", text:$password).disabled(spinner)
      Button("Unlock") {
        withAnimation { spinner = true }
      }.disabled(spinner)
      if spinner {
        ProgressView().task {
          await vault.unlock(password:password)
          withAnimation { spinner = false }
        }
      }
    }
    .padding()
    .alert(alert.text, isPresented:$alert.show, actions:{})
  }
  
}

#Preview {
  LockedView()
}
