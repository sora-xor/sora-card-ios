final class SCCardHubViewModel {

    var onUpdateUI: ((Iban?, Bool) -> Void)?
    var onAppStore: (() -> Void)?

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

    func manageCard() {
        #if DEBUG
        let bundleId = "com.soracard.iban.wallet.test"
        #elseif F_DEV
        let bundleId = "com.soracard.iban.wallet.test"
        #elseif F_TEST
        let bundleId = "com.soracard.iban.wallet.test"
        #elseif F_STAGING
        let bundleId = "com.soracard.iban.wallet"
        #else
        let bundleId = "com.soracard.iban.wallet"
        #endif

        let bundleUrl = "\(bundleId)://"
        let appUrl = URL(string: bundleUrl)!

        if UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.open(appUrl)
        } else {
            onAppStore?()
        }
    }
}
