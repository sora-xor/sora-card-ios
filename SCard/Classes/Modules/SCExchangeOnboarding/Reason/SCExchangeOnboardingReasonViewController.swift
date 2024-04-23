import Foundation
import UIKit
import SoraUIKit

final class SCExchangeOnboardingReasonViewController: UIViewController {

    private let viewModel: SCExchangeOnboardingReasonViewModel

    var rootView: SCExchangeOnboardingReasonView {
        view as! SCExchangeOnboardingReasonView
    }

    init(viewModel: SCExchangeOnboardingReasonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCExchangeOnboardingReasonView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Onboarding question 2 of 3"
        binding()
        updateUI()
    }

    private func binding() {
        rootView.onReason = { [unowned self] reason in
            viewModel.handleReason(reason)
            updateUI()
        }

        rootView.onContinue = { [unowned self] in
            viewModel.next()
        }
    }

    private func updateUI() {
        rootView.configure(variants: viewModel.reasons)
    }
}
