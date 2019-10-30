import SwiftUI

struct WatchPointer: View {
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  private static let widthRatio: CGFloat = 1/50
  @ObservedObject var viewModel: WatchPointerViewModel
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    GeometryReader { geometry in
      Group {
        if self.configuration.clockStyle == .artNouveau {
          ArtNouveauWatchPointer(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else {
          ClassicWatchPointer(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        }
      }
      .gesture(self.viewModel.dragGesture(globalFrame: geometry.frame(in: .global)))
      .rotationEffect(self.viewModel.rotationAngle)
      .animation(self.viewModel.animate ? .easeInOut : nil)
    }
  }
}

#if DEBUG
struct WatchPointer_Previews: PreviewProvider {
  static var previews: some View {
    WatchPointer(
      lineWidthRatio: 1,
      marginRatio: 1/8,
      viewModel: WatchPointerViewModel(
        rotationAngle: Angle(degrees: 8),
        dragEndedRotationAngle: Angle(degrees: 0)
      )
    )
  }
}
#endif
