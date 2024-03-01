import Foundation

extension SCKYCService {
    func xorPriceInEuro() async -> Result<SCPriceResponse, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.price(pair: "xor_euro"))
        return await client.performDecodable(request: request, withAuthorization: false)
    }
}

struct SCPriceResponse: Codable {
    let pair: String
    let price: String
    let source: String
    let updateTime: Int64

    enum CodingKeys: String, CodingKey {
        case pair
        case price
        case source
        case updateTime = "update_time"
    }
}
