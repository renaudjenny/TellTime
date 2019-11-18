import SwiftUI

struct Arm: View {
  private static let widthRatio: CGFloat = 1/50
  @EnvironmentObject var configuration: ConfigurationStore
  @EnvironmentObject var clock: ClockStore
  @State private var angle: Angle = .zero
  @State private var animate: Bool = true
  let type: ArmType
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat

  init(type: ArmType) {
    self.type = type
    switch type {
    case .hour:
      self.lineWidthRatio = 1/2
      self.marginRatio = 2/5
    case .minute:
      self.lineWidthRatio = 1/3
      self.marginRatio = 1/8
    }
  }

  var body: some View {
    GeometryReader { geometry in
      Group {
        if self.configuration.clockStyle == .artNouveau {
          ArtNouveauArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else if self.configuration.clockStyle == .drawing {
          DrawnArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else {
          ClassicArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        }
      }
      .gesture(self.dragGesture(globalFrame: geometry.frame(in: .global)))
      .rotationEffect(self.angle)
      .animation(self.animate ? .easeInOut : nil)
    }
    .onReceive(self.clock.$date, perform: self.setupAngle)
  }
}

// MARK: - Drag Gesture
extension Arm {
  func dragGesture(globalFrame: CGRect) -> AnyGesture<DragGesture.Value> {
    return AnyGesture<DragGesture.Value>(
      DragGesture(coordinateSpace: .global)
        .onChanged({ self.changePointerGesture($0, frame: globalFrame) })
        .onEnded({
          let angle = self.angle(dragGestureValue: $0, frame: globalFrame)
          switch self.type {
          case .hour: self.clock.hourAngle = angle
          case .minute: self.clock.minuteAngle = angle
          }
          self.animate = true
        })
    )
  }

  private func angle(dragGestureValue: DragGesture.Value, frame: CGRect) -> Angle {
    let radius = frame.size.width/2
    let location = (
      x: dragGestureValue.location.x - radius - frame.origin.x,
      y: -(dragGestureValue.location.y - radius - frame.origin.y)
    )
    let arctan = atan2(location.x, location.y)
    return Angle(radians: Double(arctan).positiveRadians)
  }

  private func changePointerGesture(_ value: DragGesture.Value, frame: CGRect) {
    self.animate = false
    let angle = self.angle(dragGestureValue: value, frame: frame)
    switch self.type {
    case .hour: self.angle = angle
    case .minute: self.angle = angle
    }
  }
}

// MARK: Angle
extension Arm {
  func setupAngle(_ date: Date) {
    switch self.type {
    case .hour: self.angle = .fromHour(date: date)
    case .minute: self.angle = .fromMinute(date: date)
    }
  }
}

enum ArmType {
  case hour
  case minute
}

#if DEBUG
struct Arm_Previews: PreviewProvider {
  static var previews: some View {
    Arm(type: .hour)
  }
}
#endif
