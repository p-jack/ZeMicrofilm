import SwiftUI

struct SetUpView: View {
  
  @ObservedObject var alert = AppState.shared.alert
  @ObservedObject var vault = AppState.shared.vault
  
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
          await vault.create(password:password1)
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
    .alert(alert.text, isPresented:$alert.show, actions:{})
  }
  
  func onChange() {
    disabled = password1.count == 0 || password1 != password2
  }
  
  func onCommit() {
    disabled = password1.count == 0 || password1 != password2
  }
  
}

#Preview {
  SetUpView()
}

