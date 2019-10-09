import SwiftUI

struct WatchPointer: View {
  let lineWidth: CGFloat
  let margin: CGFloat
  @ObservedObject var rotationAngle: RotationAngle
  @ObservedObject var dragEndedRotationAngle: RotationAngle
  @State var animate: Bool = true

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let top = geometry.localTop
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: top + self.margin))
      }
      .stroke(lineWidth: self.lineWidth)
      .gesture(DragGesture(coordinateSpace: .global)
        .onChanged({ self.changePointerGesture($0, frame: geometry.frame(in: .global)) })
        .onEnded({ _ in
          self.dragEndedRotationAngle.angle = self.rotationAngle.angle
          self.animate = true
        })
      )
      .rotationEffect(self.rotationAngle.angle)
      .animation(self.animate ? .easeInOut : nil)
    }
  }

  private func changePointerGesture(_ value: DragGesture.Value, frame: CGRect) {
    let radius = frame.size.width/2
    let location = (
      x: value.location.x - radius - frame.origin.x,
      y: -(value.location.y - radius - frame.origin.y)
    )
    let arctan = atan2(location.x, location.y)
    self.animate = false
    self.rotationAngle.angle = Angle(radians: Double(arctan).positiveRadians)
  }
}

#if DEBUG
struct WatchPointer_Previews: PreviewProvider {
  static var previews: some View {
    WatchPointer(
      lineWidth: 6.0,
      margin: 40.0,
      rotationAngle: RotationAngle(angle: Angle(degrees: 8)),
      dragEndedRotationAngle: RotationAngle(angle: Angle(degrees: 0))
    )
  }
}
#endif
