import Foundation
import UIKit
import SoraUIKit

final class SCKYCStatusViewController: UIViewController {

    private let viewModel: SCKYCStatusViewModel

    private var rootView: SCKYCStatusView {
        view as! SCKYCStatusView
    }

    init(viewModel: SCKYCStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCStatusView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        binding()

        Task {
            await viewModel.getKYCStatus()
        }
    }

    private func binding() {
        rootView.onCloseButton = { [unowned viewModel] in
            DispatchQueue.main.async {
                viewModel.onClose?()
            }
        }

        rootView.onRetryButton = { [unowned viewModel] in
            DispatchQueue.main.async {
                viewModel.onRetry?()
            }
        }

        rootView.onLogoutButton = { [unowned viewModel] in
            DispatchQueue.main.async {
                viewModel.onReset?()
            }
        }

        rootView.onSupportButton = { [unowned viewModel] in
            DispatchQueue.main.async {
                viewModel.onSupport?()
            }
        }

        viewModel.onError = { [unowned rootView] error in
            DispatchQueue.main.async {
                rootView.configure(error: error)
            }
        }

        viewModel.onStatus = { [unowned rootView] status, hasFreeAttemts in
            DispatchQueue.main.async {
                rootView.configure(state: status, hasFreeAttemts: hasFreeAttemts)
            }
        }
    }
}
