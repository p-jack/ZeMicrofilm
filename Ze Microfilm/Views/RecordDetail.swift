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
  
  var app:AppState? = nil {
    didSet {
      buttonState = record.empty ? .save : .edit
      if record.empty {
        record.password = try! generate()
      }
      site = record.site
      user = record.user
      password = record.password
      memo = record.memo
    }
  }
  
  var record:Record { app!.record! }
  
  @Published var site:String = ""
  @Published var user:String = ""
  @Published var password:String = ""
  @Published var memo:String = ""
  @Published var showPassword = false
  @Published var showToast = false
  @Published var alertState:AlertState = .confirm
  @Published var buttonState:ButtonState = .edit
  
  init() {
  }
  
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
    app?.showAlert = true
  }
  
  func delete() async {
    await app?.delete()
    app?.record = nil
  }
  
  func save() async {
    record.site = site
    record.user = user
    record.password = password
    record.memo = memo
    await app?.save()
    buttonState = .edit
    app?.move(to:.unlocked)
  }
  
}


struct RecordDetail: View {
  
  @ObservedObject var app:AppState
  @StateObject private var vm:ViewModel = ViewModel()
  
  init(app:AppState) {
    self.app = app
  }

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
    .alert(vm.alertText, isPresented:$app.showAlert) {
      if vm.alertState == .confirm {
        Button("Cancel", role:.cancel) {}
        Button("Delete", role:.destructive) { vm.buttonState = .deleting }
      } else {
        Button("OK", role:.cancel) {}
      }
    }
    .onAppear() {
      vm.app = app
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
  RecordDetail(app:AppState.preview(with:Record()))
}
