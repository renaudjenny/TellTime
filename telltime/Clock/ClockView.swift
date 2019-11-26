import SwiftUI

struct ClockContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    ClockView(isClockFaceShown: self.store.state.clock.isClockFaceShown)
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
struct Clock_Previews: PreviewProvider {
  static var previews: some View {
    ClockView(isClockFaceShown: false)
  }
}
#endif
