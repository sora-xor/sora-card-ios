import Foundation
import PayWingsOAuthSDK

final class SCKYCStatusViewModel {
    var onStatus: ((SCKYCUserStatus, Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onClose: (() -> Void)?
    var onRetry: (() -> Void)?
    var onLogout: (() -> Void)?
    var onSupport: (() -> Void)?

    private let service: SCKYCService
    private var hasFreeAttempts: Bool?

    init(data: SCKYCUserDataModel, service: SCKYCService) {
        self.data = data
        self.service = service
    }

    let data: SCKYCUserDataModel

    func getKYCStatus() async {
        guard await service.refreshAccessTokenIfNeeded() else {
            onError?("PayWings Login required!")
            return
        }

        await getKYCAttempts()

        for await status in service.userStatusStream {

            if hasFreeAttempts == nil {
                await getKYCAttempts()
            }
            guard let hasFreeAttempts = self.hasFreeAttempts else { return }
            onStatus?(status, hasFreeAttempts)
        }
    }

    private func getKYCAttempts() async {
        switch await service.kycAttempts() {
        case .failure(let error):
            onError?(error.errorDescription ?? "error")
        case .success(let kycAttempts):
            self.hasFreeAttempts = kycAttempts.hasFreeAttempts
        }
    }
}
