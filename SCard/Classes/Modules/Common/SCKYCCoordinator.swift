import Foundation
import SafariServices
import UIKit
import SoraUIKit

final class SCKYCCoordinator {

    private let addressProvider: () -> String
    private let service: SCKYCService
    private let storage: SCStorage
    internal var balanceStream: SCStream<Decimal>
    private let onSwapController: (UIViewController) -> Void

    init(
        addressProvider: @escaping () -> String,
        service: SCKYCService,
        storage: SCStorage,
        balanceStream: SCStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void
    ) {
        self.addressProvider = addressProvider
        self.service = service
        self.storage = storage
        self.balanceStream = balanceStream
        self.onSwapController = onSwapController
    }

    private weak var rootViewController: UIViewController?
    private let navigationController: UINavigationController = {
        let navigationVC = SCNavigationViewController()
        navigationVC.navigationBar.backgroundColor = .white
        navigationVC.navigationBar.tintColor = .black
        navigationVC.view.backgroundColor = .white
        return navigationVC
    }()

    func start(in rootViewController: UIViewController) async {
        self.rootViewController = rootViewController
        await MainActor.run {
            navigationController.viewControllers = []
        }

        if await canShowHardhub() {
            await MainActor.run {
                showCardHub()
            }
            return

        } else if await navigationController.presentingViewController == nil {
            await rootViewController.present(navigationController, animated: true)
        }

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
        Task { [weak self] in
            guard let self = self else { return }
            let isXOneWidgetAailable = await self.service.isXOneWidgetAailable()

            await MainActor.run {
                if isXOneWidgetAailable {
                    let viewController = SCXOneViewController(viewModel:
                            .init(address: self.addressProvider(), service: self.service)
                    )
                    self.navigationController.pushViewController(viewController, animated: true)
                } else {
                    let viewController = SCXOneBlockedViewController()
                    viewController.onAction = { [weak self] in
                        self?.navigationController.popViewController(animated: true)
                    }

                    viewController.onUnsupportedCountries = { [weak self] in
                        self?.showUnsupportedCountries()
                    }
                    self.navigationController.pushViewController(viewController, animated: true)
                }
            }
        }
    }

    private func showLogin(data: SCKYCUserDataModel) {

        let viewController = SCKYCLoginViewController()

        viewController.onUnsupportedCountries = { [weak self] in
            self?.showUnsupportedCountries()
        }

        viewController.onLogin = { [weak self] in
            self?.showTermsAndConditions(data: data)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showUnsupportedCountries() {
        show(url: URL(string: "https://soracard.com/blacklist")!)
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
            if data.isEmailSent {
                self.showEnterEmail(data: data)
            } else {
                navigationController.popViewController(animated: true)
            }
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
            let hasIban = await service.hasIban()

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

                    if statusesToShow.sorted.last?.userStatus == .successful, hasIban {
                        self.showCardHub()
                    } else {
                        self.showStatus(data: data)
                    }

                case .failure(let error):
                    print(error)
                    Task { [weak self] in await self?.resetKYC() }
                }
            }
        }
    }

    private func canShowHardhub() async -> Bool {
        _ = await self.service.refreshAccessTokenIfNeeded()
        switch await service.kycStatuses() {
        case .success(let statuses):
            let statusesToShow = statuses.filter({ $0.userStatus != .userCanceled })
            if statusesToShow.sorted.last?.userStatus == .successful {
                return await service.hasIban()
            } else {
                return false
            }
        case .failure(let error):
            print(error)
            return false
        }
    }

    private func showGetPrepared(data: SCKYCUserDataModel){
        let viewModel = SCKYCSummaryViewModel(service: service)
        viewModel.onContinue = { [unowned self] in
            startKYC(data: data)
        }

        let viewController = SCKYCSummaryViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        viewModel.onClose = { [unowned viewController] in
            viewController.navigationController?.dismiss(animated: true)
        }

        viewModel.onLogout = { [weak self, unowned viewController] in
            self?.showLogoutAlert(in: viewController)
        }
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

        viewModel.onLogout = { [weak self] in
            self?.showLogoutAlert(in: viewController)
        }

        viewModel.onSupport = { [weak self] in
            let url = URL(string: "https://t.me/soracardofficial")!
            let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
            self?.navigationController.pushViewController(webViewController, animated: true)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func showCardHub() {

        let viewController = SCCardHubViewController(model: .init(service: service))

        viewController.onLogout = { [weak self] in
            self?.showLogoutAlert(in: viewController)
        }

        let containerView = BlurViewController()
        containerView.modalPresentationStyle = .overFullScreen
        containerView.add(viewController)

        if self.navigationController.presentationController != nil {
            self.navigationController.dismiss(animated: true) { [weak self] in
                self?.rootViewController?.present(containerView, animated: true)
            }
        } else {
            rootViewController?.present(containerView, animated: true)
        }
    }

    private func showLogoutAlert(in viewController: UIViewController) {
        let alertController = UIAlertController(
            title: R.string.soraCard.cardHubSettingsLogoutTitle(preferredLanguages: .currentLocale),
            message: R.string.soraCard.cardHubSettingsLogoutDescription(preferredLanguages: .currentLocale),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: R.string.soraCard.commonCancel(preferredLanguages: .currentLocale), style: .cancel))
        alertController.addAction(
            UIAlertAction(title: R.string.soraCard.cardHubSettingsLogoutButton(preferredLanguages: .currentLocale) , style: .destructive
        ) { [weak self, viewController] _ in
            Task { [weak self] in await self?.storage.removeToken() }
            self?.storage.set(isRety: false)
            self?.service.clearUserKYCState()
            viewController.dismiss(animated: true)
        })
        viewController.present(alertController, animated: true)
    }

    private func retryKYC() async {
        storage.set(isRety: true)

        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.showCardDetails(data: SCKYCUserDataModel())
            self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        }
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
