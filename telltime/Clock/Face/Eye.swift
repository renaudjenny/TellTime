import SwiftUI

extension ClockFace {
  struct Eye: View {
    @EnvironmentObject private var store: Store
    let position: Position

    var body: some View {
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
        Iris(clockIsShown: self.store.showClockFace, position: self.position)
          .fill()
      }
    }
  }

  private struct Iris: Shape {
    let clockIsShown: Bool
    let position: Position
    private var animationStep: Double
    static let width: CGFloat = 15

    var animatableData: Double {
      get { self.animationStep }
      set { self.animationStep = newValue }
    }

    init(clockIsShown: Bool, position: Position) {
      self.clockIsShown = clockIsShown
      self.animationStep = clockIsShown ? 1 : 0
      self.position = position
    }

    func path(in rect: CGRect) -> Path {
      let origin = CGPoint(x: rect.width/2, y: rect.height/2)
      let size = CGSize(width: Self.width, height: Self.width)
      let animationStep = CGFloat(self.animationStep)

      let rotationAngle: CGFloat
      switch self.position {
      case .left: rotationAngle = CGFloat.pi/4
      case .right: rotationAngle = -CGFloat.pi/4
      }
      let xTranslation = (rect.width/2 - Self.width/2) * sin(rotationAngle)
      let yTranslation = (rect.height/2 - Self.width/2) * cos(rotationAngle)

      let iris = CGRect(origin: origin, size: size)
        .offsetBy(dx: -Self.width/2, dy: -Self.width/2)
        .applying(.init(
          translationX: xTranslation  * animationStep,
          y: yTranslation * animationStep
        ))

      var path = Path()
      path.addEllipse(in: iris)
      return path
    }
  }

  enum Position {
    case left
    case right
  }
}
