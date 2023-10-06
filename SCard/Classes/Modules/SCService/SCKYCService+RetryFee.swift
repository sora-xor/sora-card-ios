extension SCKYCService {
    func retryFees() async -> Result<SCKYCRetryFee, NetworkingError> {
        guard await refreshAccessTokenIfNeeded() else {
            return .failure(.unauthorized)
        }
        let request = APIRequest(method: .get, endpoint: SCEndpoint.retryFee)
        return await client.performDecodable(request: request)
    }

    func updateFees() async {
        switch await retryFees() {
        case .success(let respose):
            self.retryFeeCache = respose.retryFee
            self.applicationFeeCache = respose.applicationFee
        case .failure(let error):
            print(error)
        }
    }
}

struct SCKYCRetryFee: Codable {
    let applicationFee: String
    let retryFee: String

    enum CodingKeys: String, CodingKey {
        case applicationFee = "application_fee"
        case retryFee = "retry_fee"
    }
}
