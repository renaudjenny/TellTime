import SwiftUI

struct ClockContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    ClockView(isClockFaceShown: self.store.state.clock.isClockFaceShown)
      .onTapGesture(count: 3, perform: self.showClockFace)
  }

  private func showClockFace() {
    self.store.send(App.Action.clock(.showClockFace))
    self.store.send(Clock.delayClockFaceHidding())
  }
}

struct ClockView: View {
  static let borderWidthRatio: CGFloat = 1/70
  let isClockFaceShown: Bool

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ClockBorderContainer(localWidth: geometry.localWidth)
        IndicatorsContainer()
        Arms()
        ClockFaceContainer()
          .opacity(self.isClockFaceShown ? 1 : 0)
          .animation(.easeInOut)
      }
      .frame(width: geometry.localDiameter, height: geometry.localDiameter)
      .fixedSize()
    }
    .frame(maxWidth: 500, maxHeight: 500)
  }
}

#if DEBUG
struct ClockView_Previews: PreviewProvider {
  private static func clockView(isClockFaceShown: Bool) -> some View {
    ClockView(isClockFaceShown: isClockFaceShown)
      .environmentObject(App.previewStore)
  }
  static var previews: some View {
    Group {
      Self.clockView(isClockFaceShown: false)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Clock without Face")
      Self.clockView(isClockFaceShown: true)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Clock with Face")
    }
  }
}
#endif
