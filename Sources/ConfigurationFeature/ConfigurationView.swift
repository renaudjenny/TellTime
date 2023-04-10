import ComposableArchitecture
import SwiftClockUI
import SwiftUI

public struct ConfigurationView: View {
    let store: StoreOf<Configuration>

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    public init(store: StoreOf<Configuration>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if verticalSizeClass == .regular && horizontalSizeClass == .regular {
                    regularStackedView()
                } else if verticalSizeClass == .compact || horizontalSizeClass == .regular {
                    horizontalStackedView()
                } else {
                    verticalStackedView()
                }
            }
            .padding()
            .navigationBarTitle("Configuration")
        }
    }

    private func verticalStackedView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                stylePicker().pickerStyle(SegmentedPickerStyle())
                clockView()
                controls()
                Spacer()
            }
        }
    }

    private func horizontalStackedView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                VStack {
                    clockView()
                    stylePicker().pickerStyle(SegmentedPickerStyle())
                }
                controls()
            }
        }
    }

    private func regularStackedView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    clockView()
                    VStack {
                        allClockStylePicker()
                    }
                    .frame(maxWidth: 400)
                }
                controls().frame(maxWidth: 800)
                Spacer()
            }
        }
    }

    private func clockView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ClockView()
                .padding()
                .allowsHitTesting(false)
                .environment(\.clockStyle, viewStore.clockStyle)
                .environment(\.clockConfiguration, viewStore.clock)
        }
    }

    private func controls() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text("Speech rate: \(viewStore.speechRateRatioPercentage)%")
                    Slider(value: viewStore.binding(\.$speechRateRatio), in: 0.5...1.0)
                        .accentColor(.red)
                }
                Toggle(isOn: viewStore.binding(\.$clock.isMinuteIndicatorsShown)) {
                    Text("Minute indicators")
                }
                .disabled(!viewStore.isMinuteIndicatorsToggleEnabled)
                Toggle(isOn: viewStore.binding(\.$clock.isHourIndicatorsShown)) {
                    Text("Hour indicators")
                }
                .disabled(!viewStore.isHourIndicatorsToggleEnabled)
                Toggle(isOn: viewStore.binding(\.$clock.isLimitedHoursShown)) {
                    Text("Limited hour texts")
                }
            }
        }
    }

    private func stylePicker() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Picker("Style", selection: viewStore.binding(\.$clockStyle)) {
                ForEach(ClockStyle.allCases) { style in
                    Text(style.description).tag(style)
                }
            }
        }
    }

    private func allClockStylePicker() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ForEach(ClockStyle.allCases) { style in
                Button(action: { viewStore.send(.set(\.$clockStyle, style)) }, label: {
                    ClockView()
                        .allowsHitTesting(false)
                        .environment(\.clockStyle, style)
                        .environment(\.clockConfiguration, viewStore.clock)
                        .padding()
                })
            }
        }
    }

    private func isMinuteIndicatorsToggleEnabled(state: Configuration.State) -> Bool {
        state.clockStyle != .steampunk
    }
}

private extension Configuration.State {
    var isMinuteIndicatorsToggleEnabled: Bool { clockStyle != .steampunk }
    var isHourIndicatorsToggleEnabled: Bool { clockStyle != .artNouveau && clockStyle != .steampunk }
    var speechRateRatioPercentage: Int { Int((speechRateRatio * 100).rounded()) }
}

#if DEBUG
struct ConfigurationView_Previews: PreviewProvider {
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

extension Store where State == Configuration.State, Action == Configuration.Action {
    static var preview: StoreOf<Configuration> {
        Store(initialState: Configuration.State(), reducer: Configuration())
    }
}

struct ConfigurationViewLandscape_Previews: PreviewProvider {
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
            .previewLayout(.fixed(width: 568, height: 320))
        }
    }
}

struct ConfigurationViewRegular_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @Environment(\.calendar) var calendar

        var body: some View {
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
}
#endif
