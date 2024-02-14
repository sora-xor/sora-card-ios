import Foundation

extension SCKYCService {

    func updateKycState() async {

        async let ibanResult = iban()
        async let kycLastStateResult = kycLastState()

        var hasIban = false
        switch await ibanResult {
        case .success(let resoponse):
            hasIban = !(resoponse.ibans ?? []).isEmpty
        case .failure(let error):
            print(error)
        }

        switch await kycLastStateResult {
        case .success(let kycState):
            let kycState = kycState ?? .none

            /// Fix for user with iban but stuck KYC process for some reason
            if hasIban, kycState.userStatus != .successful  {
                self.currentUserState = .successful
                self._userStatusStream.wrappedValue = .successful
            } else {
                self.currentUserState = kycState
                self._userStatusStream.wrappedValue = kycState.userStatus
            }

        case .failure(let error):
            print("UpdateKycState error:\(error)")
        }

//TODO: statuses testing
//        Task {
//            while true {
//                _userStatusStream.wrappedValue = .none
//                sleep(3)
//                _userStatusStream.wrappedValue = .notStarted
//                sleep(3)
//                _userStatusStream.wrappedValue = .pending
//                sleep(3)
//                _userStatusStream.wrappedValue = .rejected(.init(additionalDescription: "test rej", reasons: ["reason 1"]))
//                sleep(3)
//                _userStatusStream.wrappedValue = .userCanceled
//                sleep(3)
//                _userStatusStream.wrappedValue = .successful
//            }
//        }
//TODO: statuses testing
    }

    var userStatusStream: AsyncStream<SCKYCUserStatus> {
        _userStatusStream.stream
    }

    func userStatus() async -> SCKYCUserStatus {
        await updateKycState()
        return currentUserState.userStatus
    }

    private func kycLastState() async -> Result<SCUserState?, NetworkingError> {
        guard isUserSignIn() else {
            return .failure(.unauthorized)
        }
        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycLastStatus)
        return await client.performDecodable(request: request)
    }
}

struct SCUserState: Codable {
    let kycId: String
    let personId: String
    let userReferenceNumber: String
    let referenceId: String
    internal let kycStatus: SCKYCStatus
    internal let verificationStatus: SCVerificationStatus
    let ibanStatus: SCIbanStatus
    let additionalDescription: String?
    let rejectionReasons: [SCKYCRejectionReason]?
    let updateTime: Int64

    enum CodingKeys: String, CodingKey {
        case kycId = "kyc_id"
        case personId = "person_id"
        case userReferenceNumber = "user_reference_number"
        case referenceId = "reference_id"
        case kycStatus = "kyc_status"
        case verificationStatus = "verification_status"
        case ibanStatus = "iban_status"
        case additionalDescription = "additional_description"
        case rejectionReasons = "rejection_reasons"
        case updateTime = "update_time"
    }

    /// Local combination of verificationStatus with kycStatus
    var userStatus: SCKYCUserStatus {

        // do not use kycStatus, it may be any state:
        // kycStatus == .Successful or kycStatus == completed or kycStatus == failed
        if verificationStatus == .accepted {
            return .successful
        }

        switch kycStatus {

        // KYC docs were sent, waiting for KYC verification
        case .completed:
            return .pending

        // KYC was rejected, start a new one with a new reference_number
        case .retry, .rejected:
            return .rejected(.init(
                additionalDescription: additionalDescription,
                reasons: rejectionReasons?.compactMap { $0.description } ?? []
            ))

        // KYC wasn't completed, reuse reference_number from KYC
        case .started, .failed, .successful:
            return .userCanceled // TODO: check

        case .notStarted:
            return .notStarted
        case .none:
            return .none
        }
    }
}

extension SCUserState {
    static let none: SCUserState = .init(
        kycId: "",
        personId: "",
        userReferenceNumber: "",
        referenceId: "",
        kycStatus: .notStarted,
        verificationStatus: .none,
        ibanStatus: .none,
        additionalDescription: nil,
        rejectionReasons: nil,
        updateTime: .init()
    )

    static let successful: SCUserState = .init(
        kycId: "",
        personId: "",
        userReferenceNumber: "",
        referenceId: "",
        kycStatus: .successful,
        verificationStatus: .accepted,
        ibanStatus: .pending,
        additionalDescription: nil,
        rejectionReasons: nil,
        updateTime: .init()
    )
}

@frozen
public enum SCKYCUserStatus: Equatable {
    case none
    case notStarted
    case pending
    case rejected(SCKYCRejection)
    case successful
    case userCanceled
}

public struct SCKYCRejection: Equatable {
    let additionalDescription: String?
    let reasons: [String]
}

enum SCKYCStatus: String, Codable {
    case none // Local
    case notStarted // Local
    case started = "Started"
    case completed = "Completed"
    case successful = "Successful"
    case failed = "Failed"
    case rejected = "Rejected"
    case retry = "Retry"
}

enum SCVerificationStatus: String, Codable {
    case none = "None"
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"
}

enum SCIbanStatus: String, Codable {
    case none = "None"
    case pending = "Pending"
    case rejected = "Rejected"
}

struct SCKYCRejectionReason: Codable {
    let description: String

    enum CodingKeys: String, CodingKey {
        case description = "Description"
    }
}

extension Array where Element == SCUserState {
    var sorted: [Element] {
        self.sorted(by: { $0.updateTime < $1.updateTime })
    }
}
