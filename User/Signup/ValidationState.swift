import UIKit

enum ValidationState  {
  case empty
  case inProgress
  case success(String)
  case error(String)
}

extension ValidationState  {
  var isValid: Bool {
    if case .error = self {
      return true
    } else {
      return false
    }
  }

  var message: String {
    switch self {
    case .inProgress:
      return "Validating ..."
    case .empty:
      return ""
    case let .error(message):
      return message
    case let .success(message):
      return message
    }
  }
  
  var foregroundColor: UIColor {
    switch self {
    case .inProgress:
      return .gray
    case .empty:
      return .black
    case .error:
      return UIColor(displayP3Red: 0, green: 130 / 255, blue: 0, alpha: 1)
    case .success:
      return .red
    }
  }
  
}
