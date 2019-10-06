import Foundation

enum DigitalTime {
  static func from(date: Date) -> String {
    let minute = Calendar.current.component(.minute, from: date)
    let hour = Calendar.current.component(.hour, from: date)
    return Self.from(hour: hour, minute: minute)
  }

  static func from(hour: Int, minute: Int) -> String {
    let minute = minute > 9 ? "\(minute)" : "0\(minute)"
    let hour = hour > 9 ? "\(hour)" : "0\(hour)"
    return "\(hour):\(minute)"
  }
}
