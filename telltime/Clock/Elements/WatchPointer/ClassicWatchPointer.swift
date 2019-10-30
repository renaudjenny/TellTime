import SwiftUI

struct ClassicWatchPointer: View {
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  private static let widthRatio: CGFloat = 1/50
  @ObservedObject var viewModel: WatchPointerViewModel

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let width = geometry.localWidth * Self.widthRatio * self.lineWidthRatio
        let top = center.y * self.marginRatio

        path.addArc(
          center: center,
          radius: width,
          startAngle: .zero,
          endAngle: .degrees(180),
          clockwise: false
        )

        let peak = CGPoint(x: center.x, y: top)

        path.addLine(to: peak.applying(.init(translationX: -width/2, y: 0)))
        path.addLine(to: peak.applying(.init(translationX: width/2, y: 0)))
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
    ClassicWatchPointer(
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
