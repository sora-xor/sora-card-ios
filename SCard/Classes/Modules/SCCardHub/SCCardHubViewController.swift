import Foundation
import UIKit
import SoraUIKit

final class SCCardHubViewController: UIViewController {

    var onLogout: (() -> Void)?
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

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        binding()
//
//        Task {
//            let iban = await model.iban()
//            let needUpdateApp = await model.needUpdateApp()
//            await MainActor.run {
//                rootView.configure(
//                    iban: iban?.iban,
//                    balance: iban?.availableBalance,
//                    needUpdateApp: needUpdateApp
//                )
//            }
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        binding()

        Task {
            let iban = await model.iban()
            let needUpdateApp = await model.needUpdateApp()
            await MainActor.run {
                rootView.configure(
                    iban: iban?.iban,
                    balance: iban?.availableBalance,
                    needUpdateApp: needUpdateApp
                )
            }
        }
    }

    private func binding() {

        rootView.onClose = { [unowned self] in
            self.dismiss(animated: true)
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
