import Foundation
import SafariServices
import UIKit
import SoraUIKit

final class SCKYCCoordinator {

    private let address: String
    private let service: SCKYCService
    private let storage: SCStorage
    private let balanceStream: SCStream<Decimal>
    private let onSwapController: (UIViewController) -> Void

    init(
        address: String,
        service: SCKYCService,
        storage: SCStorage,
        balanceStream: SCStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void
    ) {
        self.address = address
        self.service = service
        self.storage = storage
        self.balanceStream = balanceStream
        self.onSwapController = onSwapController
    }

    private let navigationController: UINavigationController = {
        let navigationVC = UINavigationController()
        navigationVC.navigationBar.backgroundColor = .white
        navigationVC.navigationBar.tintColor = .black
        navigationVC.view.backgroundColor = .white
        return navigationVC
    }()

    func start(in rootViewController: UIViewController) async {
        await MainActor.run {
            navigationController.viewControllers = []
        }

        await rootViewController.present(navigationController, animated: true)
        let data = SCKYCUserDataModel()

        DispatchQueue.main.async {
            self.service.startKYCStatusRefresher()
        }

        if storage.hasToken(),
           await self.service.refreshAccessTokenIfNeeded()
        {
            checkUserStatus(data: data)
        } else {
            await MainActor.run { [weak self] in
                self?.showLogin(data: data)
            }
        }
    }

    private func showXOne() {
        let viewController = SCXOneViewController(viewModel: .init(address: address, service: service))
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showLogin(data: SCKYCUserDataModel) {

        let viewController = SCKYCLoginViewController()

        viewController.onUnsupportedCountries = { [weak self] in
            self?.show(url: URL(string: "https://soracard.com/blacklist")!)
        }

        viewController.onLogin = { [weak self] in
            self?.showTermsAndConditions(data: data)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func showCardDetails(data: SCKYCUserDataModel) {
        let viewModel = SCKYCDetailsViewModel(
            data: data,
            service: service,
            balanceStream: balanceStream
        )

        viewModel.onIssueCardForFree = { [weak self] in
            self?.showTermsAndConditions(data: data)
        }

        viewModel.onHaveCard = { [weak self] in
            self?.showTermsAndConditions(data: data)
        }

        viewModel.onIssueCard = {
            print("TODO: 12$ pay integration")
        }

        viewModel.onSwapXor = { [weak self] in
            self?.showSwapController()
        }

        viewModel.onGetXorWithFiat = { [weak self] in
            self?.showXOne()
        }

        viewModel.onUnsupportedCountries = { [weak self] in
            self?.show(url: URL(string: "https://soracard.com/blacklist")!)
        }

        let viewController = SCKYCDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showTermsAndConditions(data: SCKYCUserDataModel) {
        let viewModel = SCTermsConditionsViewModel()
        let viewController = SCTermsConditionsViewController(viewModel: viewModel)

        viewModel.onBlacklistedCountries = { [weak self] in
            self?.show(url: URL(string: "https://soracard.com/blacklist")!)
        }

        viewModel.onGeneralTerms = { [weak self] in
            self?.show(url: URL(string: "https://soracard.com/terms/")!)
        }

        viewModel.onPrivacy = { [weak self] in
            self?.show(url: URL(string: "https://soracard.com/privacy/")!)
        }

        viewModel.onAccept = { [weak self] in
            if self?.storage.hasToken() ?? false {
                self?.checkUserStatus(data: data)
            } else {
                self?.showEnterPhone(data: data)
            }
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func show(url: URL) {
        let request = URLRequest(url: url)
        let webViewController = WebViewController(
            configuration: .init(),
            request: request
        )
        navigationController.pushViewController(webViewController, animated: true)
    }

    private func showEnterPhone(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterPhoneViewModel(service: service, data: data)
        viewModel.onContinue = { [unowned self] in
            showEnterPhoneCode(data: data)

        }
        let viewController = SCKYCEnterPhoneViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showEnterPhoneCode(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterPhoneCodeViewModel(data: data, service: service)
        viewModel.onUserRegistration = { [unowned self] data in
            showEnterName(data: data)
        }

        viewModel.onEmailVerification = { [unowned self] data in
            showEmailVerification(data: data)
        }

        viewModel.onSignInSuccessful = { [unowned self] data in
            checkUserStatus(data: data)
        }

        let viewController = SCKYCEnterPhoneCodeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showEnterName(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterNameViewModel(data: data)
        viewModel.onContinue = { [unowned self] data in
            showEnterEmail(data: data)

        }
        let viewController = SCKYCEnterNameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showEnterEmail(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterEmailViewModel(data: data, service: service)
        viewModel.onContinue = { [unowned self] data in
            showEmailVerification(data: data)
        }
        let viewController = SCKYCEnterEmailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showEmailVerification(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterEmailCodeViewModel(data: data, service: service)
        viewModel.onContinue = { [unowned self] data in
            checkUserStatus(data: data)
        }

        viewModel.onChangeEmail = { [unowned self] in
            // TODO: SC add change email api
            navigationController.popViewController(animated: true)
        }
        
        let viewController = SCKYCEnterEmailCodeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func checkUserStatus(data: SCKYCUserDataModel) {
        Task {
            var hasFreeAttempts = false
            if case .success(let atempts) = await service.kycAttempts() {
                hasFreeAttempts = atempts.hasFreeAttempts
            }
            let response = await service.kycStatuses()
            await MainActor.run { [weak self, hasFreeAttempts] in
                guard let self else { return }
                switch response {
                case .success(let statuses):
                    let statusesToShow = statuses.filter({ $0.userStatus != .userCanceled })
                    if statusesToShow.isEmpty || self.storage.isKYCRety() && hasFreeAttempts {
                        if data.haveEnoughXor {
                            self.showGetPrepared(data: data)
                        } else {
                            self.showCardDetails(data: data)
                            if let last = self.navigationController.viewControllers.last {
                                self.navigationController.viewControllers = [last]
                            }
                        }
                        return
                    }
                    self.showStatus(data: data)
                case .failure(let error):
                    print(error)
                    Task { [weak self] in await self?.resetKYC() }
                }
            }
        }
    }

    private func showGetPrepared(data: SCKYCUserDataModel){
        let viewModel = SCKYCSummaryViewModel()
        viewModel.onContinue = { [unowned self] in
            startKYC(data: data)
        }
        let viewController = SCKYCSummaryViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func startKYC(data: SCKYCUserDataModel) {
        let viewModel = SCKYCOnbordingViewModel(data: data, service: service, storage: storage)
        viewModel.onContinue = { [unowned self] data in
            showStatus(data: data)
        }
        let viewController = SCKYCOnbordingViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        storage.set(isRety: false)
    }

    private func showStatus(data: SCKYCUserDataModel) {
        let viewModel = SCKYCStatusViewModel(data: data, service: service)

        let viewController = SCKYCStatusViewController(viewModel: viewModel)

        viewModel.onClose = { [unowned viewController] in
            viewController.navigationController?.dismiss(animated: true)
        }

        viewModel.onRetry = { [weak self] in
            Task { [weak self] in await self?.retryKYC() }
        }

        viewModel.onReset = { [weak self] in
            Task { [weak self] in await self?.resetKYC() }
        }

        viewModel.onSupport = { [weak self] in
            let url = URL(string: "https://t.me/SORAhappiness")!
            let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
            self?.navigationController.pushViewController(webViewController, animated: true)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func retryKYC() async {
        await resetKYC()
        storage.set(isRety: true)
    }

    private func resetKYC() async {
        await storage.removeToken()
        storage.set(isRety: false)

        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.showCardDetails(data: SCKYCUserDataModel())
            self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        }
    }

    private func showSwapController() {
        onSwapController(navigationController)
    }
}

enum WebPresentableStyle {
    case automatic
    case modal
}

final class WebViewFactory {
    static func createWebViewController(for url: URL, style: WebPresentableStyle) -> UIViewController {
        let webController = SFSafariViewController(url: url)
        webController.preferredControlTintColor = .black
        webController.preferredBarTintColor = .white

        switch style {
        case .modal:
            webController.modalPresentationStyle = .overFullScreen
        default:
            break
        }

        return webController
    }
}
