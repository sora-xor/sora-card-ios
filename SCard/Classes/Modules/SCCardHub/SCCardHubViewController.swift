import Foundation
import UIKit
import SoraUIKit

final class SCCardHubViewController: UIViewController {

    var onLogout: (() -> Void)?

    private let model: SCCardHubViewModel

    private var rootView: SCCardHubView {
        view as! SCCardHubView
    }

    init(model: SCCardHubViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCCardHubView()
        modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()

        Task {
            let iban = await model.iban()
            await MainActor.run {
                rootView.configure(iban: iban)
            }
        }
    }

    private func binding() {
        rootView.onLogout = { [unowned self] in
            self.onLogout?()
        }

        rootView.onIban = { [unowned self] iban in
            self.share(text: iban)
        }
    }

    private func share(text: String) {
        let activityController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        present(activityController, animated: true, completion: nil)
    }
}
