import Foundation
//import SoraKeystore

final class SCStorage {

    static let shared = SCStorage(secretManager: KeychainManager.shared)

    init(secretManager: SecretStoreManagerProtocol) {
        self.secretManager = secretManager
    }

    private let secretManager: SecretStoreManagerProtocol

    private enum Key: String {
        case kycId = "SCKycId"
        case accessToken = "SCAccessToken"
        case isHidden = "SCIsHidden"
        case isRety = "SCIsRety"
        case isAppStarted = "SCIsAppStarted"
    }

    func kycId() -> String? {
        UserDefaults.standard.string(forKey: Key.kycId.rawValue)
    }

    func add(kycId: String?) {
        UserDefaults.standard.set(kycId, forKey: Key.kycId.rawValue)
    }

    func isSCBannerHidden() -> Bool {
        UserDefaults.standard.bool(forKey: Key.isHidden.rawValue)
    }

    func set(isHidden: Bool) {
        UserDefaults.standard.set(isHidden, forKey: Key.isHidden.rawValue)
    }

    func isKYCRety() -> Bool {
        UserDefaults.standard.bool(forKey: Key.isRety.rawValue)
    }

    func set(isRety: Bool) {
        UserDefaults.standard.set(isRety, forKey: Key.isRety.rawValue)
    }

    func isFirstLaunch() -> Bool {
        !UserDefaults.standard.bool(forKey: Key.isAppStarted.rawValue)
    }

    func setAppLaunched() {
        UserDefaults.standard.set(true, forKey: Key.isAppStarted.rawValue)
    }

    func token() async -> SCToken? {
        await withCheckedContinuation { continuation in
            secretManager.loadSecret(for: Key.accessToken.rawValue, completionQueue: DispatchQueue.main) { secretDataRepresentable in
                continuation.resume(returning: SCToken(secretData: secretDataRepresentable))
            }
        }
    }

    func hasToken() -> Bool {
        secretManager.checkSecret(for: Key.accessToken.rawValue)
    }

    func add(token: SCToken) async {
        await withCheckedContinuation { continuation in
            guard let data = token.asSecretData() else { return }
            secretManager.saveSecret(
                data,
                for: Key.accessToken.rawValue,
                completionQueue: DispatchQueue.main
            ) { _ in
                continuation.resume()
            }
        }
    }

    func removeToken() async {
        await withCheckedContinuation { continuation in
            secretManager.removeSecret(for: Key.accessToken.rawValue, completionQueue: DispatchQueue.main) { _ in
                continuation.resume()
            }
        }
    }
}
