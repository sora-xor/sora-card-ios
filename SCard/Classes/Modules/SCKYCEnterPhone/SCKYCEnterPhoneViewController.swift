import Foundation
import UIKit
import SoraUIKit

final class SCKYCEnterPhoneViewController: UIViewController {

    private let viewModel: SCKYCEnterPhoneViewModel

    private var rootView: SCKYCEnterPhoneView {
        view as! SCKYCEnterPhoneView
    }

    init(viewModel: SCKYCEnterPhoneViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCEnterPhoneView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = R.string.soraCard.verifyPhoneNumberTitle(preferredLanguages: .currentLocale)
        binding()
        viewModel.setupCrrentCountry()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootView.inputField.textField.becomeFirstResponder()
    }

    private func binding() {

        rootView.onCountry = { [unowned viewModel] in
            viewModel.onCountry?()
        }

        rootView.onContinueButton = { [unowned viewModel] in
            viewModel.signIn()
        }

        rootView.onInput = { [unowned viewModel] text in
            viewModel.onInput(text: text)
        }

        viewModel.onUpdateUI = { [unowned self] errorMessage, isContinueEnabled in
            rootView.configure(errorMessage: errorMessage, isContinueEnabled: isContinueEnabled)
        }

        viewModel.onUpdateCountry = { [unowned self] country in
            rootView.configure(country: country)
        }
    }
}
