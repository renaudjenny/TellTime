import SwiftUI

extension GeometryProxy {
  var localFrame: CGRect { self.frame(in: .local) }
  var localWidth: CGFloat { self.localFrame.width }
  var localHeight: CGFloat { self.localFrame.height }
  var localCenter: CGPoint { .init(x: self.localWidth/2, y: self.localHeight/2) }
  var localTop: CGFloat { self.localFrame.origin.y }
  var localBottom: CGFloat { self.localFrame.height }
  var localLeft: CGFloat { self.localFrame.origin.x }
  var localDiameter: CGFloat { return min(self.localWidth, self.localHeight) }
}

extension Double {
  static let hourInDegree: Double = 30
  static let minuteInDegree = 6.0

  var positiveDegrees: Double {
    guard self < 0 else { return self }
    return self + 360
  }

  var positiveRadians: Double {
    guard self < 0 else { return self }
    return self + Double.pi * 2
  }
}

extension Path {
  mutating func addTest(point: CGPoint) {
    let origin = point.applying(.init(translationX: -5, y: -5))
    self.addEllipse(in: CGRect(origin: origin, size: CGSize(width: 10, height: 10)))
  }
}

extension CGPoint {
  static func pointInCircle(from angle: Angle, frame: CGRect, margin: CGFloat = 0.0) -> Self {
    let radius = (min(frame.width, frame.height) / 2) - margin

    let radians = CGFloat(angle.radians) - CGFloat.pi/2
    let x = radius * cos(radians)
    let y = radius * sin(radians)

    return CGPoint(x: x, y: y).applying(.init(
      translationX: frame.width/2, y: frame.height/2
    ))
  }
}

extension Color {
  static var background: Self {
    Self(UIColor.systemBackground)
  }
}

extension Angle {
  static func fromHour(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let minuteInHour = minute > 0 ? minute/60 : 0
    let hour = Double(Calendar.current.component(.hour, from: date)) + minuteInHour

    let relationship: Double = 360/12
    let degrees = hour * relationship
    return Angle(degrees: degrees)
  }

  static func fromMinute(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let relationship: Double = 360/60
    return Angle(degrees: Double(minute) * relationship)
  }
}
