final class SCCardHubViewModel {

    var onUpdateUI: ((Iban?, Bool) -> Void)?

    private let service: SCKYCService

    func needUpdateApp() async -> Bool {
        switch await service.verionsChangesNeeded() {
        case .major, .minor:
            return true
        case .none, .patch:
            return false
        }
    }

    init(service: SCKYCService) {
        self.service = service
    }

    func fetchIban() {
        Task {
            let needUpdateApp = await needUpdateApp()
            for await state in await service.ibanStream() {
                await MainActor.run {
                    switch state {
                    case .inited:
                        onUpdateUI?(nil, needUpdateApp)
                    case .loading(let data):
                        onUpdateUI?(data??.first, needUpdateApp)
                    case .success(let data):
                        onUpdateUI?(data?.first, needUpdateApp)
                    case .failure(let failure):
                        // TODO: show error to user
                        print(failure)
                        onUpdateUI?(nil, needUpdateApp)
                    }
                }
            }
        }
    }
}
