final class SCCardHubViewModel {
    private let service: SCKYCService

    init(service: SCKYCService) {
        self.service = service
    }

    func iban() async -> String? {
        switch await service.iban() {
        case .success(let iban):
            return iban.ibans.first?.iban
        case .failure(let error):
            print(error)
            return nil
        }
    }
}
