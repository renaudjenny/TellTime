import SwiftUI

struct ClockBorderContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  let localWidth: CGFloat

  var body: some View {
    ClockBorder(
      localWidth: self.localWidth,
      clockStyle: self.store.state.configuration.clockStyle
    )
  }
}

struct ClockBorder: View {
  let localWidth: CGFloat
  let clockStyle: ClockStyle

  var body: some View {
    Group {
      if self.clockStyle == .artNouveau {
        ArtNouveauClockBorder(localWidth: self.localWidth)
      } else if self.clockStyle == .drawing {
        DrawnClockBorder(localWidth: self.localWidth)
      } else {
        ClassicClockBorder(localWidth: self.localWidth)
      }
    }
  }
}
