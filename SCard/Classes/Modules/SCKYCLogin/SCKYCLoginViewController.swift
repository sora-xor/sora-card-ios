import Foundation
import UIKit
import SoraUIKit

final class SCKYCLoginViewController: UIViewController {

    var onLogin: (() -> Void)?
    var onUnsupportedCountries: (() -> Void)?

    private var rootView: SCKYCLoginView {
        view as! SCKYCLoginView
    }

    override func loadView() {
        super.loadView()
        view = SCKYCLoginView()
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
