import UIKit

enum ValidationResult {
  case validating
  case empty
  case success(String)
  case failure(String)
}

extension ValidationResult {
  var isValid: Bool {
    if case .success = self {
      return true
    } else {
      return false
    }
  }

  var message: String {
    switch self {
    case .validating:
      return "Validating ..."
    case .empty:
      return ""
    case let .success(message):
      return message
    case let .failure(message):
      return message
    }
  }
  
  var foregroundColor: UIColor {
    switch self {
    case .validating:
      return .gray
    case .empty:
      return .black
    case .success:
      return UIColor(displayP3Red: 0, green: 130 / 255, blue: 0, alpha: 1)
    case .failure:
      return .red
    }
  }
  
}
