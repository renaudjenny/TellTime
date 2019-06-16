import SwiftUI
import Combine

final class Store: BindableObject  {
  let didChange = PassthroughSubject<Store, Never>()

  var hour: Int {
    get { Calendar.current.component(.hour, from: self.date) }
    set {
      self.date = Calendar.current.date(byAdding: DateComponents(hour: newValue), to: self.date) ?? Date()
    }
  }

  var minute: Int {
    get { Calendar.current.component(.minute, from: self.date) }
    set {
      self.date = Calendar.current.date(byAdding: DateComponents(minute: newValue), to: self.date) ?? Date()
    }
  }

  var date: Date = Date() {
    didSet {
      self.didChange.send(self)
    }
  }
}
