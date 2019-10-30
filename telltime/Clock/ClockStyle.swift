enum ClockStyle: Identifiable, CaseIterable {
  case classic
  case artNouveau

  var description: String {
    switch self {
    case .classic: return "Classic"
    case .artNouveau: return "Art Nouveau"
    }
  }

  var id: Int {
    switch self {
    case .classic: return 0
    case .artNouveau: return 1
    }
  }
}
