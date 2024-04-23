final class SCExchangeOnboardingSourceViewModel {
    var onContinue: (() -> Void)?
    var onError: ((String) -> Void)?

    private let service: SCExchangeService
    private let model: SCExchangeOnboardingModel

    var sources: [SCExchangeOnboarding.SourceOfFunds : Bool] {
        model.sources
    }

    init(service: SCExchangeService, model: SCExchangeOnboardingModel) {
        self.service = service
        self.model = model
    }

    func handleSource(_ source: SCExchangeOnboarding.SourceOfFunds) {
        model.sources[source]?.toggle()
    }

    func processOnboarding() {

        Task {
            switch await service.onboardUser() {
            case .success(let response):
                onContinue?()
            case .failure(let error):
                onError?(error.localizedDescription)
            }
        }
    }
}
