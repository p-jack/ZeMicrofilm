import Foundation

@MainActor
protocol TimerDelegate:AnyObject {
  func timerFired()
}

@MainActor
final class Timer:ObservableObject {

  weak var delegate:TimerDelegate?
  
  private var task:Task<Void,Error>? = nil
  @Published var seconds:UInt64 = 300

  var interval:ClosedRange<Date> {
    let lastDate = Date(timeInterval:Double(seconds), since:Date.now)
    return Date.now...lastDate
  }

  func cancel() {
    task?.cancel()
    task = nil
  }

  func touch() {
    self.task?.cancel()
    self.task = Task.detached(priority:.background) {
      try await Task.sleep(nanoseconds:self.seconds * 1_000_000_000)
      await self.fire()
      return
    }
  }
  
  private func fire() {
    delegate?.timerFired()
  }

}
