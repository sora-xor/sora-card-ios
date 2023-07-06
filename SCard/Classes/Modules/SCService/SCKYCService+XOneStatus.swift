import Foundation

extension SCKYCService {
    func xOneStatus(paymentId: String) async -> Result<SCKYCStatusResponse, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.xOneStatus(paymentId: paymentId))
        return await client.performDecodable(request: request)
    }

    func isXOneWidgetAailable() async -> Bool {
        let client = SCAPIClient(
            baseURL: URL(string: "https://dev.x1ex.com/widgets/sdk.js")!,
            baseAuth: "",
            token: .empty
        )
        let result = await client.perform(request: .init(method: .get, endpoint: SCEndpoint.empty))
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
