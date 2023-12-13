import SwiftUI

struct LockedView:View {
  
  @ObservedObject var app:AppState
  
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
          await app.unlock(password:password)
          withAnimation { spinner = false }
        }
      }
    }
    .padding()
    .alert(app.alertText, isPresented:$app.showAlert, actions: {})
  }
  
}

#Preview {
  LockedView(app:AppState())
}
