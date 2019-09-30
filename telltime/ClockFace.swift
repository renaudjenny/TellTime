import SwiftUI

struct ClockFace: View {
  @EnvironmentObject var store: Store

  var body: some View {
    GeometryReader { geometry in
      Circle()
        .fill()
        .frame(width: 15.0, height: 15.0)
        .position(
          x: geometry.frame(in: .local).width/3,
          y: geometry.frame(in: .local).width/3
        )
      Circle()
        .fill()
        .frame(width: 15.0, height: 15.0)
        .position(
          x: geometry.frame(in: .local).width/1.5,
          y: geometry.frame(in: .local).width/3
        )
      Mouth(shape: self.store.showClockFace ? .smile : .neutral)
        .stroke(style: .init(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
        .position(
          x: geometry.frame(in: .local).width/2,
          y: geometry.frame(in: .local).width/1.3
        )
        .frame(width: 150.0, height: 40.0)
    }
    .opacity(self.store.showClockFace ? .opac : .transparent)
    .animation(.easeInOut)
  }
}

struct Mouth: Shape {
  let shape: MouthShape
  private var mouthAnimationShape: Double

  init(shape: MouthShape) {
    self.shape = shape
    self.mouthAnimationShape = shape.rawValue
  }

  var animatableData: Double {
    get { self.mouthAnimationShape }
    set { self.mouthAnimationShape = newValue }
  }

  func path(in rect: CGRect) -> Path {
    let width = rect.width
    let height = rect.height
    guard width > 0, height > 0 else { return Path() }

    let margin: CGFloat = 8.0

    var path = Path()

    let y = height/2 * (1 - CGFloat(self.mouthAnimationShape))
    path.move(to: CGPoint(x: .zero, y: y))

    let leftTo = CGPoint(x: width/2, y: height/2 * (1 + CGFloat(self.mouthAnimationShape)))
    let leftControl = CGPoint(x: .zero + margin, y: leftTo.y)
    path.addQuadCurve(to: leftTo, control: leftControl)

    let rightTo = CGPoint(x: width, y: y)
    let rightControl = CGPoint(x: width - margin, y: leftTo.y)
    path.addQuadCurve(to: rightTo, control: rightControl)

    return path
  }

  enum MouthShape: Double {
    case smile = 1.0
    case neutral = 0.0
    case sad = -1.0
  }
}

fileprivate extension Double {
  static let transparent = 0.0
  static let opac = 1.0
}

struct ClockFace_Previews: PreviewProvider {
  static var previews: some View {
    ClockFace()
  }
}
