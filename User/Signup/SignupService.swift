import Foundation

import RxSwift
import RxCocoa
import RxAlamofire

import MudoxKit

import JacKit
fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

struct SignupService {

  let minimumPasswordLength = 6

  let networkService: NetworkService

  init(networkService: NetworkService) {
    self.networkService = networkService
  }

  func validateUsername(_ username: String) -> Observable<ValidationResult> {
    guard !username.isEmpty else {
      return .just(.empty)
    }

    guard username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil else {
      return .just(.failure("User name should contain only alphanumerics"))
    }

    return networkService.isUsernameAvailable(username)
      .map {
        if $0 {
          return .success("The username is available")
        } else {
          return .failure("The username already existed")
        }
      }
      .startWith(.validating)
  }


  func validatePassword(_ password: String) -> ValidationResult {
    guard !password.isEmpty else {
      return .empty
    }

    guard password.count >= minimumPasswordLength else {
      return .failure("Need at least \(minimumPasswordLength) characters")
    }

    return .success("Valid")
  }

  func validatePasswordRepeated(_ password: String, _ passwordRepeated: String) -> ValidationResult {
    guard !passwordRepeated.isEmpty else {
      return .empty
    }

    if passwordRepeated == password {
      return .success("Valid")
    } else {
      return .failure("Passwords don't match")
    }

  }

}
