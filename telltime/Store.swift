import SwiftUI
import Combine

final class Store: BindableObject  {
  let didChange = PassthroughSubject<Store, Never>()

  var hour: Int = 12 {
    didSet {
      didChange.send(self)
    }
  }

  var minute: Int = 0 {
    didSet {
      didChange.send(self)
    }
  }

  var date: Date {
    get {
      let components = DateComponents(hour: self.hour, minute: self.minute)
      return Calendar.current.date(from: components) ?? Date()
    }
    set {
      let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
      self.hour = components.hour ?? 0
      self.minute = components.minute ?? 0
    }
  }
}
