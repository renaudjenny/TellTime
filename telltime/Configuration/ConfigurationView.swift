import SwiftUI
import Combine
import SwiftClockUI

struct ConfigurationView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var store: Store<App.State, App.Action>

    var body: some View {
        Group {
            if verticalSizeClass == .compact || horizontalSizeClass == .regular {
                horizontalStackedView
            } else {
                verticalStackedView
            }
        }
        .padding()
        .navigationBarTitle("Configuration")
    }

    private var verticalStackedView: some View {
        VStack {
            StylePicker()
            clockView
            Controls()
            Spacer()
        }
    }

    private var horizontalStackedView: some View {
        HStack {
            VStack {
                clockView
                StylePicker()
            }
            Controls()
        }
    }

    private var clockView: some View {
        ClockView()
            .padding()
            .allowsHitTesting(false)
            .environment(\.clockStyle, store.state.configuration.clockStyle)
            .environment(\.clockConfiguration, store.state.configuration.clock)
    }
}

private struct Controls: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    private var isMinuteIndicatorsShown: Binding<Bool> {
        self.store.binding(for: \.configuration.clock.isMinuteIndicatorsShown) {
            .configuration(.showMinuteIndicators($0))
        }
    }
    private var isHourIndicatorsShown: Binding<Bool> {
        self.store.binding(for: \.configuration.clock.isHourIndicatorsShown) {
            .configuration(.showHourIndicators($0))
        }
    }
    private var isLimitedHoursShown: Binding<Bool> {
        self.store.binding(for: \.configuration.clock.isLimitedHoursShown) {
            .configuration(.showLimitedHours($0))
        }
    }
    private var speechRateRatio: Binding<Float> {
        self.store.binding(for: \.tts.rateRatio) { .tts(.changeRateRatio($0)) }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Speech rate: \(speechRateRatioPourcentage)%")
                Slider(value: speechRateRatio, in: 0.5...1.0)
                    .accentColor(.red)
            }
            Toggle(isOn: isMinuteIndicatorsShown) {
                Text("Minute indicators")
            }
            Toggle(isOn: isHourIndicatorsShown) {
                Text("Hour indicators")
            }
            .disabled(!isHourIndicatorsToggleEnabled)
            Toggle(isOn: self.isLimitedHoursShown) {
                Text("Limited hour texts")
            }
        }
    }

    private var speechRateRatioPourcentage: Int {
        Int((speechRateRatio.wrappedValue * 100).rounded())
    }

    var isHourIndicatorsToggleEnabled: Bool {
        store.state.configuration.clockStyle != .artNouveau
    }
}

private struct StylePicker: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    private var clockStyle: Binding<ClockStyle> {
        self.store.binding(for: \.configuration.clockStyle) { .configuration(.changeClockStyle($0)) }
    }

    var body: some View {
        Picker("Style", selection: self.clockStyle) {
            ForEach(ClockStyle.allCases) { style in
                Text(style.description).tag(style)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#if DEBUG
struct ConfigurationView_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        NavigationView {
            ConfigurationView()
        }
        .environmentObject(App.previewStore)
        .environment(\.verticalSizeClass, .regular)
        .environment(\.horizontalSizeClass, .compact)
        .environment(\.clockDate, .constant(.init(hour: 10, minute: 10, calendar: calendar)))
    }
}

struct ConfigurationViewLandscape_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        NavigationView {
            ConfigurationView()
        }
        .environmentObject(App.previewStore)
        .environment(\.verticalSizeClass, .compact)
        .environment(\.horizontalSizeClass, .compact)
        .environment(\.clockDate, .constant(.init(hour: 10, minute: 10, calendar: calendar)))
        .previewLayout(.iPhoneSe(.landscape))
    }
}
#endif
