import SwiftUI

struct ClockBorder: View {
  let localWidth: CGFloat
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    Group {
      if self.configuration.clockStyle == .artNouveau {
        ArtNouveauClockBorder(localWidth: self.localWidth)
      } else {
        ClassicClockBorder(localWidth: self.localWidth)
      }
    }
  }
}
