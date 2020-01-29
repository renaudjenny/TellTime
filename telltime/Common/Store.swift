import Foundation
import Combine
import SwiftUI

typealias Reducer<State, Action> = (inout State, Action) -> Void

final class Store<State, Action>: ObservableObject {
  typealias Effect = AnyPublisher<Action, Never>

  @Published private(set) var state: State

  private let reducer: Reducer<State, Action>
  private var cancellables: Set<AnyCancellable> = []

  init(initialState: State, reducer: @escaping Reducer<State, Action>) {
    self.state = initialState
    self.reducer = reducer
  }

  func send(_ action: Action) {
    reducer(&state, action)
  }

  func send(_ effect: Effect) {
    var cancellable: AnyCancellable?
    var didComplete = false

    cancellable = effect
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] _ in
          guard let self = self else { return }
          didComplete = true
          if let effectCancellable = cancellable {
            self.cancellables.remove(effectCancellable)
          }
        }, receiveValue: send)

    if !didComplete, let effectCancellable = cancellable {
      cancellables.insert(effectCancellable)
    }
  }
}

extension Store {
  func binding<Value>(
    for keyPath: KeyPath<State, Value>,
    _ action: @escaping (Value) -> Action
  ) -> Binding<Value> {
    Binding<Value>(
      get: { self.state[keyPath: keyPath] },
      set: { self.send(action($0)) }
    )
  }
}
