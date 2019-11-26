import SwiftUI
import Combine

struct ConfigurationContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var clockStyle: Binding<ClockStyle> { .init(
    get: { self.store.state.configuration.clockStyle },
    set: { self.store.send(.configuration(action: .changeClockStyle($0))) }
  )}
  private var isMinuteIndicatorsShown: Binding<Bool> { .init(
    get: { self.store.state.configuration.isMinuteIndicatorsShown },
    set: { self.store.send(.configuration(action: .shownMinuteIndicators($0) ))}
  )}
  private var isHourIndicatorsShown: Binding<Bool> { .init(
    get: { self.store.state.configuration.isHourIndicatorsShown },
    set: { self.store.send(.configuration(action: .showHourIndicators($0) ))}
  )}
  private var isLimitedHoursShown: Binding<Bool> { .init(
    get: { self.store.state.configuration.isLimitedHoursShown },
    set: { self.store.send(.configuration(action: .showLimitedHours($0))) }
  )}
  private var speechRateRatio: Binding<Float> { .init(
    get: { self.store.state.configuration.speechRateRatio },
    set: { self.store.send(.configuration(action: .changeSpeechRateRatio($0))) }
  )}

  var body: some View {
    ConfigurationView(
      clockStyle: self.clockStyle,
      isMinuteIndicatorsShown: self.isMinuteIndicatorsShown,
      isHourIndicatorsShown: self.isHourIndicatorsShown,
      isLimitedHoursShown: self.isLimitedHoursShown,
      speechRateRatio: self.speechRateRatio,
      deviceOrientation: self.store.state.deviceOrientation
    )
    // FIXME: TODO .onReceive(self.configuration.$speechRateRatio, perform: { self.tts.rateRatio = $0 })
  }
}

struct ConfigurationView: View {
  @Binding var clockStyle: ClockStyle
  @Binding var isMinuteIndicatorsShown: Bool
  @Binding var isHourIndicatorsShown: Bool
  @Binding var isLimitedHoursShown: Bool
  @Binding var speechRateRatio: Float
  let deviceOrientation: UIDeviceOrientation

  var body: some View {
    Group {
      if self.deviceOrientation.isLandscape {
        self.landscapeBody
      } else {
        self.portraitBody
      }
    }
    .padding()
  }

  private var portraitBody: some View {
    VStack {
      self.stylePicker
      ClockContainer()
        .padding()
      self.controls
      Spacer()
    }
  }

  private var landscapeBody: some View {
    HStack {
      VStack {
        ClockContainer()
          .padding()
        self.stylePicker
      }
      self.controls
    }
  }

  private var controls: some View {
    VStack(spacing: 30.0) {
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
      .disabled(self.clockStyle == .artNouveau)
      Toggle(isOn: self.$isLimitedHoursShown) {
        Text("Limited hour texts")
      }
    }
  }

  private var stylePicker: some View {
    Picker("Style", selection: self.$clockStyle) {
      ForEach(ClockStyle.allCases) { style in
        Text(style.description)
          .tag(style)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }

  private var speechRateRatioPourcentage: Int {
    Int(
      (self.speechRateRatio * 100)
        .rounded()
    )
  }
}

struct Configuration_Previews: PreviewProvider {
  static var previews: some View {
    ConfigurationView(
      clockStyle: .constant(.classic),
      isMinuteIndicatorsShown: .constant(true),
      isHourIndicatorsShown: .constant(true),
      isLimitedHoursShown: .constant(false),
      speechRateRatio: .constant(1.0),
      deviceOrientation: .portrait
    )
  }
}
