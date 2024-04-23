final class SCExchangeOnboardingReasonViewModel {
    var onContinue: (() -> Void)?

    var reasons: [SCExchangeOnboarding.OpeningReason : Bool] {
        model.reasons
    }

    private let model: SCExchangeOnboardingModel

    private let service: SCExchangeService

    init(service: SCExchangeService, model: SCExchangeOnboardingModel) {
        self.service = service
        self.model = model
    }

    func handleReason(_ reason: SCExchangeOnboarding.OpeningReason) {
        model.reasons[reason]?.toggle()
    }

    func next() {
        onContinue?()
    }
}
