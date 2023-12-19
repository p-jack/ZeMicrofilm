import SwiftUI

struct RecordRow:View {

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
  RecordRow(record:Record())
}
