import PayWingsOAuthSDK

final class SCKYCUserDataService {

    private let service: SCKYCService
    private var data: SCKYCUserDataModel?
    private let getUserDataCallback = GetUserDataCallback()
    private var continuation: CheckedContinuation<SCKYCUserDataModel?, Never>?

    init(service: SCKYCService) {
        self.service = service
        getUserDataCallback.delegate = self
    }

    func fetchUserData() async -> SCKYCUserDataModel? {
        self.service.getUserData(callback: getUserDataCallback)
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

extension SCKYCUserDataService: GetUserDataCallbackDelegate {
    func onUserSignInRequired() {
        print("SCKYCUserDataService onUserSignInRequired")
        continuation?.resume(returning: nil)
    }
    
    func onError(error: PayWingsOAuthSDK.OAuthErrorCode, errorMessage: String?) {
        print("SCKYCUserDataService onError \(error) \(errorMessage ?? "")")
        continuation?.resume(returning: nil)
    }

    func onUserData(
        userId: String,
        firstName: String?,
        lastName: String?,
        email: String?,
        emailConfirmed: Bool,
        phoneNumber: String?
    ) {
        let data = SCKYCUserDataModel()
        data.userId = userId
        data.name = firstName ?? ""
        data.lastname = lastName ?? ""
        data.phoneNumber = phoneNumber ?? ""
        data.email = email ?? ""
        data.isEmailSent = !(email ?? "").isEmpty
        continuation?.resume(returning: data)
    }
}
