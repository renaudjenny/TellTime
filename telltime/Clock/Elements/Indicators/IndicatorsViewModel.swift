import SwiftUI

final class IndicatorsViewModel: ObservableObject, Identifiable {
  func positionInCircle(from angle: Angle, frame: CGRect, margin: CGFloat) -> CGPoint {
    let radius = (min(frame.width, frame.height) / 2) - margin

    let radians = CGFloat(angle.radians) - CGFloat.pi/2
    let x = radius * cos(radians)
    let y = radius * sin(radians)

    return CGPoint(x: x, y: y).applying(.init(
      translationX: frame.width/2, y: frame.height/2
    ))
  }
}
