import Foundation
//import SoraKeystore
import PayWingsOAuthSDK


final class SCKYCEnterEmailCodeViewModel {
    var onContinue: ((SCKYCUserDataModel) -> Void)?
    var onChangeEmail: (() -> Void)?

    init(data: SCKYCUserDataModel, service: SCKYCService) {
        self.data = data
        self.service = service
        self.checkEmailCallback.delegate = self
        self.sendNewVerificationEmailCallback.delegate = self
    }

    let data: SCKYCUserDataModel
    private let service: SCKYCService
    private var codeState: SCKYCPhoneCodeState = .editing
    private var checkEmailCallback = CheckEmailVerifiedCallback()
    private var sendNewVerificationEmailCallback = SendNewVerificationEmailCallback()
    private var timer = Timer()

    func checkEmail() {

        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(requestCheckEmailVerified),
            userInfo: nil,
            repeats: true
        )
    }

    func resendVerificationLink() {
        data.lastEmailOTPSentDate = .init()
        service.sendNewVerificationEmail(callback: sendNewVerificationEmailCallback)
    }

    @objc private func requestCheckEmailVerified() {
        service.checkEmailVerified(callback: checkEmailCallback)
    }
}

extension SCKYCEnterEmailCodeViewModel: CheckEmailVerifiedCallbackDelegate {
    func onSignInSuccessful() {
        timer.invalidate()
        onContinue?(self.data)
    }

    func onEmailNotVerified() {
        print("SCKYCEnterEmailCodeViewModel onEmailNotVerified")
    }
}

extension SCKYCEnterEmailCodeViewModel: SendNewVerificationEmailCallbackDelegate {

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        print("SCKYCEnterEmailCodeViewModel error:\(error)")
    }

    func onUserSignInRequired() {
        print("SCKYCEnterEmailCodeViewModel onUserSignInRequired")
    }
    
    func onShowEmailConfirmationScreen(email: String, autoEmailSent: Bool) {
        print("SCKYCEnterEmailCodeViewModel onShowEmailConfirmationScreen")
    }
}
