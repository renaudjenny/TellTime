import UIKit
import NotificationCenter
import SwiftUI
import SwiftPastTen

// SwiftUI for Today Widget:
// https://medium.com/@code_cookies/swiftui-embed-swiftui-view-into-the-storyboard-a6fc96e7a0a1

struct WidgetView: View {
    @Environment(\.calendar) var calendar
    var body: some View {
        HStack {
            Text("🕗")
            Text(time)
            Text("🕗")
        }
    }

    private var currentDate: String {
        let date = Date()
        let minute = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        return fromHour(hour, minute: minute)
    }

    private func fromHour(_ hour: Int, minute: Int) -> String {
        let minute = minute > 9 ? "\(minute)" : "0\(minute)"
        let hour = hour > 9 ? "\(hour)" : "0\(hour)"
        return "\(hour):\(minute)"
    }

    private var time: String {
        guard let time = try? SwiftPastTen().tell(time: currentDate) else {
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

//    TODO: if it's useless, remove it
//    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
//        // Perform any setup necessary in order to update the view.
//
//        // If an error is encountered, use NCUpdateResult.Failed
//        // If there's no update required, use NCUpdateResult.NoData
//        // If there's an update, use NCUpdateResult.NewData
//
//        completionHandler(NCUpdateResult.newData)
//    }
}
