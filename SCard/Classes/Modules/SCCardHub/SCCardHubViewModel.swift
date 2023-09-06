final class SCCardHubViewModel {
    private let service: SCKYCService

    init(service: SCKYCService) {
        self.service = service
    }

    func iban() async -> String? {
        switch await service.iban() {
        case .success(let iban):
            if let iban = iban.ibans.first?.iban, !iban.isEmpty {
                return iban
            } else {
                return nil
            }
        case .failure(let error):
            print(error)
            return nil
        }
    }
}
