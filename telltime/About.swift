import SwiftUI

struct About: View {
  var body: some View {
    VStack {
      Spacer()
      VStack(spacing: 32) {
        Text("This application has been made by\nRenaud Jenny. @Renox0")
          .multilineTextAlignment(.center)
          .font(.body)
        Text("Based on open source projects you can find on my GitHub:\nhttps://github.com/renaudjenny")
          .multilineTextAlignment(.center)
          .font(.body)
        Text("Icons and illustrations by\nMathilde Seyller. @MathildeSeyller")
          .multilineTextAlignment(.center)
          .font(.body)
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
}

fileprivate extension Double {
  static let high: Double = 100
}

struct About_Previews: PreviewProvider {
  static var previews: some View {
    About()
  }
}
