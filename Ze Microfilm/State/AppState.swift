import Foundation
import SwiftUI
import CryptoKit

@MainActor
final class AppState:ObservableObject {

  static let shared = AppState()
  
  let alert = Alert()
  let navigation = Navigation()
  let timer = Timer()
  let vault = Vault()

  init() {
    timer.delegate = self
    vault.delegate = self
  }
  
  func move(to place:Place) {
    var newPlace = place
    if place == .unlocked && vault.key == nil {
      newPlace = .locked
    }
    withAnimation {
      navigation.place = newPlace
    }
  }

  func lock() {
    move(to:.locked)
    timer.cancel()
    vault.lock()
    navigation.record = nil
  }

  static func preview(with record:Record?) -> AppState {
    let app = AppState()
    app.vault.key = SymmetricKey(data:Data(count:32))
    if let record = record {
      app.vault.records = record.empty ? [] : [record]
    } else {
      app.vault.records = []
    }
    return app
  }
  
}

extension AppState:VaultDelegate {
  
  func present(error:String) {
    alert.present(error:error)
  }
  
  func vaultCreated() {
    timer.touch()
    move(to:.unlocked)
  }
  
  func vaultLocked() {}
  
  func vaultUnlocked() {
    timer.touch()
    move(to:.unlocked)
  }
  
  func recordSaved() {
    navigation.record = nil
  }
  
  func recordDeleted() {
    navigation.record = nil
  }
  
}

extension AppState:TimerDelegate {
  
  func timerFired() {
    self.lock()
  }
  
}
