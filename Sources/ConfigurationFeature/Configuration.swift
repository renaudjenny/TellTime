import ComposableArchitecture
import SwiftClockUI

public struct Configuration: ReducerProtocol {
    public struct State: Equatable {
        @BindingState public var clock = ClockConfiguration()
        @BindingState public var clockStyle: ClockStyle = .classic
        @BindingState public var speechRateRatio: Float = 1
        public var isPresented = false

        public init(
            clock: ClockConfiguration = ClockConfiguration(),
            clockStyle: ClockStyle = .classic,
            speechRateRatio: Float = 1,
            isPresented: Bool = false
        ) {
            self.clock = clock
            self.clockStyle = clockStyle
            self.speechRateRatio = speechRateRatio
            self.isPresented = isPresented
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case present
        case hide
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
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
