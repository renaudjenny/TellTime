import SwiftUI

final class RotationAngle: ObservableObject {
  @Published var angle: Angle

  init(angle: Angle) {
    self.angle = angle
  }
}
