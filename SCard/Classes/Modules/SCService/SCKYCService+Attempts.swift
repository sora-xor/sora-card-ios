extension SCKYCService {
    func kycAttempts() async -> Result<SCKYCAtempts, NetworkingError> {
        guard await refreshAccessTokenIfNeeded() else {
            return .failure(.unauthorized)
        }
        let request = APIRequest(method: .get, endpoint: SCEndpoint.kycAttemptCount)
        return await client.performDecodable(request: request)
    }
}
