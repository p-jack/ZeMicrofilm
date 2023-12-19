import SwiftUI
import CryptoKit

fileprivate enum AlertState {
  case confirm, error
}

fileprivate enum ButtonState {
  case edit, save, saving, deleting
}

@MainActor
fileprivate class ViewModel:ObservableObject {

  let app:AppState = AppState.shared

  init() {
    self.record = app.navigation.record ?? Record()
    buttonState = record.empty ? .save : .edit
    if record.empty {
      record.password = try! generate()
    }
    site = record.site
    user = record.user
    password = record.password
    memo = record.memo
  }

  var record:Record
  
  @Published var site:String = ""
  @Published var user:String = ""
  @Published var password:String = ""
  @Published var memo:String = ""
  @Published var showPassword = false
  @Published var showToast = false
  @Published var alertState:AlertState = .confirm
  @Published var buttonState:ButtonState = .edit
  
  var alertText:String {
    return alertState == .confirm
    ? "Are you sure? This action cannot be undone."
    : "An error occurred."
  }
  
  var editText:String {
    switch buttonState {
    case .edit: "Edit"
    case .save: "Save"
    default: ""
    }
  }
  
  var viewText:String {
    showPassword ? "Hide Password" : "View Password"
  }
  
  var viewImage:String {
    showPassword ? "eye.slash" : "eye"
  }
  
  func onEdit() {
    if buttonState == .edit {
      buttonState = .save
    } else if buttonState == .save {
      buttonState = .saving
    }
  }
  
  func onView() {
    showPassword = !showPassword
  }
  
  func onCopy() {
    UIPasteboard.general.string = password
    withAnimation { showToast = true }
  }
  
  private nonisolated func sleep(seconds:UInt64) async {
    try! await Task.sleep(nanoseconds:seconds*1000_000_000)
  }

  func hideToast() async {
    await self.sleep(seconds:3)
    withAnimation { showToast = false }
  }
  
  func onDelete() {
    alertState = .confirm
    app.alert.show = true
  }
  
  func delete() async {
    await app.vault.delete(record:record)
  }
  
  func save() async {
    record.site = site
    record.user = user
    record.password = password
    record.memo = memo
    await app.vault.save(record:record)
  }
  
}


struct RecordDetail: View {

  @ObservedObject var alert = AppState.shared.alert
  @ObservedObject var vault = AppState.shared.vault

  @StateObject private var vm:ViewModel = ViewModel()
  
  var body: some View {
    VStack {
      Form {
        Section {
          textField("Site", "example.com", $vm.site)
          textField("Login", "me@gmail.com", $vm.user)
          if vm.showPassword {
            textField("qFg2e-MMmZP-eHQzC", $vm.password)
              .fontDesign(.monospaced)
              .multilineTextAlignment(.center)
          } else {
            LabeledContent {
              Text("•••••")
            } label: {
              Text("Password")
            }
          }
        } header: {
          Text("Details")
        }
        Section {
          TextField("Notes", text:$vm.memo, axis:.vertical)
        } header: {
          Text("Notes")
        }
        Section {
          Button(vm.viewText, systemImage:vm.viewImage) { vm.onView() }
          Button("Copy Password", systemImage:"doc.on.doc") { vm.onCopy() }
          Button("Delete", systemImage:"minus.circle", role:.destructive) { vm.onDelete() }
            .foregroundStyle(.red, .red)
        } header: {
          Text("Actions")
        }
      }
      if vm.showToast {
        HStack(spacing:0) {
          Spacer()
          Text("Password Copied")
            .task { await vm.hideToast() }
            .padding(10)
            .foregroundStyle(.white)
          Spacer()
        }.background(.green)
      }
    }
    .toolbar {
      ToolbarItem(placement:.navigationBarTrailing) {
        if vm.buttonState == .saving {
          ProgressView().task { await vm.save() }
        } else if vm.buttonState == .deleting {
          ProgressView().task { await vm.delete() }
        } else {
          Button(vm.editText) { vm.onEdit() }
        }
      }
    }
    .navigationTitle(vm.site.isEmpty ? "Password" : vm.site)
    .alert(vm.alertText, isPresented:$alert.show) {
      if vm.alertState == .confirm {
        Button("Cancel", role:.cancel) {}
        Button("Delete", role:.destructive) { vm.buttonState = .deleting }
      } else {
        Button("OK", role:.cancel) {}
      }
    }
  }
  
  @ViewBuilder
  private func textField(_ prompt:String, _ binding:Binding<String>) -> some View {
    TextField(prompt, text:binding)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .disabled(vm.buttonState != .save)
      .multilineTextAlignment(.trailing)
  }
  
  @ViewBuilder
  private func textField(_ label:String, _ prompt:String, _ binding:Binding<String>) -> some View {
    LabeledContent {
      textField(prompt, binding)
    } label: {
      Text(label)
    }
  }
}

#Preview {
  RecordDetail()
}
