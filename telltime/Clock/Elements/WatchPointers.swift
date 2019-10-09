import SwiftUI

struct WatchPointers: View {
  @Binding var date: Date
  @ObservedObject var hourDragEndedRotationAngle = RotationAngle(angle: .zero)
  @ObservedObject var minuteDragEndedRotationAngle = RotationAngle(angle: .zero)

  var body: some View {
    ZStack {
      WatchPointer(
        lineWidth: 6.0,
        margin: 40.0,
        rotationAngle: RotationAngle(angle: self.hourIntoAngle(date: self.date)),
        dragEndedRotationAngle: self.hourDragEndedRotationAngle
      )
      WatchPointer(
        lineWidth: 4.0,
        margin: 20.0,
        rotationAngle: RotationAngle(angle: self.minuteIntoAngle(date: self.date)),
        dragEndedRotationAngle: self.minuteDragEndedRotationAngle
      )
    }
    .onReceive(self.hourDragEndedRotationAngle.$angle.dropFirst()) { angle in
      let hourRelationship: Double = 360/12
      let hour = angle.degrees.positiveDegrees/hourRelationship
      let minute = Calendar.current.component(.minute, from: self.date)

      self.date = Calendar.current.date(
        bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
        of: self.date
      ) ?? self.date
    }
    .onReceive(self.minuteDragEndedRotationAngle.$angle.dropFirst()) { angle in
      let relationship: Double = 360/60
      let minute = angle.degrees.positiveDegrees/relationship
      let hour = Calendar.current.component(.hour, from: self.date)

      self.date = Calendar.current.date(
        bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
        of: self.date
      ) ?? self.date
    }
  }

  private func hourIntoAngle(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let minuteInHour = minute > 0 ? minute/60 : 0
    let hour = Double(Calendar.current.component(.hour, from: date)) + minuteInHour

    let relationship: Double = 360/12
    let degrees = hour * relationship
    return Angle(degrees: degrees)
  }

  private func minuteIntoAngle(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let relationship: Double = 360/60
    return Angle(degrees: Double(minute) * relationship)
  }
}

#if DEBUG
struct WatchPointers_Previews: PreviewProvider {
  static var previews: some View {
    WatchPointers(date: .constant(Date(timeIntervalSince1970: 123)))
  }
}
#endif
