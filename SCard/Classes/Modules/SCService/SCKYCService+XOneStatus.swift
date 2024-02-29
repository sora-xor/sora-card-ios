import Foundation

extension SCKYCService {
    func xOneStatus(paymentId: String) async -> Result<SCUserState, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.xOneStatus(paymentId: paymentId))
        return await client.performDecodable(request: request, withAuthorization: false)
    }

    func isXOneWidgetAailable() async -> Bool {
        let client = SCAPIClient(
            baseURL: URL(string: "https://\(URL(string: config.xOneEndpoint)!.host!)")!,
            baseAuth: "",
            bearerProvider: nil
        )
        let result = await client.perform(request: .init(method: .get, endpoint: SCEndpoint.xOneWidget), withAuthorization: false)
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
