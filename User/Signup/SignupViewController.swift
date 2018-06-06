import UIKit
import RxSwift
import RxCocoa

import MudoxKit

import JacKit
fileprivate let jack = Jack.with(levelOfThisFile: .verbose)

extension Reactive where Base: UILabel {

  var validationResult: Binder<ValidationResult> {
    return Binder(base) { label, result in
      label.textColor = result.foregroundColor
      label.text = result.message
    }
  }

}

class SignupViewController: UIViewController {

  var disposeBag = DisposeBag()
  var viewModel: SignupViewModel!

  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var usernameLabel: UILabel!

  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var passwordLabel: UILabel!

  @IBOutlet weak var passwordRepeatedField: UITextField!
  @IBOutlet weak var passwordRepeatedLabel: UILabel!

  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSubviews()
    setupViewModel()
  }

  func setupSubviews() {

    usernameLabel.text = ""
    passwordLabel.text = ""
    passwordRepeatedLabel.text = ""

    signupButton.isEnabled = false

    with(registerButton) { b in
      b.setTitleColor(.white, for: .normal)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)), for: .normal)

      b.setTitleColor(.white, for: .disabled)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), for: .disabled)

      b.layer.cornerRadius = 3
      b.layer.masksToBounds = true
    }



  }

  func setupViewModel() {

    let networkService = NetworkService()
    viewModel = SignupViewModel(
      input: (
        username: usernameField.rx.text.orEmpty.asDriver(),
        password: passwordField.rx.text.orEmpty.asDriver(),
        passwordRepeated: passwordRepeatedField.rx.text.orEmpty.asDriver(),
        signupTap: signupButton.rx.tap.asDriver()
      ),
      dependency: (
        networkService: networkService,
        signupService: SignupService(networkService: networkService)
      )
    )

    viewModel.usernameValidation
      .drive(usernameLabel.rx.validationResult)
      .disposed(by: disposeBag)

    viewModel.passwordValidation
      .drive(passwordLabel.rx.validationResult)
      .disposed(by: disposeBag)

    viewModel.passwordRepeatedValidation
      .drive(passwordRepeatedLabel.rx.validationResult)
      .disposed(by: disposeBag)

    viewModel.isSignupEnabled
      .drive(signupButton.rx.isEnabled)
      .disposed(by: disposeBag)

    viewModel.signupResult
      .drive(onNext: { result in
        jack.info("Sign up: \(result)")
      })
      .disposed(by: disposeBag)

    registerButton.rx.bind(to: viewModel.signupAction) { [weak self] _ in
      guard let ss = self else { return ("", "") }
      return (ss.usernameField.text ?? "", ss.passwordField.text ?? "")
    }

    viewModel.signupAction.elements
      .subscribe(onNext: { result in
        jack.info("Register: \(result)")
      })
    .disposed(by: disposeBag)

    viewModel.progressHUD
      .drive(view.mbp.hud)
      .disposed(by: disposeBag)

  }

}
