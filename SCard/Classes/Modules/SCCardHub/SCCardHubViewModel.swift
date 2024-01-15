final class SCCardHubViewModel {
    private let service: SCKYCService

    func needUpdateApp() async -> Bool {
        await service.updateVersion()
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
            if let iban = iban.ibans?.first {
                return iban.isActive ? iban : nil
            }
            return nil
        case .failure(let error):
            print(error)
            return nil
        }
    }
}
