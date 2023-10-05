extension SCKYCService {
    func iban() async -> Result<SCIbanResponse, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.ibans)
        return await client.performDecodable(request: request)
    }

    func hasIban() async -> Bool {
        switch await iban() {
        case .success(let result):
            if let iban = result.ibans?.first?.iban, !iban.isEmpty {
                return true
            } else {
                return false
            }
        case .failure(let error):
            print(error)
            return false
        }
    }
}

struct SCIbanResponse: Codable {
    let callerReferenceId: String
    let ibans: [Iban]?
    let referenceId: String
    let statusCode: Int
    let statusDescription: String

    enum CodingKeys: String, CodingKey {
        case callerReferenceId = "CallerReferenceID"
        case ibans = "IBANs"
        case referenceId = "ReferenceID"
        case statusCode = "StatusCode"
        case statusDescription = "StatusDescription"
    }
}

struct Iban: Codable {
    let id: String
    let iban: String
    let availableBalance: Int
    let balance: Int
    let bicSwift: String
    let bicSwiftForSepa: String
    let bicSwiftForSwift: String
    let createdDate: String
    let currency: String
    let maxTransactionAmount: Int
    let minTransactionAmount: Int
    let status, statusDescription: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case availableBalance = "AvailableBalance"
        case balance = "Balance"
        case bicSwift = "BicSwift"
        case bicSwiftForSepa = "BicSwiftForSepa"
        case bicSwiftForSwift = "BicSwiftForSwift"
        case createdDate = "CreatedDate"
        case currency = "Currency"
        case description = "Description"
        case id = "ID"
        case iban = "Iban"
        case maxTransactionAmount = "MaxTransactionAmount"
        case minTransactionAmount = "MinTransactionAmount"
        case status = "Status"
        case statusDescription = "StatusDescription"
    }
}
