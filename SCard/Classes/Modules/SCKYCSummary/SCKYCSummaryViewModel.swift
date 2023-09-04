import Foundation

final class SCKYCSummaryViewModel {

    var onContinue: (() -> Void)?
    var onAttempts: ((Int64) -> Void)?

    private let service: SCKYCService

    init(service: SCKYCService) {
        self.service = service
    }

    func getKYCAttempts() async {
        switch await service.kycAttempts() {
        case .failure(let error):
            // TODO: no design
            print("SCKYCSummaryViewModel failure:\(error)")
            return
        case .success(let kycAttempts):
            onAttempts?(kycAttempts.freeAttempts)
        }
    }
}
