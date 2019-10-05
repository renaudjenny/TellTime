import SwiftUI

extension ClockFace {
  struct Eye: View {
    @EnvironmentObject var store: Store
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

      let xTranslation: CGFloat
      switch self.position {
      case .left: xTranslation = rect.width/2 - Self.width
      case .right: xTranslation = -(rect.width/2 - Self.width)
      }
      let yTranslation = rect.height/2 - Self.width

      let iris = CGRect(origin: origin, size: size)
        .offsetBy(dx: -Self.width/2, dy: -Self.width/2)
        .applying(.init(
          translationX: xTranslation * CGFloat(self.animationStep),
          y: yTranslation * CGFloat(self.animationStep)
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
