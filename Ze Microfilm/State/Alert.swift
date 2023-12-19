import Foundation

@MainActor
final class Alert:ObservableObject {
  
  static let standard = "An error occurred."
  
  @Published var show = false
  @Published var error = true
  @Published var text = standard

  func present(error:String) {
    self.error = true
    self.text = error
    self.show = true
  }

}
