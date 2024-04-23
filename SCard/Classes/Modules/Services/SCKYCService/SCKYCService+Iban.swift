extension SCKYCService {

    func hasIban() async -> Bool {
        await iban() != nil
    }

    func ibanStream() async -> AsyncStream<Loadable<[Iban]?, NetworkingError>> {
        await IbanStorage.shared.ibansStream.stream
    }

    func iban() async -> Iban? {
        switch await IbanStorage.shared.ibansStream.wrappedValue {
        case .inited:
            await IbanStorage.shared.set(ibans: .loading(nil))
            switch await fetchIban() {
            case .success(let success):
                return success.ibans?.first
            case .failure:
                return nil // TODO: retry ?
            }
        case .loading(let data):
            return data??.first
        case .success(let data):
            return data?.first
        case .failure:
            return nil // TODO: retry ?
        }
    }

    func fetchIban() async -> Result<SCIbanResponse, NetworkingError> {
        let request = APIRequest(method: .get, endpoint: SCEndpoint.ibans)
        let result: Result<SCIbanResponse, NetworkingError> = await client.performDecodable(request: request)
        switch result {
        case .success(let success):
            await IbanStorage.shared.set(ibans: .success(success.ibans))
        case .failure(let error):
            await IbanStorage.shared.set(ibans: .failure(error))
        }
        return result
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

    enum Status: String, Codable {
        case active = "A"
        case suspendedByUser = "U"
        case suspendedBySystem = "S"
        case closed = "C"
    }

    let id: String
    let iban: String
    var availableBalance: Int
    let balance: Int
    let bicSwift: String
    let bicSwiftForSepa: String
    let bicSwiftForSwift: String
    let createdDate: String
    let currency: String
    let maxTransactionAmount: Int
    let minTransactionAmount: Int
    let status: Status
    let statusDescription: String
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
