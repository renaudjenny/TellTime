import SwiftUI
import Combine

final class WatchPointerViewModel: ObservableObject, Identifiable {
  @Published var rotationAngle: Angle
  @Published var dragEndedRotationAngle: Angle
  @Published var animate: Bool = true

  func dragGesture(globalFrame: CGRect) -> AnyGesture<DragGesture.Value> {
    return AnyGesture<DragGesture.Value>(
      DragGesture(coordinateSpace: .global)
        .onChanged({ self.changePointerGesture($0, frame: globalFrame) })
        .onEnded({ _ in
          self.dragEndedRotationAngle = self.rotationAngle
          self.animate = true
        })
    )
  }

  init(rotationAngle: Angle, dragEndedRotationAngle: Angle) {
    self.rotationAngle = rotationAngle
    self.dragEndedRotationAngle = dragEndedRotationAngle
  }

  private func changePointerGesture(_ value: DragGesture.Value, frame: CGRect) {
    let radius = frame.size.width/2
    let location = (
      x: value.location.x - radius - frame.origin.x,
      y: -(value.location.y - radius - frame.origin.y)
    )
    let arctan = atan2(location.x, location.y)
    self.animate = false
    self.rotationAngle = Angle(radians: Double(arctan).positiveRadians)
  }
}
