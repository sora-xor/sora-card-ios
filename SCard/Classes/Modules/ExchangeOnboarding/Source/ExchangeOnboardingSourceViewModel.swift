final class ExchangeOnboardingSourceViewModel {
    var onContinue: (() -> Void)?
    var onError: ((String) -> Void)?

    private let service: ExchangeService
    private let model: ExchangeOnboardingModel

    var sources: [ExchangeOnboarding.SourceOfFunds : Bool] {
        model.sources
    }

    init(service: ExchangeService, model: ExchangeOnboardingModel) {
        self.service = service
        self.model = model
    }

    func handleSource(_ source: ExchangeOnboarding.SourceOfFunds) {
        model.sources[source]?.toggle()
    }

    func processOnboarding() {

        Task {
            switch await service.onboardUser() {
            case .success(let response):
                onError?("")
                onContinue?()
            case .failure(let error):
                onError?(error.localizedDescription)
            }
        }
    }
}
