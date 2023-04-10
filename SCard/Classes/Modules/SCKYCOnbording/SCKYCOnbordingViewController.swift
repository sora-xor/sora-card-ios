import UIKit

final class SCKYCOnbordingViewController: UIViewController {

    private let viewModel: SCKYCOnbordingViewModel

    init(viewModel: SCKYCOnbordingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCOnbordingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        title = "KYC Onbording"
        
        viewModel.startKYC()
    }
}
