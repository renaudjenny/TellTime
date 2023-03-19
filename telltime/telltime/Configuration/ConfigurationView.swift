import SwiftUI
import Combine
import ComposableArchitecture
import SwiftClockUI

struct ConfigurationView: View {
    struct ViewState: Equatable {
        var clockStyle: ClockStyle
        var clockConfiguration: ClockConfiguration
        var speechRateRatio: Float
        var speechRateRatioPercentage: Int
        var isMinuteIndicatorsShown: Bool
        var isHourIndicatorsShown: Bool
        var isMinuteIndicatorsToggleEnabled: Bool
        var isHourIndicatorsToggleEnabled: Bool
        var isLimitedHoursShown: Bool
    }

    enum ViewAction: Equatable {
        case setSpeechRateRatio(Float)
        case setMinuteIndicatorsShown(Bool)
        case setHourIndicatorsShown(Bool)
        case setLimitedHoursShown(Bool)
        case setClockStyle(ClockStyle)
    }

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            Group {
                if verticalSizeClass == .regular && horizontalSizeClass == .regular {
                    regularStackedView(viewStore: viewStore)
                } else if verticalSizeClass == .compact || horizontalSizeClass == .regular {
                    horizontalStackedView(viewStore: viewStore)
                } else {
                    verticalStackedView(viewStore: viewStore)
                }
            }
            .padding()
            .navigationBarTitle("Configuration")
        }
    }

    private func verticalStackedView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        VStack {
            stylePicker(viewStore: viewStore).pickerStyle(SegmentedPickerStyle())
            clockView(viewStore: viewStore)
            controls(viewStore: viewStore)
            Spacer()
        }
    }

    private func horizontalStackedView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        HStack {
            VStack {
                clockView(viewStore: viewStore)
                stylePicker(viewStore: viewStore).pickerStyle(SegmentedPickerStyle())
            }
            controls(viewStore: viewStore)
        }
    }

    private func regularStackedView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        VStack {
            HStack {
                clockView(viewStore: viewStore)
                VStack {
                    allClockStylePicker(viewStore: viewStore)
                }
                .frame(maxWidth: 400)
            }
            controls(viewStore: viewStore).frame(maxWidth: 800)
            Spacer()
        }
    }

    private func clockView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        ClockView()
            .padding()
            .allowsHitTesting(false)
            .environment(\.clockStyle, viewStore.clockStyle)
            .environment(\.clockConfiguration, viewStore.clockConfiguration)
    }

    private func controls(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        VStack {
            HStack {
                Text("Speech rate: \(viewStore.speechRateRatioPercentage)%")
                Slider(
                    value: viewStore.binding(get: \.speechRateRatio, send: ViewAction.setSpeechRateRatio),
                    in: 0.5...1.0
                )
                .accentColor(.red)
            }
            Toggle(isOn: viewStore.binding(get: \.isMinuteIndicatorsShown, send: ViewAction.setMinuteIndicatorsShown)) {
                Text("Minute indicators")
            }
            .disabled(!viewStore.isMinuteIndicatorsToggleEnabled)
            Toggle(isOn: viewStore.binding(get: \.isHourIndicatorsShown, send: ViewAction.setHourIndicatorsShown)) {
                Text("Hour indicators")
            }
            .disabled(!viewStore.isHourIndicatorsToggleEnabled)
            Toggle(isOn: viewStore.binding(get: \.isLimitedHoursShown, send: ViewAction.setLimitedHoursShown)) {
                Text("Limited hour texts")
            }
        }
    }

    private func stylePicker(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        Picker("Style", selection: viewStore.binding(get: \.clockStyle, send: ViewAction.setClockStyle)) {
            ForEach(ClockStyle.allCases) { style in
                Text(style.description).tag(style)
            }
        }
    }

    private func allClockStylePicker(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
        ForEach(ClockStyle.allCases) { style in
            Button(action: { viewStore.send(.setClockStyle(style)) }, label: {
                ClockView()
                    .allowsHitTesting(false)
                    .environment(\.clockStyle, style)
                    .environment(\.clockConfiguration, viewStore.clockConfiguration)
                    .padding()
            })
        }
    }
}

private extension AppState {
    var view: ConfigurationView.ViewState {
        ConfigurationView.ViewState(
            clockStyle: configuration.clockStyle,
            clockConfiguration: configuration.clock,
            speechRateRatio: tts.rateRatio,
            speechRateRatioPercentage: Int((tts.rateRatio * 100).rounded()),
            isMinuteIndicatorsShown: configuration.clock.isMinuteIndicatorsShown,
            isHourIndicatorsShown: configuration.clock.isHourIndicatorsShown,
            isMinuteIndicatorsToggleEnabled: configuration.clockStyle != .steampunk,
            isHourIndicatorsToggleEnabled:
                configuration.clockStyle != .artNouveau
                && configuration.clockStyle != .steampunk,
            isLimitedHoursShown: configuration.clock.isLimitedHoursShown
        )
    }
}

private extension AppAction {
    static func view(localAction: ConfigurationView.ViewAction) -> Self {
        switch localAction {
        case .setSpeechRateRatio(let rateRatio): return .tts(.changeRateRatio(rateRatio))
        case .setMinuteIndicatorsShown(let isShown): return .configuration(.setMinuteIndicatorsShown(isShown))
        case .setHourIndicatorsShown(let isShown): return .configuration(.setHourIndicatorsShown(isShown))
        case .setLimitedHoursShown(let isShown): return .configuration(.setLimitedHoursShown(isShown))
        case .setClockStyle(let clockStyle): return .configuration(.setClockStyle(clockStyle))
        }
    }
}

#if DEBUG
struct ConfigurationView_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @Environment(\.calendar) var calendar

        var body: some View {
            NavigationView {
                ConfigurationView(store: .preview)
            }
            .environment(\.verticalSizeClass, .regular)
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.clockDate, .constant(.init(hour: 10, minute: 10, calendar: calendar)))
        }
    }
}

struct ConfigurationViewLandscape_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @Environment(\.calendar) var calendar

        var body: some View {
            NavigationView {
                ConfigurationView(store: .preview)
            }
            .environment(\.verticalSizeClass, .compact)
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.clockDate, .constant(.init(hour: 10, minute: 10, calendar: calendar)))
            .previewLayout(.iPhoneSe(.landscape))
        }
    }
}

struct ConfigurationViewRegular_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        NavigationView {
            ConfigurationView(store: .preview)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.verticalSizeClass, .regular)
        .environment(\.horizontalSizeClass, .regular)
        .environment(\.clockDate, .constant(.init(hour: 10, minute: 10, calendar: calendar)))
        .previewLayout(.fixed(width: 1000, height: 900))
    }
}
#endif
