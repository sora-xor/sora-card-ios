import Foundation
import UIKit
import SoraUIKit

final class LoginViewController: UIViewController {

    var onLogin: (() -> Void)?
    var onUnsupportedCountries: (() -> Void)?

    private var rootView: LoginView {
        view as! LoginView
    }

    override func loadView() {
        super.loadView()
        view = LoginView()
        title = R.string.soraCard.statusNotStarted(preferredLanguages: .currentLocale)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
    }

    private func binding() {
        rootView.onLogin = { [unowned self] in
            self.onLogin?()
        }

        rootView.onUnsupportedCountries = { [unowned self] in
            self.onUnsupportedCountries?()
        }
    }
}
