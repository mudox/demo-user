import RxSwift
import RxCocoa
import RxSwiftExt
import Action

import MudoxKit

import JacKit
fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

struct SignupViewModel {

  let usernameValidation: Driver<ValidationResult>
  let passwordValidation: Driver<ValidationResult>
  let passwordRepeatedValidation: Driver<ValidationResult>

  let isSignupEnabled: Driver<Bool>
  let signupResult: Driver<Bool>
  let signupAction: Action<(String, String), Bool>

  let progressHUD: Driver<MBPCommand>

  init(
    input: (
      username: Driver<String>,
      password: Driver<String>,
      passwordRepeated: Driver<String>,
      signupTap: Driver<Void>
    ),
    dependency: (
      networkService: NetworkService,
      signupService: SignupService
    )
  )
  {
    usernameValidation = input.username
      .debounce(0.5)
      .distinctUntilChanged()
      .flatMapLatest {
        dependency.signupService
          .validateUsername($0)
          .asDriver(onErrorJustReturn: .failure("validation failed"))
          .startWith(.validating)
    }

    passwordValidation = input.password
      .map {
        dependency.signupService
          .validatePassword($0)
    }

    passwordRepeatedValidation = Driver.combineLatest(
      input.password,
      input.passwordRepeated,
      resultSelector: dependency.signupService.validatePasswordRepeated
    )

    isSignupEnabled = Driver.combineLatest(
      usernameValidation,
      passwordValidation,
      passwordRepeatedValidation
    ) { $0.isValid && $1.isValid && $2.isValid }
      .distinctUntilChanged()

    let usernameAndPassword = Driver.combineLatest(input.username, input.password)

    signupResult = input.signupTap.withLatestFrom(usernameAndPassword)
      .flatMapFirst { username, password in
        return dependency.networkService
          .signup(username: username, password: password)
          .track(Activity.signup, by: The.activityCenter)
          .asDriver(onErrorJustReturn: false)
    }

    signupAction = Action(enabledIf: isSignupEnabled.asObservable()) {
      username, password in
      return dependency.networkService
        .signup(username: username, password: password)
        .track(Activity.signupUsingAction, by: The.activityCenter)
    }

    progressHUD = The.activityCenter
      .states(of: .signup)
      .filterMap { state in
        let change: ChangeMBP = { hud in
          hud.margin = 10
          hud.minSize = CGSize(width: 155, height: 100)
        }
        switch state {
        case .start:
          return .map(.start(message: "Signing up ...", extra: change))
        case .next(let result as Bool):
          if result {
            return .map(.success(message: "Signed Up", extra: change))
          } else {
            return .map(.failure(message: "Failed", extra: change))
          }
        default:
          return .ignore
        }
      }
      .asDriver(onErrorJustReturn: .failure(message: "Failed"))
  }

}
