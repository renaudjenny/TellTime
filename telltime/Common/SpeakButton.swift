import SwiftUI

struct SpeakButton: View {
  var action: () -> Void
  var progress: Double
  var isSpeaking: Bool

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        Rectangle()
          .fill(Color.gray)
          .cornerRadius(8)
        Rectangle()
          .size(
            width: geometry.size.width * CGFloat(self.progress),
            height: geometry.size.height)
          .fill(Color.red)
          .cornerRadius(8)
          .animation(.easeInOut)
      }
      Button(action: action) {
        Image(systemName: "speaker.2")
          .padding()
          .accentColor(.white)
          .cornerRadius(8)
          .animation(.easeInOut)
      }
      .disabled(self.isSpeaking)
      .layoutPriority(1)
    }
  }
}
