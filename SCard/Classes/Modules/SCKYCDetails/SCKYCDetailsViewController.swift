import Foundation
import UIKit
import SoraUIKit

final class SCKYCDetailsViewController: UIViewController {

    private let viewModel: SCKYCDetailsViewModel

    private var rootView: SCKYCDetailsView {
        view as! SCKYCDetailsView
    }

    init(viewModel: SCKYCDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCDetailsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        rootView.updateHaveCardButton(isHidden: SCStorage.shared.hasToken())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.refreshBalanceStart()
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.refreshBalanceStop()
        super.viewDidDisappear(animated)
    }

    private func binding() {
        rootView.onIssueCard = { [unowned viewModel] in
            viewModel.onIssueCard?()
        }

        rootView.onGetMoreXor = { [unowned self] in
            self.showGetMoreAlert()
        }

        rootView.onIssueCardForFree = { [unowned self] in
            viewModel.onIssueCardForFree?()
        }

        rootView.onHaveCard = { [unowned viewModel] in
            viewModel.onHaveCard?()
        }

        rootView.onUnsupportedCountries = { [unowned viewModel] in
            viewModel.onUnsupportedCountries?()
        }

        viewModel.onBalanceUpdate = { [weak rootView] (percentage, title, isKYCFree) in
            rootView?.updateBalance(percentage: percentage, title: title, isKYCFree: isKYCFree)
        }
    }

    private func showGetMoreAlert() {
        let alertController = UIAlertController(
            title: "Get more XOR",
            message: "Select a way you want to get XOR",
            preferredStyle: .actionSheet
        )

        alertController.addAction(UIAlertAction(title: "Swap for XOR", style: .default) { [unowned viewModel] _ in
            viewModel.onSwapXor?()
        })

        alertController.addAction(UIAlertAction(title: "Buy XOR with fiat", style: .default) { [unowned viewModel] _ in
            viewModel.onGetXorWithFiat?()
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}
