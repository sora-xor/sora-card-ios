import Foundation
import PayWingsOAuthSDK

enum SCEndpoint: Endpoint {
    case getReferenceNumber
    // case kycStatus
    case kycStatuses
    case kycAttemptCount
    case xOneStatus(paymentId: String)
    case price(pair: String)
    case xOneWidget
    case ibans

    var path: String {

        switch self {
        case .getReferenceNumber:
            return "get-reference-number"
        // case .kycStatus:
        //    return "kyc-last-status"
        case .kycStatuses:
            return "kyc-status"
        case .kycAttemptCount:
            return "kyc-attempt-count"
        case .xOneStatus(let paymentId):
            return "x1-payment-status/\(paymentId)"
        case .price(let pair):
            return "prices/\(pair)"
        case .xOneWidget:
            return "widgets/sdk.js"
        case .ibans:
            return "ibans"
        }
    }
}

public final class SCKYCService {

    internal let client: SCAPIClient
    internal var currentUserStatus: SCKYCUserStatus?
    let config: SCard.Config
    private let payWingsOAuthClient: PayWingsOAuthSDK.OAuthServiceProtocol
    private var isRefreshAccessTokenInProgress = false
    private var kycStatusRefresherTimer: Timer?

    init(client: SCAPIClient, config: SCard.Config) {
        self.client = client
        self.config = config

        PayWingsOAuthClient.initialize(
            environmentType: config.environmentType.pwType,
            apiKey: config.pwApiKey,
            domain: config.pwAuthDomain
        )
        
        self.payWingsOAuthClient = PayWingsOAuthClient.instance()!
    }

    @SCStream internal var _userStatusStream = SCStream(wrappedValue: SCKYCUserStatus.notStarted)

    func startKYCStatusRefresher() {
        guard kycStatusRefresherTimer == nil else { return }
        kycStatusRefresherTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { [weak self] in let status  = await self?.userStatus() }
        }
    }

    func refreshAccessTokenIfNeeded() async -> Bool {
        guard let token = await SCStorage.shared.token(),
              !isRefreshAccessTokenInProgress
        else {
            return false
        }
        guard Date() >= Date(timeIntervalSince1970: TimeInterval(token.accessTokenExpirationTime))
        else {
            client.set(token: token)
            return true
        }

        isRefreshAccessTokenInProgress = true

        return await withCheckedContinuation { continuation in

            self.payWingsOAuthClient.getNewAccessToken(refreshToken: token.refreshToken) { [weak self] result in
                if let data = result.accessTokenData {
                    let token = SCToken(
                        refreshToken: token.refreshToken,
                        accessToken: data.accessToken,
                        accessTokenExpirationTime: data.accessTokenExpirationTime
                    )
                    self?.client.set(token: token)

                    Task {
                        await SCStorage.shared.add(token: token)
                    }
                    continuation.resume(returning: true)
                    self?.isRefreshAccessTokenInProgress = false
                    return
                }

                if let errorData = result.errorData {
                    print("Error SCKYCService:\(errorData.error.rawValue) \(String(describing: errorData.errorMessage))")
                    continuation.resume(returning: false)
                    self?.isRefreshAccessTokenInProgress = false
                    return
                }
            }
        }
    }

    func sendNewVerificationEmail(callback: SendNewVerificationEmailCallback) {
        payWingsOAuthClient.sendNewVerificationEmail(callback: callback)
    }

    func getUserData(callback: GetUserDataCallback) {
        Task {
            guard let token = await SCStorage.shared.token() else {
                return
            }
            payWingsOAuthClient.getUserData(accessToken: token.accessToken, callback: callback)
        }
    }

    func registerUser(data: SCKYCUserDataModel, callback: RegisterUserCallback) {
        payWingsOAuthClient.registerUser(
            firstName: data.name,
            lastName: data.lastname,
            email: data.email,
            callback: callback
        )
    }

    func changeUnverifiedEmail(email: String, callback: ChangeUnverifiedEmailCallback) {
        payWingsOAuthClient.changeUnverifiedEmail(email: email, callback: callback)
    }

    func signInWithPhoneNumberVerifyOtp(code: String, callback: SignInWithPhoneNumberVerifyOtpCallback) {
        payWingsOAuthClient.signInWithPhoneNumberVerifyOtp(otp: code, callback: callback)
    }

    func signInWithPhoneNumberRequestOtp(phoneNumber: String, callback: SignInWithPhoneNumberRequestOtpCallback) {
        payWingsOAuthClient.signInWithPhoneNumberRequestOtp(
            phoneNumber: phoneNumber,
            smsContentTemplate: nil,
            callback: callback
        )
    }

    func checkEmailVerified(callback: CheckEmailVerifiedCallback) {
        payWingsOAuthClient.checkEmailVerified(callback: callback)
    }
}
