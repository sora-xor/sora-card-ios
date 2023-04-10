import PayWingsOAuthSDK
import PayWingsOnboardingKYC
import SoraUIKit

public class SCard {

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

    public init(
        address: String,
        config: Config,
        balanceStream: AsyncStream<Decimal>,
        onSwapController: @escaping (UIViewController) -> Void
    ) {

        self.config = config
        client = .init(baseURL: URL(string: config.backendUrl)!, baseAuth: "", token: .empty, logLevels: .debug)
        service = .init(client: client, config: config)
        coordinator = .init(
            address: address,
            service: service,
            storage: storage,
            balanceStream: balanceStream,
            onSwapController: onSwapController
        )
    }

    public func start(in vc: UIViewController) {
        Task { await coordinator.start(in: vc) }
    }

    public func resetState() {
        Task {
            await storage.removeToken()
            storage.set(isRety: false)
        }
    }
}
