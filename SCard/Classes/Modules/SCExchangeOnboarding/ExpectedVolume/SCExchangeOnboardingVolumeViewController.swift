import Foundation
import UIKit
import SoraUIKit

final class SCExchangeOnboardingVolumeViewController: UIViewController {

    private let viewModel: SCExchangeOnboardingVolumeViewModel

    var rootView: SCExchangeOnboardingVolumeView {
        view as! SCExchangeOnboardingVolumeView
    }

    init(viewModel: SCExchangeOnboardingVolumeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = SCExchangeOnboardingVolumeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Onboarding question 1 of 3"
        binding()
        configure()
    }

    private func binding() {
        rootView.onVolume = { [unowned self] volume in
            viewModel.volume = volume
            rootView.select(variant: volume)
        }

        rootView.onContinue = { [unowned self] in
            viewModel.next()
        }
    }

    private func configure() {
        let variants = SCExchangeOnboarding.ExpectedVolume.allCases
        rootView.configure(variants: variants, selected: viewModel.volume)
    }
}
