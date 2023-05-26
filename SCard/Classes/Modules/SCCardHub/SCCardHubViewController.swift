import Foundation
import UIKit
import SoraUIKit

final class SCCardHubViewController: UIViewController {

    var onLogout: (() -> Void)?

    private var rootView: SCCardHubView {
        view as! SCCardHubView
    }

    override func loadView() {
        super.loadView()
        view = SCCardHubView()
        modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
    }

    private func binding() {
        rootView.onLogout = { [unowned self] in
            self.onLogout?()
        }
    }
}
