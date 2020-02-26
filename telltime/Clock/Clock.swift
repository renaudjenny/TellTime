import SwiftUI
import Combine
import Foundation

// TODO: Clock is not necessary just for wrapping the date. Move this to the Root Store
enum Clock {
  struct State {
    var date: Date = Current.date()
  }

  enum Action {
    case changeClockRandomly
    case changeDate(Date)
  }

  static func reducer(state: inout Clock.State, action: Clock.Action) {
    switch action {
    case .changeClockRandomly:
      state.date = Current.randomDate()
    case let .changeDate(date):
      state.date = date
    }
  }
}
