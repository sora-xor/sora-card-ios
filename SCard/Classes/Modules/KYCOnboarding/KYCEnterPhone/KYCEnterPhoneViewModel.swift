import PayWingsOAuthSDK

enum KYCEnterPhoneInputMessage {
    case none
    case zeroFormat
    case timerIsActive
    case wrongFormat
    case noSpam
    case error(String)
    
    var description: String {
        switch self {
        case .zeroFormat:
            return "The phone number format entered seems unusual. If issues arise, consider removing the leading \"0\"."
        case .noSpam:
            return R.string.soraCard.commonNoSpam(preferredLanguages: .currentLocale)
        case .wrongFormat:
            return "Wrong phone number format!"
        case .timerIsActive:
            return "Please wait before retrying."
        case .error(let message):
            return message
        case .none:
            return ""
        }
    }
}

final class KYCEnterPhoneViewModel {

    /// "^[\\+]?[(]?[0-9]{3}[)]?[-\\s.]?[0-9]{3}[-\\s.]?[0-9]{3,9}$"
    static let phoneNumberRegex = "^[\\+][0-9]{8,16}$"
    var onCountry: (() -> Void)?
    var onContinue: (() -> Void)?
    var onUpdateUI: ((KYCEnterPhoneInputMessage, Bool, Int) -> Void)?
    var onPhoneNumber: ((String) -> Void)?
    var onUpdateCountry: ((SCCountry) -> Void)?
    var outputWithActiveTimer: ((Date?) -> ())?

    let data: KYCUserDataModel
    private var currentText: String = ""
    private var timerIsActive: Bool = false
    
    private let service: KYCService
    private var selectedCountry: SCCountry = .usa
    private let callback = SignInWithPhoneNumberRequestOtpCallback()
    private var dialCode = ""
    private var phoneNumber = ""

    private var isPhoneNumberZeroPrefixCorrectionOn: Bool {
        data.loginCase == .register
    }

    init(service: KYCService, data: KYCUserDataModel) {
        self.service = service
        self.data = data
        callback.delegate = self
    }

    func updateTimerIfNeeded() {
        guard data.secondsLeftForPhoneOTP > 0 || timerIsActive else { return }
        
        onUpdateUI?(.timerIsActive, false, data.secondsLeftForPhoneOTP)
        
        timerIsActive = data.secondsLeftForPhoneOTP > 0
        
        if !timerIsActive {
            onInput(text: currentText)
        }
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
                data.phoneCountryCode = country.dialCode
                await MainActor.run {
                    onUpdateCountry?(country)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func onInput(text: String) {

        var cleanText = text
        currentText = text
        if cleanText.first == "0" {
            if isPhoneNumberZeroPrefixCorrectionOn {
                cleanText = String(cleanText.drop(while: { $0 == "0"} ))
                onPhoneNumber?(cleanText)
            }
        }

        dialCode = selectedCountry.dialCode
        phoneNumber = cleanText
        let phone = dialCode + phoneNumber
        
        if cleanText.isEmpty {
            onUpdateUI?( .noSpam,
                false,
                data.secondsLeftForPhoneOTP
            )
        } else {
            if phone ~= Self.phoneNumberRegex {
                if phoneNumber.first == "0" {
                    onUpdateUI?(.zeroFormat, data.secondsLeftForPhoneOTP == 0, data.secondsLeftForPhoneOTP)
                } else {
                    onUpdateUI?(.none, data.secondsLeftForPhoneOTP == 0, data.secondsLeftForPhoneOTP)
                }
            } else {
                if phone.count > 7 {
                    onUpdateUI?(.wrongFormat, false, data.secondsLeftForPhoneOTP)
                }
            }
        }
    }

    func onCountrySelected(_ selectedCountry: SCCountry) {
        self.selectedCountry = selectedCountry
        data.phoneCountryCode = selectedCountry.dialCode
        onUpdateCountry?(selectedCountry)
    }

    func signIn() {
        data.phoneNumber = phoneNumber

        if data.secondsLeftForPhoneOTP == 0 {
            data.lastPhoneOTPSentDate = Date()
            onUpdateUI?(.none, false, data.secondsLeftForPhoneOTP)
            service.signInWithPhoneNumberRequestOtp(
                countryCode: dialCode,
                phoneNumber: phoneNumber,
                callback: callback
            )
        } else {
            onUpdateUI?(.none, false, data.secondsLeftForPhoneOTP)
            onContinue?()
        }
    }
    
    func saveTimerIfNeeded() {
        outputWithActiveTimer?(data.lastPhoneOTPSentDate)
    }
}

extension KYCEnterPhoneViewModel: SignInWithPhoneNumberRequestOtpCallbackDelegate {
    func onShowTimeBasedOtpVerificationInputScreen(accountName: String) {
        print("TODO: onShowTimeBasedOtpVerificationInputScreen")
    }
    
    func onShowOtpInputScreen(otpLength: Int) {
        data.otpLength = otpLength
        onContinue?()
        onUpdateUI?(.none, false, data.secondsLeftForPhoneOTP) // todo stop timer
    }

    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        onUpdateUI?(.error(error.description), false, data.secondsLeftForPhoneOTP)
    }
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
