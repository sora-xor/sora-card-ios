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

        rootView.onUnsupportedCountries = { [unowned viewModel] in
            viewModel.onUnsupportedCountries?()
        }

        viewModel.onBalanceUpdate = { [weak rootView] (percentage, title, isKYCFree, issuanceFee) in
            rootView?.updateBalance(
                percentage: percentage,
                title: title,
                isKYCFree: isKYCFree,
                issuanceFee: issuanceFee
            )
        }
    }

    private func showGetMoreAlert() {
        let alertController = UIAlertController(
            title: R.string.soraCard.detailsGetMoreXor(preferredLanguages: .currentLocale),
            message: R.string.soraCard.getMoreXorDialogDescription(preferredLanguages: .currentLocale),
            preferredStyle: .actionSheet
        )

        let swapTitle = R.string.soraCard.getMoreXorDialogSwapOption(preferredLanguages: .currentLocale)
        alertController.addAction(UIAlertAction(title: swapTitle, style: .default) { [unowned viewModel] _ in
            viewModel.onSwapXor?()
        })

        let buyTitle = R.string.soraCard.getMoreXorDialogBuyOption(preferredLanguages: .currentLocale)
        alertController.addAction(UIAlertAction(title: buyTitle, style: .default) { [unowned viewModel] _ in
            viewModel.onGetXorWithFiat?()
        })

        alertController.addAction(UIAlertAction(
            title: R.string.soraCard.commonCancel(preferredLanguages: .currentLocale),
            style: .cancel)
        )
        present(alertController, animated: true)
    }
}
