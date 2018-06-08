import Foundation

import RxSwift
import RxCocoa
import RxAlamofire

import MudoxKit

import JacKit
fileprivate let jack = Jack.usingLocalFileScope().setLevel(.verbose)

struct NetworkService {

  // Fake
  func isUsernameAvailable(_ username: String) -> Observable<Bool> {
    return requestData(.head, "https://github.com/\(username.urlEncoded(.urlPathAllowed)!)")
      .map { response, _ in
        return response.statusCode == 404
      }
      .catchErrorJustReturn(false)
      .trackActivity(.isUserNameAvailable)
  }

  // Fake
  func signup(username: String, password: String) -> Observable<Bool> {
    let result = arc4random() % 5 == 0 ? false : true
    return Observable.just(result)
      .delay(1.5, scheduler: MainScheduler.instance)
  }

}
