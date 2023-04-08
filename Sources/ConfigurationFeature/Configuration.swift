import ComposableArchitecture
import SwiftClockUI

struct Configuration: ReducerProtocol {
    struct State: Equatable {
        @BindingState var clock = ClockConfiguration()
        @BindingState var clockStyle: ClockStyle = .classic
        @BindingState var speechRateRatio: Float
        var isPresented = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case present
        case hide
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .present:
                state.isPresented = true
                return .none
            case .hide:
                state.isPresented = false
                return .none
            }
        }
    }
}
