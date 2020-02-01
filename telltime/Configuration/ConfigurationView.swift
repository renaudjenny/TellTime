import SwiftUI
import Combine

struct ConfigurationContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var clockStyle: Binding<ClockStyle> {
    self.store.binding(for: \.configuration.clockStyle) { .configuration(.changeClockStyle($0)) }
  }
  private var isMinuteIndicatorsShown: Binding<Bool> {
    self.store.binding(for: \.configuration.isMinuteIndicatorsShown) { .configuration(.showMinuteIndicators($0)) }
  }
  private var isHourIndicatorsShown: Binding<Bool> {
    self.store.binding(for: \.configuration.isHourIndicatorsShown) { .configuration(.showHourIndicators($0)) }
  }
  private var isLimitedHoursShown: Binding<Bool> {
    self.store.binding(for: \.configuration.isLimitedHoursShown) { .configuration(.showLimitedHours($0)) }
  }
  private var speechRateRatio: Binding<Float> {
    self.store.binding(for: \.tts.rateRatio) { .tts(.changeRateRatio($0)) }
  }

  var body: some View {
    ConfigurationView(
      clockStyle: self.clockStyle,
      isMinuteIndicatorsShown: self.isMinuteIndicatorsShown,
      isHourIndicatorsShown: self.isHourIndicatorsShown,
      isLimitedHoursShown: self.isLimitedHoursShown,
      speechRateRatio: self.speechRateRatio
    )
      .navigationBarTitle("Configuration")
  }
}

struct ConfigurationView: View {
  @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
  @Binding var clockStyle: ClockStyle
  @Binding var isMinuteIndicatorsShown: Bool
  @Binding var isHourIndicatorsShown: Bool
  @Binding var isLimitedHoursShown: Bool
  @Binding var speechRateRatio: Float

  var body: some View {
    Group {
      if verticalSizeClass == .compact || horizontalSizeClass == .regular {
        HStack {
          VStack {
            ClockContainer()
              .padding()
            StylePicker(clockStyle: self.$clockStyle)
          }
          Controls(
            isMinuteIndicatorsShown: self.$isMinuteIndicatorsShown,
            isHourIndicatorsShown: self.$isHourIndicatorsShown,
            isLimitedHoursShown: self.$isLimitedHoursShown,
            speechRateRatio: self.$speechRateRatio,
            isHourIndicatorsToggleEnabled: self.clockStyle != .artNouveau,
            speechRateRatioPourcentage: self.speechRateRatioPourcentage
          )
        }
      } else {
        VStack {
          StylePicker(clockStyle: self.$clockStyle)
          ClockContainer()
            .padding()
          Controls(
            isMinuteIndicatorsShown: self.$isMinuteIndicatorsShown,
            isHourIndicatorsShown: self.$isHourIndicatorsShown,
            isLimitedHoursShown: self.$isLimitedHoursShown,
            speechRateRatio: self.$speechRateRatio,
            isHourIndicatorsToggleEnabled: self.clockStyle != .artNouveau,
            speechRateRatioPourcentage: self.speechRateRatioPourcentage
          )
          Spacer()
        }
      }
    }
    .padding()
  }

  private var speechRateRatioPourcentage: Int {
    Int(
      (self.speechRateRatio * 100)
        .rounded()
    )
  }
}

private struct Controls: View {
  @Binding var isMinuteIndicatorsShown: Bool
  @Binding var isHourIndicatorsShown: Bool
  @Binding var isLimitedHoursShown: Bool
  @Binding var speechRateRatio: Float
  let isHourIndicatorsToggleEnabled: Bool
  let speechRateRatioPourcentage: Int

  var body: some View {
    VStack {
      HStack {
        Text("Speech rate: \(self.speechRateRatioPourcentage)%")
        Slider(value: self.$speechRateRatio, in: 0.5...1.0)
          .accentColor(.red)
      }
      Toggle(isOn: self.$isMinuteIndicatorsShown) {
        Text("Minute indicators")
      }
      Toggle(isOn: self.$isHourIndicatorsShown) {
        Text("Hour indicators")
      }
      .disabled(!self.isHourIndicatorsToggleEnabled)
      Toggle(isOn: self.$isLimitedHoursShown) {
        Text("Limited hour texts")
      }
    }
  }
}

private struct StylePicker: View {
  @Binding var clockStyle: ClockStyle

  var body: some View {
    Picker("Style", selection: self.$clockStyle) {
      ForEach(ClockStyle.allCases) { style in
        Text(style.description)
          .tag(style)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

#if DEBUG
struct ConfigurationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ConfigurationView(
        clockStyle: .constant(.classic),
        isMinuteIndicatorsShown: .constant(true),
        isHourIndicatorsShown: .constant(true),
        isLimitedHoursShown: .constant(false),
        speechRateRatio: .constant(1.0)
      )
        .navigationBarTitle("Configuration")
    }
    .environmentObject(App.previewStore)
    .environment(\.verticalSizeClass, .regular)
    .environment(\.horizontalSizeClass, .compact)
    .previewLayout(.iPhoneSe)
    .previewDisplayName("Configuration portrait")
  }
}

struct ConfigurationViewLandscape_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ConfigurationView(
        clockStyle: .constant(.classic),
        isMinuteIndicatorsShown: .constant(true),
        isHourIndicatorsShown: .constant(true),
        isLimitedHoursShown: .constant(false),
        speechRateRatio: .constant(1.0)
      )
        .navigationBarTitle("Configuration")
    }
    .environmentObject(App.previewStore)
    .environment(\.verticalSizeClass, .compact)
    .environment(\.horizontalSizeClass, .compact)
    .previewLayout(.iPhoneSe(.landscape))
    .previewDisplayName("Configuration landscape")
  }
}
#endif
