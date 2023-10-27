import PayWingsOAuthSDK

final class SCKYCEnterPhoneViewModel {

    /// "^[\\+]?[(]?[0-9]{3}[)]?[-\\s.]?[0-9]{3}[-\\s.]?[0-9]{3,9}$"
    static let phoneNumberRegex = "^[\\+][0-9]{8,16}$"
    var onCountry: (() -> Void)?
    var onContinue: (() -> Void)?
    var onUpdateUI: ((String, Bool) -> Void)?
    var onUpdateCountry: ((SCCountry) -> Void)?

    private let service: SCKYCService
    private let data: SCKYCUserDataModel
    private var selectedCountry: SCCountry
    private let callback = SignInWithPhoneNumberRequestOtpCallback()
    private var phoneNumber = ""

    init(service: SCKYCService, data: SCKYCUserDataModel) {
        self.service = service
        self.data = data
        self.selectedCountry = .usa
        callback.delegate = self

    }

    func setupCrrentCountry() {
        Task {
            let response = await service.updateCountries()
            switch response {
            case .success(let countries):
                let regionCode = Locale.current.regionCode
                let country = countries
                    .first(where: { $0.code.lowercased() == regionCode?.lowercased() }) ?? .usa
                selectedCountry = country
                await MainActor.run {
                    onUpdateCountry?(country)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func onInput(text: String) {
        let cleanText = text.first == "0" ? String(text.dropFirst(1)) : text
        phoneNumber = selectedCountry.dialCode + cleanText
        if cleanText.isEmpty {
            onUpdateUI?(R.string.soraCard.commonNoSpam(preferredLanguages: .currentLocale), false)
        } else {
            if phoneNumber ~= Self.phoneNumberRegex {
                onUpdateUI?("", true)
            } else {
                if phoneNumber.count > 7 {
                    onUpdateUI?("Wrong phone number format!", false) // TODO: localize
                }
            }
        }
    }

    func onCountrySelected(_ selectedCountry: SCCountry) {
        self.selectedCountry = selectedCountry
        onUpdateCountry?(selectedCountry)
    }

    func signIn() {
        onUpdateUI?("", false)
        data.phoneNumber = phoneNumber

        if data.secondsLeftForPhoneOTP == 0 {
            data.lastPhoneOTPSentDate = Date()
            service.signInWithPhoneNumberRequestOtp(
                phoneNumber: phoneNumber,
                callback: callback
            )
        } else {
            onContinue?()
        }
    }
}

extension SCKYCEnterPhoneViewModel: SignInWithPhoneNumberRequestOtpCallbackDelegate {
    func onShowOtpInputScreen(otpLength: Int) {
        data.otpLength = otpLength
        onContinue?()
        onUpdateUI?("", true)
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
