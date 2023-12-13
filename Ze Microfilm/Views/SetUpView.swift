import SwiftUI

struct SetUpView: View {
  
  @ObservedObject var app:AppState
  
  @State private var password1 = ""
  @State private var password2 = ""
  @State private var disabled = true
  @State private var spinner = false
  
  var body: some View {
    VStack {
      Text(
        "To get started, enter your master password."
      )
      if spinner {
        ProgressView().task {
          await app.save(password:password1)
        }
      }
      SecureField(
        "Master Password",
        text:$password1,
        onCommit:onCommit
      ).padding().onChange(of:password1) {
        onChange()
      }
      SecureField(
        "Confirm Master Password",
        text:$password2,
        onCommit:onCommit
      ).padding().onChange(of:password2) {
        onChange()
      }
      Button("Continue") {
        spinner = true
      }.disabled(disabled)
    }
    .padding()
    .alert(app.alertText, isPresented:$app.showAlert, actions: {})
  }
  
  func onChange() {
    disabled = password1.count == 0 || password1 != password2
  }
  
  func onCommit() {
    disabled = password1.count == 0 || password1 != password2
  }
  
}

#Preview {
  SetUpView(app:AppState())
}

