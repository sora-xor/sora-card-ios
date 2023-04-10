import Foundation
import PayWingsOAuthSDK

final class SCKYCEnterPhoneViewModel {

    var onContinue: (() -> Void)?
    var onError: ((String) -> Void)?

    private let service: SCKYCService
    private let data: SCKYCUserDataModel
    private let callback = SignInWithPhoneNumberRequestOtpCallback()

    init(service: SCKYCService, data: SCKYCUserDataModel) {
        self.service = service
        self.data = data
        callback.delegate = self
    }

    func set(phoneNumber: String) {
        data.phoneNumber = phoneNumber 
        data.lastPhoneOTPSentDate = Date()

        service.signInWithPhoneNumberRequestOtp(
            phoneNumber: phoneNumber,
            callback: callback
        )
    }
}

extension SCKYCEnterPhoneViewModel: SignInWithPhoneNumberRequestOtpCallbackDelegate {
    func onShowOtpInputScreen(otpLength: Int) {
        // TODO: SC otpLength needed?
        onError?("")
        onContinue?()
    }

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        onError?(error.description)
    }
}


