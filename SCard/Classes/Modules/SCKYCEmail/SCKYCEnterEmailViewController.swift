import Foundation
import UIKit
import SoraUIKit

final class SCKYCEnterEmailViewController: UIViewController {

    private let viewModel: SCKYCEnterEmailViewModel

    private var rootView: SCKYCEnterEmailView {
        view as! SCKYCEnterEmailView
    }

    init(viewModel: SCKYCEnterEmailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCEnterEmailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = R.string.soraCard.enterEmailTitle(preferredLanguages: .currentLocale)
        binding()
    }

    private func binding() {
        rootView.onContinueButton = { [unowned viewModel] in
            viewModel.register(email: self.rootView.inputField.sora.text ?? "")
        }

        viewModel.onError = { [unowned rootView] errorMessage in
            rootView.configure(errorMessage: errorMessage)
        }
    }
}
