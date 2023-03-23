import SwiftUI
import SwiftPastTen

func tellTime(date: Date, calendar: Calendar) -> String {
    let time = SwiftPastTen.formattedDate(date, calendar: calendar)
    guard let tellTime = try? SwiftPastTen().tell(time: time) else { return "" }
    return tellTime
}
