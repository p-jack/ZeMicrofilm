import SwiftUI

struct ListView: View {
  
  @ObservedObject var navigation = AppState.shared.navigation
  @ObservedObject var vault = AppState.shared.vault
  @ObservedObject var timer = AppState.shared.timer

  var body: some View {
    NavigationSplitView {
      VStack {
        List(selection:$navigation.record) {
          ForEach(vault.records) { record in
            NavigationLink(value:record) {
              RecordRow(record:record)
            }
          }
        }
        Text(timerInterval:timer.interval)
      }
      .navigationTitle("Passwords")
      .toolbar {
        ToolbarItem {
          Button(action:addItem) {
            Label("Add", systemImage: "plus")
          }
        }
      }
    } detail: {
      if let _ = navigation.record {
        RecordDetail()
      } else {
        Text("Select a password.")
      }
    }
  }
  
  func addItem() {
    withAnimation {
      navigation.record = Record()
    }
  }
  
}

#Preview {
  ListView()
}
