import UIKit
import SoraUIKit

class ExchangeOnboardingCoordinator {

    private let service: ExchangeService

    private let onboardingModel = ExchangeOnboardingModel()

    private weak var rootViewController: UIViewController?

    private let navigationController: UINavigationController = {
        let navigationVC = SCNavigationViewController()
        navigationVC.view.backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgPage)
        let color = SoramitsuUI.shared.theme.palette.color(.fgPrimary)
        navigationVC.navigationBar.titleTextAttributes = [.foregroundColor: color]
        return navigationVC
    }()

    init(service: ExchangeService) {
        self.service = service
    }

    @MainActor
    func start(in rootViewController: UIViewController) {
        self.rootViewController = rootViewController

        navigationController.viewControllers = []

        rootViewController.present(navigationController, animated: true)
        navigationController.startLoader()

        Task {
            switch await service.onboarded() {
            case .success(let response):
                guard let response = response else { return }
                navigationController.stopLoader()
                if response.onboarded {
                    showExchange()
                } else {
                    showOnboardingVolume()
                }

            case .failure(let error):
                print(error.localizedDescription)
                navigationController.stopLoader()
                navigationController.dismiss(animated: true)
            }
        }
    }

    @MainActor
    private func showOnboardingVolume() {

        guard navigationController.viewControllers.isEmpty else { return }
        navigationController.startLoader()
        let model = ExchangeOnboardingVolumeViewModel(service: service, volume: onboardingModel.volume)
        model.onContinue = { [weak self] volume in
            self?.onboardingModel.volume = volume
            self?.showOnboardingReason()
        }
        let viewController = ExchangeOnboardingVolumeViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
        navigationController.stopLoader()
    }

    @MainActor
    private func showOnboardingReason() {
        let model = ExchangeOnboardingReasonViewModel(service: service, model: onboardingModel)
        model.onContinue = { [weak self] in
            self?.showOnboardingSource()
        }
        let viewController =  ExchangeOnboardingReasonViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
    }

    @MainActor
    private func showOnboardingSource() {
        let model = ExchangeOnboardingSourceViewModel(service: service, model: onboardingModel)
        model.onContinue = { [weak self] in
            DispatchQueue.main.async {
                self?.showExchange()
            }
        }
        let viewController =  ExchangeOnboardingSourceViewController(viewModel: model)
        navigationController.pushViewController(viewController, animated: true)
    }

    @MainActor
    private func showExchange() {
        navigationController.startLoader()
        Task { [weak self] in
            let result = await self?.service.userIframe(type: .deposit)
            await MainActor.run { self?.navigationController.stopLoader() }
            switch result {
            case .success(let response):
                guard let urlStr = response?.url, let url = URL(string: urlStr) else {
                    self?.showAlert(
                        title: R.string.soraCard.commonErrorGeneralTitle(),
                        message: response?.statusDescription ?? ""
                    )
                    return
                }
                await MainActor.run {
                    self?.show(url: url)
                }
            case .failure(let error):
                self?.showAlert(
                    title: R.string.soraCard.commonErrorGeneralTitle(),
                    message: error.localizedDescription
                )
            case .none:
                ()
            }
        }
    }

    @MainActor
    private func show(url: URL) {
        let request = URLRequest(url: url)
        let webViewController = WebViewController(
            configuration: .init(),
            request: request
        )
        navigationController.pushViewController(webViewController, animated: true)
    }


    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            .init(
                title: R.string.soraCard.commonClose(preferredLanguages: .currentLocale),
                style: .cancel,
                handler: { [weak self] _ in
                    self?.navigationController.dismiss(animated: true)
                }
            )
        )
        (navigationController.topViewController ?? navigationController).present(alert, animated: true)
    }
}
