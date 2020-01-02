import SwiftUI

extension ClockFace {
  struct Eye: View {
    let move: Bool
    let position: Position

    var body: some View {
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
        ClockFace.Iris(move: self.move, position: self.position)
          .fill()
      }
    }
  }

  private struct Iris: Shape {
    let position: Position
    private var animationStep: Double
    static let width: CGFloat = 15

    var animatableData: Double {
      get { self.animationStep }
      set { self.animationStep = newValue }
    }

    init(move: Bool, position: Position) {
      self.animationStep = move ? 1 : 0
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

#if DEBUG
struct Eye_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ClockFace.Eye(move: false, position: .left)
        .padding()
        .frame(width: 150, height: 150)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Eye (not moved)")

      ClockFace.Eye(move: true, position: .left)
        .padding()
        .frame(width: 150, height: 150)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Left eye")

      ClockFace.Eye(move: true, position: .right)
        .padding()
        .frame(width: 150, height: 150)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Right eye")
    }
  }
}
#endif
