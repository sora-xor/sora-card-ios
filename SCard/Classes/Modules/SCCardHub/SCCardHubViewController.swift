import Foundation
import UIKit
import SoraUIKit

final class SCCardHubViewController: UIViewController {

    var onLogout: (() -> Void)?
    var onSupport: (() -> Void)?
    var onUpdateApp: (() -> Void)?

    private let model: SCCardHubViewModel

    private var rootView: SCCardHubView {
        view as! SCCardHubView
    }

    init(model: SCCardHubViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCCardHubView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        model.fetchIban()
    }

    private func binding() {

        model.onUpdateUI = { [unowned self] iban, needUpdateApp in
            rootView.configure(
                iban: iban?.iban,
                ibanStatus: iban?.status,
                balance: iban?.availableBalance,
                needUpdateApp: needUpdateApp
            )
        }

        rootView.onClose = { [unowned self] in
            self.dismiss(animated: true)
        }

        rootView.onSupport = { [unowned self] in
            self.onSupport?()
        }

        rootView.onLogout = { [unowned self] in
            self.onLogout?()
        }

        rootView.onIbanShare = { [unowned self] iban in
            self.share(text: iban)
        }

        rootView.onUpdateApp = onUpdateApp
    }

    private func share(text: String) {
        let activityController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        present(activityController, animated: true, completion: nil)
    }
}
