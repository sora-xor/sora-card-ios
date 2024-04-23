import UIKit
import SoraUIKit

class SCExchangeOnboardingCoordinator {

    private let service: SCExchangeService

    private let onboardingModel = SCExchangeOnboardingModel()

    private weak var rootViewController: UIViewController?

    private let navigationController: UINavigationController = {
        let navigationVC = SCNavigationViewController()
        navigationVC.view.backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgPage)
        let color = SoramitsuUI.shared.theme.palette.color(.fgPrimary)
        navigationVC.navigationBar.titleTextAttributes = [.foregroundColor: color]
        return navigationVC
    }()

    init(service: SCExchangeService) {
        self.service = service
    }

    @MainActor
    func start(in rootViewController: UIViewController) {
        self.rootViewController = rootViewController

        rootViewController.present(navigationController, animated: true)
        // TODO: check if user unboarded

        showOnboardingVolume()
    }

    @MainActor
    private func showOnboardingVolume() {

        guard navigationController.viewControllers.isEmpty else { return }
        navigationController.startLoader()
        let model = SCExchangeOnboardingVolumeViewModel(service: service, volume: onboardingModel.volume)
        model.onContinue = { [weak self] volume in
            self?.onboardingModel.volume = volume
            self?.showOnboardingReason()
        }
        let viewController = SCExchangeOnboardingVolumeViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
        navigationController.stopLoader()
    }

    @MainActor
    private func showOnboardingReason() {
        let model = SCExchangeOnboardingReasonViewModel(service: service, model: onboardingModel)
        model.onContinue = { [weak self] in
            self?.showOnboardingSource()
        }
        let viewController =  SCExchangeOnboardingReasonViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
    }

    @MainActor
    private func showOnboardingSource() {
        let model = SCExchangeOnboardingSourceViewModel(service: service, model: onboardingModel)
        model.onContinue = { [weak self] in
            print("Todo")
        }
        let viewController =  SCExchangeOnboardingSourceViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
    }
}
