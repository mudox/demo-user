import UIKit

import RxSwift
import RxCocoa

import MudoxKit

import JacKit
fileprivate let jack = Jack.usingLocalFileScope().setLevel(.verbose)

extension Reactive where Base: UILabel {

  var validationResult: Binder<ValidationState > {
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
  @IBOutlet weak var registeringIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupViewModel()

    usernameField.rx.controlEvent(.editingDidBegin).asDriver()
      .drive(onNext: {
        jack.debug("did begin")
      })
      .disposed(by: disposeBag)
    usernameField.rx.controlEvent(.editingDidEnd).asDriver()
      .drive(onNext: {
        jack.debug("did end")
      })
      .disposed(by: disposeBag)
    usernameField.rx.controlEvent(.editingDidEndOnExit).asDriver()
      .drive(onNext: {
        jack.debug("did end on exit")
      })
      .disposed(by: disposeBag)

  }

  func setupView() {

    usernameLabel.text = ""
    passwordLabel.text = ""
    passwordRepeatedLabel.text = ""

    with(signupButton) { b in
      b.isEnabled = false

      b.setTitleColor(.white, for: .normal)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), for: .normal)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)), for: .selected)

      b.setTitleColor(.white, for: .disabled)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), for: .disabled)

      b.layer.cornerRadius = 3
      b.layer.masksToBounds = true
    }

    with(registerButton) { b in
      b.isEnabled = false

      b.setTitleColor(.white, for: .normal)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)), for: .normal)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)), for: .highlighted)

      b.setTitleColor(.white, for: .disabled)
      b.setBackgroundImage(UIImage.mdx.color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), for: .disabled)

      b.layer.cornerRadius = 3
      b.layer.masksToBounds = true
    }

  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  func setupViewModel() {

    viewModel = SignupViewModel(
      input: (
        username: usernameField.rx.text.orEmpty.asDriver(),
        password: passwordField.rx.text.orEmpty.asDriver(),
        passwordRepeated: passwordRepeatedField.rx.text.orEmpty.asDriver(),
        signupTap: signupButton.rx.tap.asDriver()
      ),
      dependency: (
        networkService: NetworkService.shared,
        signupService: SignupService(networkService: NetworkService.shared)
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

    viewModel.signupAction.executing
      .bind(to: registeringIndicator.rx.isAnimating)
      .disposed(by: disposeBag)

    viewModel.progressHUD
      .drive(view.mbp.hud)
      .disposed(by: disposeBag)

  }

}
