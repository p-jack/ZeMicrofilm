import SwiftUI

struct ListView: View {
  
  @ObservedObject var app:AppState
  
  var body: some View {
    NavigationSplitView {
      List(selection:$app.record) {
        ForEach(app.records) { record in
          NavigationLink(value:record) {
            RecordRow(app:app, record:record)
          }
        }
      }
      .navigationTitle("Passwords")
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add", systemImage: "plus")
          }
        }
      }
    } detail: {
      if let _ = app.record {
        RecordDetail(app:app)
      } else {
        Text("Select a password.")
      }
    }
  }
  
  func addItem() {
    withAnimation {
      let record = Record()
      app.record = record
    }
  }
  
}

#Preview {
  ListView(app:AppState())
}
