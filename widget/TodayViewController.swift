import UIKit
import NotificationCenter
import SwiftUI
import SwiftPastTen
import SwiftClockUI

// SwiftUI for Today Widget:
// https://medium.com/@code_cookies/swiftui-embed-swiftui-view-into-the-storyboard-a6fc96e7a0a1

struct WidgetView: View {
    @Environment(\.calendar) var calendar

    var body: some View {
        HStack {
            ClockView().allowsHitTesting(false)
            Spacer()
            Text(time)
            Spacer()
        }.padding()
    }

    private var time: String {
        let  formattedDate = SwiftPastTen.formattedDate(Date(), calendar: calendar)
        guard let time = try? SwiftPastTen().tell(time: formattedDate) else {
            return "Error"
        }
        return time
    }
}

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBSegueAction func addSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        let viewController = UIHostingController(coder: coder, rootView: WidgetView())
        viewController?.view.backgroundColor = .clear
        return viewController
    }
}
