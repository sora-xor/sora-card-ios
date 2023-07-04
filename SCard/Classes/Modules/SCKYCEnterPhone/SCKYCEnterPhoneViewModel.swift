import Foundation
import PayWingsOAuthSDK

final class SCKYCEnterPhoneViewModel {

    static let phoneNumberRegex = "^[\\+]?[(]?[0-9]{3}[)]?[-\\s.]?[0-9]{3}[-\\s.]?[0-9]{4,6}$"
    var onContinue: (() -> Void)?
    var onUpdateUI: ((String, Bool) -> Void)?

    private let service: SCKYCService
    private let data: SCKYCUserDataModel
    private let callback = SignInWithPhoneNumberRequestOtpCallback()
    private var phoneNumber = ""

    init(service: SCKYCService, data: SCKYCUserDataModel) {
        self.service = service
        self.data = data
        callback.delegate = self
    }

    func onInput(text: String) {
        phoneNumber = text
        if text.isEmpty {
            onUpdateUI?(R.string.soraCard.commonNoSpam(preferredLanguages: .currentLocale), false)
        } else {
            if text ~= Self.phoneNumberRegex {
                onUpdateUI?("", true)
            } else {
                if text.count > 13 {
                    onUpdateUI?("Wrong phone number format!", false)
                } else {
                    onUpdateUI?("", false)
                }
            }
        }
    }

    func signIn() {
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
        data.otpLength = otpLength
        onUpdateUI?("", true)
        onContinue?()
    }

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        onUpdateUI?(error.description, false)
    }
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
