import Foundation
import UIKit
import SoraUIKit

final class SCKYCCardIssuanceViewController: UIViewController {

    private let viewModel: SCKYCCardIssuanceViewModel

    private var rootView: SCKYCCardIssuanceView {
        view as! SCKYCCardIssuanceView
    }

    init(viewModel: SCKYCCardIssuanceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCCardIssuanceView()
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

        rootView.onLogout = { [unowned viewModel] in
            viewModel.onLogout?()
        }

        rootView.onClose = { [unowned viewModel] in
            viewModel.onClose?()
        }

        rootView.onFreeCard = { [unowned viewModel] in
            viewModel.onFreeCard()
        }

        rootView.onPayForIssueCard = { [unowned self] in
            viewModel.onPayForIssueCard?()
        }

        viewModel.onUpdate = { [weak rootView] data in
            rootView?.configure(data: data)
        }

        viewModel.onGetMoreXor = { [unowned self] in
            self.showGetMoreAlert()
        }
    }

    private func showGetMoreAlert() {

        let alertController = UIAlertController(
            title: R.string.soraCard.detailsGetMoreXor(preferredLanguages: .currentLocale),
            message: "", // TODO: fix design R.string.soraCard.getMoreXorDialogDescription(preferredLanguages: .currentLocale),
            preferredStyle: .actionSheet
        )

        let receiveTitle = R.string.soraCard.getMoreXorDialogDepositOption(preferredLanguages: .currentLocale)
        alertController.addAction(UIAlertAction(title: receiveTitle, style: .default) { [unowned viewModel] _ in
            viewModel.onReceiveXor?()
        })

        let swapTitle = R.string.soraCard.getMoreXorDialogSwapOption(preferredLanguages: .currentLocale)
        alertController.addAction(UIAlertAction(title: swapTitle, style: .default) { [unowned viewModel] _ in
            viewModel.onSwapXor?()
        })

// TODO: Temporary Removal of X1
//        let buyTitle = R.string.soraCard.getMoreXorDialogBuyOption(preferredLanguages: .currentLocale)
//        alertController.addAction(UIAlertAction(title: buyTitle, style: .default) { [unowned viewModel] _ in
//            viewModel.onGetXorWithFiat?()
//        })

        alertController.addAction(UIAlertAction(
            title: R.string.soraCard.commonCancel(preferredLanguages: .currentLocale),
            style: .cancel)
        )
        present(alertController, animated: true)
    }
}
