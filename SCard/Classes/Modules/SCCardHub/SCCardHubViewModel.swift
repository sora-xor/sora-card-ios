final class SCCardHubViewModel {
    private let service: SCKYCService

    var needUpdateApp: Bool {
        switch service.verionsChangesNeeded() {
        case .major, .minor:
            return true
        case .none, .patch:
            return false
        }
    }

    init(service: SCKYCService) {
        self.service = service
    }

    func iban() async -> Iban? {
        switch await service.iban() {
        case .success(let iban):
            return iban.ibans?.first
        case .failure(let error):
            print(error)
            return nil
        }
    }
}
