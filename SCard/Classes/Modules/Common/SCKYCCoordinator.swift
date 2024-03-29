import Foundation
import SafariServices
import UIKit
import SoraUIKit

final class SCKYCCoordinator {

    private let addressProvider: () -> String
    private let service: SCKYCService
    private let storage: SCStorage
    internal var balanceStream: SCStream<Decimal>
    private let onReceiveController: (UIViewController) -> Void
    private let onSwapController: (UIViewController) -> Void

    init(
        addressProvider: @escaping () -> String,
        service: SCKYCService,
        storage: SCStorage,
        balanceStream: SCStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void,
        onReceiveController: @escaping (UIViewController) -> Void
    ) {
        self.addressProvider = addressProvider
        self.service = service
        self.storage = storage
        self.balanceStream = balanceStream
        self.onSwapController = onSwapController
        self.onReceiveController = onReceiveController
    }

    private weak var rootViewController: UIViewController?
    private let navigationController: UINavigationController = {
        let navigationVC = SCNavigationViewController()
        navigationVC.view.backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgPage)
        let color = SoramitsuUI.shared.theme.palette.color(.fgPrimary)
        navigationVC.navigationBar.titleTextAttributes = [.foregroundColor: color]
        return navigationVC
    }()

    func start(in rootViewController: UIViewController) async {
        storage.set(isHidden: false)
        self.rootViewController = rootViewController

// TODO: Testing showCardIssuance only
//        if await navigationController.presentingViewController == nil {
//            await rootViewController.present(navigationController, animated: true)
//        }
//        await MainActor.run {
//            self.showCardIssuance(data: .init())
//        }
//        return
// TODO: Testing showCardIssuance only

        await MainActor.run {
            navigationController.viewControllers = []
        }

        switch await service.verionsChangesNeeded() {
        case .major, .minor, .patch:
            await showUpdateVersion()
        case .none:
            await openSCard()
        }
    }

    private func openSCard() async {
        // TODO: present loading creeen

        if await canShowHardhub() {
            await MainActor.run {
                showCardHub()
            }
            return

        } else if await navigationController.presentingViewController == nil {
            await rootViewController?.present(navigationController, animated: true)
        }

        let data = await SCKYCUserDataService(service: service).fetchUserData() ?? SCKYCUserDataModel()

        await service.updateFees()

        DispatchQueue.main.async {
            self.service.startKYCStatusRefresher()
        }

        if service.isUserSignIn() {
            checkUserStatus(data: data)
        } else {
            await MainActor.run { [weak self] in
                self?.showLogin(data: data)
            }
        }
    }

    private func showUpdateVersion() async {
        let url = URL(string: service.config.appStoreUrl)!
        let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
        await rootViewController?.present(webViewController, animated: true)
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

    // TODO: remove
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

        viewModel.onReceiveXor = { [weak self] in
            self?.showReceiveController()
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

    private func showCardIssuance(data: SCKYCUserDataModel) {
        let viewModel = SCKYCCardIssuanceViewModel(
            data: data,
            service: service,
            balanceStream: balanceStream
        )

        viewModel.onIssueCardForFree = { [weak self] in
            self?.showTermsAndConditions(data: data)
        }

        viewModel.onPayForIssueCard = {
            print("TODO: impl 20$ pay integration")
        }

        viewModel.onReceiveXor = { [weak self] in
            self?.showReceiveController()
        }

        viewModel.onSwapXor = { [weak self] in
            self?.showSwapController()
        }

        viewModel.onGetXorWithFiat = { [weak self] in
            self?.showXOne()
        }

        let viewController = SCKYCCardIssuanceViewController(viewModel: viewModel)

        viewModel.onLogout = { [weak self, unowned viewController] in
            self?.showLogoutAlert(in: viewController)
        }

        viewModel.onClose = { [unowned viewController] in
            viewController.navigationController?.dismiss(animated: true)
        }

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
            if self?.service.isUserSignIn() ?? false {
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

        viewModel.onCountry = { [unowned self, unowned viewModel] in
            showCountryList() { selectedCountry in
                viewModel.onCountrySelected(selectedCountry)
            }
        }

        viewModel.onContinue = { [unowned self] in
            showEnterPhoneCode(data: data)

        }
        let viewController = SCKYCEnterPhoneViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showCountryList(_ onCountrySelected: @escaping (SCCountry) -> Void) {
        let viewController = SCCountryList(service: service)
        viewController.onCountrySelected = { [unowned self] selectedCountry in
            navigationController.popViewController(animated: true)
            onCountrySelected(selectedCountry)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showEnterPhoneCode(data: SCKYCUserDataModel) {
        let viewModel = SCKYCEnterPhoneCodeViewModel(data: data, service: service)
        viewModel.onUserRegistration = { [unowned self] data in
            showEnterName(data: data)
        }

        viewModel.onSignInSuccessfully = { [unowned self] data in
            checkUserStatus(data: data)
        }

        let viewController = SCKYCEnterPhoneCodeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        viewModel.onEmailVerification = { [unowned self, weak viewController] data in
            showEmailVerification(data: data)
            viewController?.removeFromParent()
        }
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

            await service.updateKycState()
            let isEnoughXor = await SCKYCDetailsViewModel.isEnoughXor(
                xorBalance: self.balanceStream.wrappedValue,
                service: service
            )

            await MainActor.run { [weak self, isEnoughXor] in
                guard let self else { return }

                let kycLastState = self.service.currentUserState
                if kycLastState.verificationStatus == .accepted {
                    self.showCardHub()
                    return
                }

                switch kycLastState.kycStatus {

                case .notStarted, .none:
                    if isEnoughXor {
                        self.showGetPrepared(data: data)
                    } else {
                        self.showCardIssuance(data: data)
                    }
                case .started, .failed:
                    self.showGetPrepared(data: data)

                case .completed, .retry, .rejected:
                    if self.storage.isKYCRety() {
                        self.showGetPrepared(data: data)
                    } else {
                        self.showStatus(data: data)
                    }

                case .successful:
                    () // handled earyer verificationStatus == .accepted
                }
            }
        }
    }

    private func canShowHardhub() async -> Bool {
        if service.currentUserState.userStatus == .none {
            await service.updateKycState()
        }
        return service.currentUserState.userStatus == .successful
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
            self?.showSupport()
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func showCardHub() {

        let viewController = SCCardHubViewController(model: .init(service: service))

        viewController.onLogout = { [weak self, weak viewController] in
            guard let viewController = viewController else { return }
            self?.showLogoutAlert(in: viewController)
        }
        viewController.onSupport = { [weak viewController] in
            let url = URL(string: "https://t.me/soracardofficial")!
            let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
            viewController?.present(webViewController, animated: true)
        }
        viewController.onUpdateApp = { [weak self, weak viewController] in
            guard let self = self else { return }
            let url = URL(string: self.service.config.appStoreUrl)!
            let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
            viewController?.present(webViewController, animated: true)
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

    private func showSupport() {
        let url = URL(string: "https://t.me/soracardofficial")!
        let webViewController = WebViewFactory.createWebViewController(for: url, style: .automatic)
        navigationController.pushViewController(webViewController, animated: true)
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
            self?.service.logout()
            self?.storage.set(isRety: false)
            viewController.dismiss(animated: true)
        })
        viewController.present(alertController, animated: true)
    }

    private func retryKYC() async {
        storage.set(isRety: true)

        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.showGetPrepared(data: .init())
            self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        }
    }

    private func resetKYC() async {

        storage.set(isRety: false)
        service.logout()

        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.showGetPrepared(data: .init())
            self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        }
    }

    private func showReceiveController() {
        onReceiveController(navigationController)
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
