import Foundation
import PayWingsOAuthSDK

final class SCKYCEnterEmailViewModel {
    var onContinue: ((SCKYCUserDataModel) -> Void)?
    var onError: ((String) -> Void)?

    var secondsLeft: Int {
        abs(Int(Date().timeIntervalSince(data.lastEmailOTPSentDate + 60)))
    }

    init(data: SCKYCUserDataModel, service: SCKYCService) {
        self.data = data
        self.service = service
        registerUserCallback.delegate = self
        changeUnverifiedEmailCallback.delegate = self
    }

    private let service: SCKYCService
    private let data: SCKYCUserDataModel
    private let registerUserCallback = RegisterUserCallback()
    private let changeUnverifiedEmailCallback = ChangeUnverifiedEmailCallback()

    func register(email: String) {

        guard !data.isEmailSent else {
            changeEmail(email: email)
            return
        }

        data.lastEmailOTPSentDate = Date()
        data.isEmailSent = true
        data.email = email

        service.registerUser(data: data, callback: registerUserCallback)
    }

    private func changeEmail(email: String) {
        data.lastEmailOTPSentDate = Date()
        data.email = email
        service.changeUnverifiedEmail(email: email, callback: changeUnverifiedEmailCallback)
    }
}

extension SCKYCEnterEmailViewModel: RegisterUserCallbackDelegate, ChangeUnverifiedEmailCallbackDelegate {
    func onSignInSuccessful() {
        onError?("")
        onContinue?(data)
    }

    func onShowEmailConfirmationScreen(email: String, autoEmailSent: Bool) {
        onError?("")
        onContinue?(data)
    }

    func onUserSignInRequired() {
        onError?("")
        onContinue?(data)
    }

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {

        if error == .EMAIL_ALREADY_VERIFIED
            //TODO: fix on PW side || errorMessage?.contains("User email verification required") ?? false
        {
            onError?("")
            onContinue?(data)
            return 
        }
        onError?(errorMessage ?? error.description)
    }
}
