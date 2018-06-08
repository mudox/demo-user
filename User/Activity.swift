import MudoxKit

extension Activity {

  public static let isUserNameAvailable = Activity(
    identifier: "isUserNameAvailable",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnbaled: false
  )

  public static let signupUsingAction = Activity(
    identifier: "signupUsingAction",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnbaled: false
  )

  public static let signup = Activity(
    identifier: "signup",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnbaled: false
  )

}
