import Foundation
import UIKit
import SoraUIKit

final class SCExchangeOnboardingSourceViewController: UIViewController {

    private let viewModel: SCExchangeOnboardingSourceViewModel

    var rootView: SCExchangeOnboardingSourceView {
        view as! SCExchangeOnboardingSourceView
    }

    init(viewModel: SCExchangeOnboardingSourceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCExchangeOnboardingSourceView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Onboarding question 3 of 3"
        binding()
        updateUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func binding() {
        rootView.onSource = { [unowned self] source in
            viewModel.handleSource(source)
            updateUI()
        }

        rootView.onContinue = { [unowned self] in
            viewModel.processOnboarding()
        }

        viewModel.onError = { [weak self] errorMessage in
            self?.updateUI(errorMessage: errorMessage)
        }
    }

    private func updateUI(errorMessage: String? = nil) {
        DispatchQueue.main.async {
            self.rootView.configure(variants: self.viewModel.sources)
            guard let errorMessage = errorMessage else { return }
            self.rootView.configure(errorMessage: errorMessage)
        }
    }
}
