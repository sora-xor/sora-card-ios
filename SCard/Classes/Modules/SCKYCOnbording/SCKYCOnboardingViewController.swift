import UIKit

final class SCKYCOnboardingViewController: UIViewController {

    private let viewModel: SCKYCOnboardingViewModel

    init(viewModel: SCKYCOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCOnboardingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        title = "KYC Onboarding"
        
        viewModel.startKYC()
    }
}
