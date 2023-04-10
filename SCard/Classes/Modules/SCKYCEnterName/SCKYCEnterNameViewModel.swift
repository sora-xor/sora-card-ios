import Foundation

final class SCKYCEnterNameViewModel {
    var onContinue: ((SCKYCUserDataModel) -> Void)?

    init(data: SCKYCUserDataModel) {
        self.data = data
    }

    let data: SCKYCUserDataModel

    var isContinueEnabled: Bool {
        !(data.name.isEmpty || data.lastname.isEmpty)
    }
}
