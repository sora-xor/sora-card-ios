import Foundation

extension SCKYCService {
    func kycLastStatus() async -> Result<SCUserState?, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycLastStatus)
        let response: Result<SCUserState?, NetworkingError> = await client.performDecodable(request: request)
        if case .success(let kycState) = response, let kycState = kycState {
            self._userStatusStream.wrappedValue = kycState.userStatus
            self.currentUserState = kycState
        } else {
            self.clearUserKYCState()
        }
        return response
    }

    var userStatusStream: AsyncStream<SCKYCUserStatus> {
        _userStatusStream.stream
    }

    func userStatus() async -> SCKYCUserStatus? {
        guard case .success(let status) = await kycLastStatus(),
              let userStatus = status?.userStatus
        else { return nil }
        return userStatus
    }

    func clearUserKYCState() {
        _userStatusStream.wrappedValue = .notStarted
        currentUserState = .notStarted
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
        }
    }
}

extension SCUserState {
    static let notStarted: SCUserState = .init(
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
}

public enum SCKYCUserStatus: Equatable {
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
    case notStarted
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
