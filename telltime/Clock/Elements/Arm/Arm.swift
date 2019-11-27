import SwiftUI

struct ArmContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  let type: ArmType

  var body: some View {
    Arm(
      clockStyle: self.store.state.configuration.clockStyle,
      lineWidthRatio: self.ratios(for: self.type).lineWidthRatio,
      marginRatio: self.ratios(for: self.type).marginRatio,
      angle: self.setupAngle(),
      setAngle: self.setAngle
    )
  }

  private func setupAngle() -> Angle {
    let date = self.store.state.clock.date
    switch self.type {
    case .hour: return .fromHour(date: date)
    case .minute: return .fromMinute(date: date)
    }
  }

  private func setAngle(_ angle: Angle) {
    switch type {
      case .hour:
        self.store.send(.clock(.changeHourAngle(angle)))
      case .minute:
        self.store.send(.clock(.changeMinuteAngle(angle)))
    }
  }

  private func ratios(for type: ArmType) -> (lineWidthRatio: CGFloat, marginRatio: CGFloat) {
    switch type {
    case .hour: return (lineWidthRatio: 1/2, marginRatio: 2/5)
    case .minute: return (lineWidthRatio: 1/3, marginRatio: 1/8)
    }
  }
}

struct Arm: View {
  private static let widthRatio: CGFloat = 1/50
  @State private var animate: Bool = true
  let clockStyle: ClockStyle
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  let angle: Angle
  let setAngle: (Angle) -> Void

  var body: some View {
    GeometryReader { geometry in
      Group {
        if self.clockStyle == .artNouveau {
          ArtNouveauArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else if self.clockStyle == .drawing {
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
          self.setAngle(angle)
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
    self.setAngle(angle)
  }
}

enum ArmType {
  case hour
  case minute
}

#if DEBUG
struct Arm_Previews: PreviewProvider {
  static var previews: some View {
    Arm(
      clockStyle: .classic,
      lineWidthRatio: 1/2,
      marginRatio: 2/5,
      angle: .zero,
      setAngle: { print("new angle: \($0)") }
    )
  }
}
#endif
