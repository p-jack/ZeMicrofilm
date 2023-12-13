import SwiftUI

struct RecordRow: View {

  @ObservedObject var app:AppState
  var record:Record

  var body: some View {
    VStack {
        Text(record.site)
//        Label(record.user)
    }
    .padding()
  }
}

#Preview {
  ListView(app:AppState())
}


