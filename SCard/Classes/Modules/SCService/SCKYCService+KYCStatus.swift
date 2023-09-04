import Foundation

extension SCKYCService {
    //    func kycStatus() async -> Result<SCKYCStatusResponse?, NetworkingError> {
    //        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycStatus)
    //        return await client.performDecodable(request: request)
    //    }

    var userStatusStream: AsyncStream<SCKYCUserStatus> {
        _userStatusStream.stream
    }

    func userStatus() async -> SCKYCUserStatus? {
        guard case .success(let statuses) = await kycStatuses(),
              let userStatus = statuses.sorted.last?.userStatus
        else { return nil }
        return userStatus
    }

    func kycStatuses() async -> Result<[SCKYCStatusResponse], NetworkingError> {
        guard await refreshAccessTokenIfNeeded() else {
            return .failure(.unauthorized)
        }
        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycStatuses)
        let response: Result<[SCKYCStatusResponse], NetworkingError> = await client.performDecodable(request: request)
        if case .success(let statuses) = response, let userStatus = statuses.sorted.last?.userStatus {
            self._userStatusStream.wrappedValue = userStatus
        } else {
            self._userStatusStream.wrappedValue = .notStarted
        }
        return response
    }

    func kycAttempts() async -> Result<SCKYCAtempts, NetworkingError> {
        guard await refreshAccessTokenIfNeeded() else {
            return .failure(.unauthorized)
        }
        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycAttemptCount)
        return await client.performDecodable(request: request)
    }
}

extension Array where Element == SCKYCStatusResponse {
    var sorted: [Element] {
        self.sorted(by: { $0.updateTime < $1.updateTime })
    }
}

struct SCKYCStatusResponse: Codable {
    let kycId: String
    let personId: String
    let userReferenceNumber: String
    let referenceId: String
    private let kycStatus: SCKYCStatus
    private let verificationStatus: SCVerificationStatus
    let ibanStatus: SCIbanStatus
    let additionalDescription: String?
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
        case updateTime = "update_time"
    }

    var userStatus: SCKYCUserStatus {

        if kycStatus == .completed && verificationStatus == .pending {
            return .pending
        }

        if kycStatus == .rejected || verificationStatus == .rejected {
            return .rejected
        }
        
        if kycStatus == .failed {
            return .userCanceled
        }

        if verificationStatus == .accepted {
            return .successful
        }

        return .notStarted
    }
}

public enum SCKYCUserStatus {
    case notStarted
    case pending
    case rejected
    case successful
    case userCanceled
}

enum SCKYCStatus: String, Codable {
    case started = "Started"
    case completed = "Completed"
    case successful = "Successful"
    case failed = "Failed"
    case rejected = "Rejected"
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

struct SCKYCAtempts: Codable {
    let total: Int64
    let completed: Int64
    let rejected: Int64
    let freeAttempts: Int64
    let hasFreeAttempts: Bool

    enum CodingKeys: String, CodingKey {
        case total
        case completed
        case rejected
        case freeAttempts = "free_attempts"
        case hasFreeAttempts = "free_attempt"
    }
}
