import PayWingsOAuthSDK
import PayWingsOnboardingKYC
import SoraUIKit

public class SCard {

    static let minXorAmount = "100"
    static let issuanceFee = "20"

    public static var shared: SCard?

    internal let service: SCKYCService
    private let config: Config
    private let coordinator: SCKYCCoordinator
    private let client: SCAPIClient
    private let storage: SCStorage = .shared
    private let addressProvider: () -> String

    public struct Config {
        public let backendUrl: String
        public let pwAuthDomain: String
        public let pwApiKey: String
        public let kycUrl: String
        public let kycUsername: String
        public let kycPassword: String
        public let xOneEndpoint: String
        public let xOneId: String
        public let environmentType: EnvironmentType
        public let themeMode: SoramitsuThemeMode

        public init(
            backendUrl: String,
            pwAuthDomain: String,
            pwApiKey: String,
            kycUrl: String,
            kycUsername: String,
            kycPassword: String,
            xOneEndpoint: String,
            xOneId: String,
            environmentType: EnvironmentType,
            themeMode: SoramitsuThemeMode
        ) {
            self.backendUrl = backendUrl
            self.pwAuthDomain = pwAuthDomain
            self.pwApiKey = pwApiKey
            self.kycUrl = kycUrl
            self.kycUsername = kycUsername
            self.kycPassword = kycPassword
            self.xOneEndpoint = xOneEndpoint
            self.xOneId = xOneId
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

    public init(
        addressProvider: @escaping () -> String,
        config: Config,
        balanceStream: SCStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void
    ) {
        self.config = config
        self.addressProvider = addressProvider

        client = .init(baseURL: URL(string: config.backendUrl)!, baseAuth: "", token: .empty, logLevels: .debug)
        service = .init(client: client, config: config)
        coordinator = .init(
            addressProvider: addressProvider,
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
            } else {
                _ = await service.kycStatuses()
            }
        }
    }

    public var selectedLocalization: String = "en" {
        didSet {
            LocalizationManager.shared.selectedLocalization = selectedLocalization
        }
    }

    public func updateBalance(stream: SCStream<Decimal>) {
        coordinator.balanceStream = stream
    }

    public func start(in vc: UIViewController) {
        Task { await coordinator.start(in: vc) }
    }

    func set(token: SCToken) {
        client.set(token: token)
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

    public var configuration: String {
        config.debugDescription
    }
}

extension SCard.Config: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        SCard.Config
        backendUrl: \(backendUrl)
        pwAuthDomain: \(pwAuthDomain)
        pwApiKey: \(pwApiKey)
        kycUrl: \(kycUrl)
        kycUsername: \(kycUsername)
        kycPassword: \(kycPassword)
        xOneEndpoint: \(xOneEndpoint)
        xOneId: \(xOneId)
        environmentType: \(environmentType)
        themeMode: \(themeMode)
        """
    }
}
