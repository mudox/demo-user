import Foundation

import RxSwift
import RxCocoa
import RxAlamofire

import MudoxKit


import JacKit
fileprivate let jack = Jack.usingLocalFileScope().setLevel(.verbose)

struct SignupService {

  let minimumPasswordLength = 6

  let networkService: NetworkService

  init(networkService: NetworkService) {
    self.networkService = networkService
  }

  func validateUsername(_ username: String) -> Observable<ValidationState > {
    guard !username.isEmpty else {
      return .just(.empty)
    }

    guard username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil else {
      return .just(.error("User name should contain only alphanumerics"))
    }

    return networkService.isUsernameAvailable(username)
      .map {
        if $0 {
          return .success("The username is available")
        } else {
          return .error("The username already exists")
        }
      }
      .startWith(.inProgress)
  }


  func validatePassword(_ password: String) -> ValidationState  {
    guard !password.isEmpty else {
      return .empty
    }

    guard password.count >= minimumPasswordLength else {
      return .success("Need at least \(minimumPasswordLength) characters")
    }

    return .error("Valid")
  }

  func validateRepeatedPassword(_ password: String, _ passwordRepeated: String) -> ValidationState  {
    guard !passwordRepeated.isEmpty else {
      return .empty
    }

    if passwordRepeated == password {
      return .error("Valid")
    } else {
      return .success("Passwords don't match")
    }

  }

}
