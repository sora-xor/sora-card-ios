import Foundation
import PayWingsOAuthSDK

enum SCKYCPhoneCodeState {
    case editing
    case sent
    case wrong(String)
    case succeed
}

final class SCKYCEnterPhoneCodeViewModel {

    static let phoneCodeRegex = "[0-9]{4,6}$"

    var onEmailVerification: ((SCKYCUserDataModel) -> Void)?
    var onUserRegistration: ((SCKYCUserDataModel) -> Void)?
    var onSignInSuccessful: ((SCKYCUserDataModel) -> Void)?

    var onResend: ((SCKYCUserDataModel) -> Void)?
    var onUpdateUI: (() -> Void)?

    var callback = SignInWithPhoneNumberVerifyOtpCallback()
    var getUserDataCallback = GetUserDataCallback()

    init(data: SCKYCUserDataModel, service: SCKYCService) {
        self.data = data
        self.service = service
        callback.delegate = self
        getUserDataCallback.delegate = self
    }

    let data: SCKYCUserDataModel
    var codeState: SCKYCPhoneCodeState = .editing

    private let service: SCKYCService

    func check(code: String) {
        if code.count < data.otpLength {
            codeState = .editing
            onUpdateUI?()
            return
        }

        if code ~= Self.phoneCodeRegex {
            codeState = .sent
            onUpdateUI?()
            service.signInWithPhoneNumberVerifyOtp(code: code, callback: callback)
            return
        }

        codeState = .wrong(R.string.soraCard.commonWrongFormat(preferredLanguages: .currentLocale))
        onUpdateUI?()
    }
}

extension SCKYCEnterPhoneCodeViewModel: SignInWithPhoneNumberVerifyOtpCallbackDelegate {
    func onShowEmailConfirmationScreen(email: String, autoEmailSent: Bool) {
        data.email = email
        data.isEmailSent = true
        codeState = .succeed
        onEmailVerification?(data)
    }

    func onShowRegistrationScreen() {
        codeState = .succeed
        onUpdateUI?()
        onUserRegistration?(data)
    }

    func onUserSignInRequired() {}

    func onVerificationFailed() {
        codeState = .wrong(R.string.soraCard.otpErrorMessageWrongCode(preferredLanguages: .currentLocale))
        onUpdateUI?()
    }

    func onSignInSuccessful(refreshToken: String, accessToken: String, accessTokenExpirationTime: Int64) {
        let token = SCToken(refreshToken: refreshToken, accessToken: accessToken, accessTokenExpirationTime: accessTokenExpirationTime)
        service.client.set(token: token)

        Task { [weak self] in
            await SCStorage.shared.add(token: token)
            guard let self = self else { return }
            self.service.getUserData(callback: self.getUserDataCallback)
            await MainActor.run {
                self.onUpdateUI?()
            }
        }
    }

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        codeState = .wrong(errorMessage ?? error.description)
        onUpdateUI?()
    }
}

extension SCKYCEnterPhoneCodeViewModel: GetUserDataCallbackDelegate {

    func onUserData(
        userId: String,
        firstName: String?,
        lastName: String?,
        email: String?,
        emailConfirmed: Bool,
        phoneNumber: String?
    ) {
        data.userId = userId
        data.name = firstName ?? ""
        data.lastname = lastName ?? ""
        data.email = email ?? ""

        onSignInSuccessful?(data)
    }
}
