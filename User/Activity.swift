import Foundation

import MudoxKit

enum Activity: ActivityType {
  case isUsernameAvailable
  case signupUsingAction
  case signup
  
  var isNetworkActivity: Bool {
    return true
  }
}

extension The {
  static let activityCenter = ActivityCenter<Activity>()
}
