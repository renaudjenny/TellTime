import SwiftUI

struct WatchPointer: View {
  let lineWidth: CGFloat
  let margin: CGFloat
  @ObservedObject var viewModel: WatchPointerViewModel

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let top = geometry.localTop
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: top + self.margin))
      }
        .stroke(lineWidth: self.lineWidth)
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
      lineWidth: 6.0,
      margin: 40.0,
      viewModel: WatchPointerViewModel(
        rotationAngle: Angle(degrees: 8),
        dragEndedRotationAngle: Angle(degrees: 0)
      )
    )
  }
}
#endif
