import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 32) {
                developmentCredit
                openSourceCredit
                iconsAndIllustrationsCredit
                Text("Thank you for your support!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
            }
            .layoutPriority(.high)
            Spacer()
        }
        .padding()
        .navigationBarTitle("About")
    }

    private var developmentCredit: some View {
        VStack {
            Text("This application has been made by\nRenaud Jenny")
                .multilineTextAlignment(.center)
                .font(.body)
            WebLink(text: "@Renox0", url: .renox0Twitter)
        }
    }

    private var openSourceCredit: some View {
        VStack {
            Text("Based on open source projects you can find on my GitHub")
                .multilineTextAlignment(.center)
                .font(.body)
            WebLink(text: "https://github.com/renaudjenny", url: .renaudjennyGithub)
        }
    }

    private var iconsAndIllustrationsCredit: some View {
        VStack {
            Text("Icons and illustrations by\nMathilde Seyller")
                .multilineTextAlignment(.center)
                .font(.body)
            WebLink(text: "@MathildeSeyller", url: .myobrielInstagram)
        }
    }
}

struct WebLink: View {
    let text: String
    let url: URL

    var body: some View {
        Button(action: openURL) {
            Text(text)
        }
    }

    private func openURL() {
        UIApplication.shared.open(url)
    }
}

fileprivate extension Double {
  static let high: Double = 100
}

private extension URL {
    static var renox0Twitter: Self {
        guard let url = Self(string: "https://twitter.com/Renox0") else {
            fatalError("Cannot build the Twitter URL")
        }
        return url
    }

    static var renaudjennyGithub: Self {
        guard let url = Self(string: "https://github.com/renaudjenny") else {
            fatalError("Cannot build the Github URL")
        }
        return url
    }

    static var myobrielInstagram: Self {
        guard let url = Self(string: "https://www.instagram.com/myobriel") else {
            fatalError("Cannot build the instagram URL")
        }
        return url
    }
}

#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
    }
}
#endif
