import XCTest
@testable import telltime
import SwiftUI

class SwiftUIExtensionsTests: XCTestCase {
  func testDoubleExtension() {
    XCTAssertEqual(50.0, 50.0.positiveDegrees)
    XCTAssertEqual(310.0, (-50.0).positiveDegrees)

    XCTAssertEqual(Double.pi, Double.pi.positiveRadians)
    XCTAssertEqual(Double.pi, (-Double.pi).positiveRadians)
  }

  func testCGPointExtensionPointInCircleFromAngleZero() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let angle = Angle(degrees: 0)
    let expectedPoint = CGPoint(x: frame.width/2, y: 0)

    let pointInCircleFromAngle: CGPoint = .pointInCircle(from: angle, frame: frame)
    XCTAssertEqual(expectedPoint.x, pointInCircleFromAngle.x, accuracy: 0.01)
    XCTAssertEqual(expectedPoint.y, pointInCircleFromAngle.y, accuracy: 0.01)
  }

  func testCGPointExtensionPointInCircleFromAngleNinetyDegrees() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let angle = Angle(degrees: 90)
    let expectedPoint = CGPoint(x: frame.width, y: frame.height/2)

    let pointInCircleFromAngle: CGPoint = .pointInCircle(from: angle, frame: frame)
    XCTAssertEqual(expectedPoint.x, pointInCircleFromAngle.x, accuracy: 0.01)
    XCTAssertEqual(expectedPoint.y, pointInCircleFromAngle.y, accuracy: 0.01)
  }

  func testCGPointExtensionPointInCircleFromAngleTwoHundredSeventyDegrees() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let angle = Angle(degrees: 270)
    let expectedPoint = CGPoint(x: 0, y: frame.height/2)

    let pointInCircleFromAngle: CGPoint = .pointInCircle(from: angle, frame: frame)
    XCTAssertEqual(expectedPoint.x, pointInCircleFromAngle.x, accuracy: 0.01)
    XCTAssertEqual(expectedPoint.y, pointInCircleFromAngle.y, accuracy: 0.01)
  }

  func testCGPointExtensionPointInCircleFromAngleFortyFiveDegrees() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let angle = Angle(degrees: 45)

    // https://stackoverflow.com/questions/839899/how-do-i-calculate-a-point-on-a-circle-s-circumference
    // The parametric equation for a circle is
    // https://en.wikipedia.org/wiki/Circle#Equations
    // x = originX + radius * cos(angle)
    // y = originY + radius * sin(angle)
    let originX = 50.0
    let originY = 50.0

    let radius = 50.0

    let cosAngle = cos(angle.radians - Double.pi/2)
    let sinAngle = sin(angle.radians - Double.pi/2)

    let expectedPoint = CGPoint(
      x: originX + radius * cosAngle,
      y: originY + radius * sinAngle
    )

    let pointInCircleFromAngle: CGPoint = .pointInCircle(from: angle, frame: frame)
    XCTAssertEqual(expectedPoint.x, pointInCircleFromAngle.x, accuracy: 0.01)
    XCTAssertEqual(expectedPoint.y, pointInCircleFromAngle.y, accuracy: 0.01)
  }

  func testColorExtensionBackground() {
    XCTAssertEqual(Color(UIColor.systemBackground), Color.background)
  }
}
