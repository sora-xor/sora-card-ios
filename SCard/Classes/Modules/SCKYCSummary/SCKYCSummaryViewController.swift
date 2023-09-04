import Foundation
import UIKit
import SoraUIKit

final class SCKYCSummaryViewController: UIViewController {

    private let viewModel: SCKYCSummaryViewModel

    private var rootView: SCKYCSummaryView {
        view as! SCKYCSummaryView
    }

    init(viewModel: SCKYCSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCSummaryView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = R.string.soraCard.getPreparedTitle(preferredLanguages: .currentLocale)
        self.navigationItem.setHidesBackButton(true, animated: false)
        binding()
        Task { await viewModel.getKYCAttempts() }
    }

    private func binding() {
        rootView.onContinueButton = { [unowned viewModel] in
            viewModel.onContinue?()
        }

        viewModel.onAttempts = { [unowned self] attempts in
            self.rootView.configure(attempts: Int(attempts))
        }
    }
}
