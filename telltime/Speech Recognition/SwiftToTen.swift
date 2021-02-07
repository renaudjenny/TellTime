import Foundation

// TODO: extract this into its own Swift Package

enum SwiftToTen {
    static func recognizeTime(in time: String, calendar: Calendar) -> Date? {
        // Extract basic time recognized by the speech recognizer itself
        // The format will be xx:xx or x:xx, which can be easily extracted by a regex
        // TODO: find a Swifty RegExp lib, this is very hard to read
        guard let extractTimeRegExp = try? NSRegularExpression(
            pattern: "(\\d{1,2}):(\\d{2})",
            options: []
        )
        else { return nil }
        let range = NSRange(location: 0, length: time.utf16.count)
        let matches = extractTimeRegExp.matches(in: time, options: [], range: range)
            .flatMap({ match in
                (1..<match.numberOfRanges).map { rangeIndex -> String? in
                    let captureRange = match.range(at: rangeIndex)
                    let lowerIndex = time.utf16.index(time.startIndex, offsetBy: captureRange.lowerBound)
                    let upperIndex = time.utf16.index(time.startIndex, offsetBy: captureRange.upperBound)
                    return String(time.utf16[lowerIndex..<upperIndex])
                }
            })

        guard matches.count == 2
        else { return nil }

        guard let hourString = matches[0],
              let minuteString = matches[1],
              let hour = Int(hourString),
              let minute = Int(minuteString)
        else { return nil }

        return DateComponents(
            calendar: calendar,
            hour: hour,
            minute: minute
        )
        .date
    }
}
