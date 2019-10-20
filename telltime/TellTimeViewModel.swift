import SwiftUI
import Combine
import SwiftPastTen

final class TellTimeViewModel: ObservableObject, Identifiable {
  @Published var date: Date
  @Published var deviceOrientation = UIDevice.current.orientation
  @Published var isClockFaceShown: Bool = false
  @Published var isSpeaking: Bool = false
  @Published var speakingProgress: Double = 1.0
  var configuration: ConfigurationStore
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()
  var tts = TTS()

  private var disposables = Set<AnyCancellable>()

  var time: String {
    guard let time = try? tellTimeEngine.tell(time: DigitalTime.from(date: self.date)) else {
      return ""
    }
    return time
  }

  init(date: Date = Date(), configuration: ConfigurationStore) {
    self.date = date
    self.configuration = configuration
    self.subscribe()
  }

  private func subscribe() {
    NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      .sink(receiveValue: { notification in
        guard let device = notification.object as? UIDevice else { return }
        guard device.orientation.isValidInterfaceOrientation else { return }

        let isPhoneUpsideDown = device.orientation == .portraitUpsideDown && device.userInterfaceIdiom == .phone
        guard !isPhoneUpsideDown else { return }

        self.deviceOrientation = device.orientation
      })
      .store(in: &self.disposables)

    self.tts.isSpeaking
      .assign(to: \.isSpeaking, on: self)
      .store(in: &self.disposables)

    self.tts.speakingProgress
      .assign(to: \.speakingProgress, on: self)
      .store(in: &self.disposables)

    self.$date
      .sink(receiveValue: { date in
        guard !self.isSpeaking else { return }
        self.tts.speech(text: DigitalTime.from(date: date))
      })
      .store(in: &self.disposables)

    self.$isClockFaceShown
      .filter({ $0 == true })
      .delay(for: 2.0, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.isClockFaceShown = false
      })
      .store(in: &self.disposables)

    self.configuration.$speechRateRatio
      .assign(to: \.tts.rateRatio, on: self)
      .store(in: &self.disposables)
  }

  func showClockFace() {
     self.isClockFaceShown = true
   }

  func changeClockRandomly() {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0

    guard let newDate = Calendar.current.date(
      byAdding: DateComponents(hour: hour, minute: minute),
      to: self.date
    ) else { return }

    self.date = newDate
  }

  func tellTime() {
    self.tts.speech(text: DigitalTime.from(date: self.date))
  }
}
