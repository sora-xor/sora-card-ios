import Foundation
import PayWingsOAuthSDK

final class SCKYCStatusViewModel {
    var onStatus: ((SCKYCUserStatus, Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onClose: (() -> Void)?
    var onRetry: (() -> Void)?
    var onReset: (() -> Void)?
    var onSupport: (() -> Void)?

    private let service: SCKYCService

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
        let response = await service.kycStatuses()
        switch response {
        case .failure(let error):
            onError?(error.errorDescription ?? "error")
        case .success(let statuses):
            guard let status = statuses.sorted.last else {
                onError?("KYC not started yet")
                return
            }

            switch await service.kycAttempts() {
            case .failure(let error):
                onError?(error.errorDescription ?? "error")
            case .success(let kycAttempts):
                onStatus?(status.userStatus, kycAttempts.hasFreeAttempts)
            }
        }
    }
}
