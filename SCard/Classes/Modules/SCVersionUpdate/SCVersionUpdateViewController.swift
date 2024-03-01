import Foundation
import UIKit
import SoraUIKit

final class SCVersionUpdateViewController: UIViewController {

    var onUpdate: (() -> Void)?
    var onSkip: (() -> Void)?

    private let service: SCKYCService

    private var rootView: SCVersionUpdateView {
        view as! SCVersionUpdateView
    }

    init(
        service: SCKYCService,
        onUpdate: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil
    ) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
        self.onUpdate = onUpdate
        self.onSkip = onSkip
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCKYCLoginView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await rootView.configure(versionChange: service.verionsChangesNeeded())
        }
        binding()
    }

    private func binding() {
        rootView.onUpdate = { [unowned self] in
            self.onUpdate?()
        }

        rootView.onSkip = { [unowned self] in
            self.onSkip?()
        }
    }
}
