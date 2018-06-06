import Foundation

import MudoxKit

enum Activity: ActivityType {
  case isUsernameAvailable
  case signupUsingAction
  case signup
}

extension The {
  static let activityCenter = ActivityTracker<Activity>()
}
