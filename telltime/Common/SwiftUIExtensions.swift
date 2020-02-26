import SwiftUI

// TODO: move this extension to its own file (or simply rename the file)
#if DEBUG
extension PreviewLayout {
  enum Orientation {
    case portrait
    case landscape
  }
  static func iPhoneSe(_ orientation: Orientation) -> Self {
    switch orientation {
    case .portrait: return .fixed(width: 320, height: 568)
    case .landscape: return .fixed(width: 568, height: 320)
    }
  }

  static let iPhoneSe = Self.iPhoneSe(.portrait)
}
#endif
