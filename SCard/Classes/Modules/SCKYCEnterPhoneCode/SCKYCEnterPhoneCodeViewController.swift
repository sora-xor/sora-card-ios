import Foundation
import UIKit
import SoraUIKit

final class SCKYCEnterPhoneCodeViewController: UIViewController {

    private let viewModel: SCKYCEnterPhoneCodeViewModel

    var rootView: SCKYCEnterPhoneCodeView {
        view as! SCKYCEnterPhoneCodeView
    }

    init(viewModel: SCKYCEnterPhoneCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCEnterPhoneCodeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = R.string.soraCard.verifyPhoneNumberTitle(preferredLanguages: .currentLocale)
        rootView.inputField.textField.becomeFirstResponder()
        binding()
        configure()
    }

    private func binding() {
        rootView.onResendButton = { [unowned self] in
            viewModel.data.lastPhoneOTPSentDate = Date()
            configure()
        }

        rootView.onCode = { [unowned self] code in
            // TODO: add throtling using asyncDebounce
            viewModel.check(code: code)
            configure()
        }

        viewModel.onUpdateUI = { [unowned self] in
            configure()
        }
    }

    private func configure() {
        DispatchQueue.main.async {
            self.rootView.configure(
                phoneNumber: self.viewModel.data.phoneNumber,
                secondsLeft: self.viewModel.data.secondsLeftForPhoneOTP,
                codeState: self.viewModel.codeState
            )
        }
    }
}
