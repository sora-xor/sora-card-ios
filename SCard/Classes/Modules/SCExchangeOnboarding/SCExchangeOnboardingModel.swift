final class SCExchangeOnboardingModel {
    var volume: SCExchangeOnboarding.ExpectedVolume
    var reasons: [SCExchangeOnboarding.OpeningReason : Bool]
    var sources: [SCExchangeOnboarding.SourceOfFunds : Bool]

    init() {
        self.volume = .k10
        self.reasons = SCExchangeOnboarding.OpeningReason.allCases
            .reduce(into: [SCExchangeOnboarding.OpeningReason : Bool]()) {
                $0[$1] = false
            }
        self.sources = SCExchangeOnboarding.SourceOfFunds.allCases
            .reduce(into: [SCExchangeOnboarding.SourceOfFunds : Bool]()) {
                $0[$1] = false
            }
    }
}
