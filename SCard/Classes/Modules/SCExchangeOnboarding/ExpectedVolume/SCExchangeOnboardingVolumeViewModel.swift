import SwiftUI

final class SCExchangeOnboardingVolumeViewModel {
    var onContinue: ((SCExchangeOnboarding.ExpectedVolume) -> Void)?

    var volume: SCExchangeOnboarding.ExpectedVolume

    private let service: SCExchangeService

    init(service: SCExchangeService, volume: SCExchangeOnboarding.ExpectedVolume) {
        self.service = service
        self.volume = volume
    }

    func next() {
        onContinue?(volume)
    }
}
