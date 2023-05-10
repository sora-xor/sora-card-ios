import PayWingsOAuthSDK
import PayWingsOnboardingKYC
import SoraUIKit

public class SCard {

    public static var shared: SCard?

    public struct Config {
        public let backendUrl: String
        public let pwAuthDomain: String
        public let pwApiKey: String
        public let kycUrl: String
        public let kycUsername: String
        public let kycPassword: String
        public let environmentType: EnvironmentType
        public let themeMode: SoramitsuThemeMode

        public init(
            backendUrl: String,
            pwAuthDomain: String,
            pwApiKey: String,
            kycUrl: String,
            kycUsername: String,
            kycPassword: String,
            environmentType: EnvironmentType,
            themeMode: SoramitsuThemeMode
        ) {
            self.backendUrl = backendUrl
            self.pwAuthDomain = pwAuthDomain
            self.pwApiKey = pwApiKey
            self.kycUrl = kycUrl
            self.kycUsername = kycUsername
            self.kycPassword = kycPassword
            self.environmentType = environmentType
            self.themeMode = themeMode
        }

        public enum EnvironmentType: String {
            case test
            case prod

            var pwType: PayWingsOAuthSDK.EnvironmentType {
                switch self {
                case .test:
                    return .TEST
                case .prod:
                    return .PRODUCTION
                }
            }
        }
    }

    private let config: Config
    private let coordinator: SCKYCCoordinator
    private let client: SCAPIClient
    private let service: SCKYCService
    private let storage: SCStorage = .shared
    private let address: String

    public init(
        address: String,
        config: Config,
        balanceStream: SCStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void
    ) {
        self.config = config
        self.address = address

        client = .init(baseURL: URL(string: config.backendUrl)!, baseAuth: "", token: .empty, logLevels: .debug)
        service = .init(client: client, config: config)
        coordinator = .init(
            address: address,
            service: service,
            storage: storage,
            balanceStream: balanceStream,
            onSwapController: onSwapController
        )

        Task {
            if SCStorage.shared.isFirstLaunch() {
                await SCStorage.shared.removeToken()
                SCStorage.shared.setAppLaunched()
                service._userStatusStream.wrappedValue = .notStarted
            }
        }
    }

    public func start(in vc: UIViewController) {
        Task { await coordinator.start(in: vc) }
    }

    public func accessToken() async -> String? {
        await storage.token()?.accessToken
    }

    public func removeToken() async {
        await storage.removeToken()
    }

    public var userStatusStream: AsyncStream<SCKYCUserStatus> {
        service.userStatusStream
    }

    public func userStatus() async -> SCKYCUserStatus? {
        await service.userStatus()
    }

    public var isSCBannerHidden: Bool {
        get { storage.isSCBannerHidden() }
        set { storage.set(isHidden: newValue) }
    }

    public func xOneViewController(address: String) -> UIViewController {
        return SCXOneViewController(viewModel: .init(address: address, service: service))
    }
}
