import Foundation
import PayWingsOAuthSDK

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct HTTPHeader {
    let field: String
    let value: String
}

protocol Endpoint {
    var path: String { get }
}

final class APIRequest {
    let method: HTTPMethod
    let endpoint: Endpoint
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?

    init(method: HTTPMethod, endpoint: Endpoint) {
        self.method = method
        self.endpoint = endpoint
    }

    init(
        method: HTTPMethod,
        endpoint: Endpoint,
        body: Data
    ) {
        self.method = method
        self.endpoint = endpoint
        self.body = body
    }
}

public class SCAPIClient {

    init(
        baseURL: URL,
        baseAuth: String,
        token: SCToken,
        logLevels: NetworkingLogLevel = .debug
    ) {
        self.baseURL = baseURL
        self.baseAuth = baseAuth
        self.token = token
        self.logger.logLevels = logLevels
        self.headers = [
            .init(field: "appName", value: Bundle.main.appName),
            .init(field: "displayName", value: Bundle.main.displayName),
            .init(field: "language", value: Bundle.main.language),
            .init(field: "appBuild", value: Bundle.main.appBuild),
            .init(field: "appVersionLong", value: Bundle.main.appVersionLong),
        ]
    }

    private let apiKey = ""
    private let baseAuth: String
    private var token: SCToken
    private let baseURL: URL
    private let headers: [HTTPHeader]

    private let session = URLSession.shared
    private let logger = NetworkingLogger()

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()

    func set(token: SCToken) {
        self.token = token
    }

    func performDecodable<T: Decodable>(request: APIRequest, withAuthorization: Bool = true) async -> Result<T, NetworkingError> {
        let result = await perform(request: request, withAuthorization: withAuthorization)

        switch result {
        case let .success(data):
            do {
                let decodedData = try jsonDecoder.decode(T.self, from: data)
                return .success(decodedData)
            } catch let error {
                print(error)
                return .failure(.init(status: .cannotDecodeRawData))
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    func perform(request: APIRequest, withAuthorization: Bool) async -> Result<Data, NetworkingError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.port = baseURL.port
        urlComponents.path = baseURL.path
        if !apiKey.isEmpty {
            urlComponents.queryItems = (request.queryItems ?? []) + [URLQueryItem(name: "api_key", value: apiKey)]
        } else {
            urlComponents.queryItems = request.queryItems
        }

        guard let url = urlComponents.url?.appendingPathComponent(request.endpoint.path) else {
            return .failure(.init(status: .badURL))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        if withAuthorization {
            guard PayWingsOAuthClient.instance()?.isUserSignIn() ?? false else {
                return .failure(NetworkingError.unauthorized)
            }

            let (accessToken, _) = await withCheckedContinuation { continuation in
                PayWingsOAuthClient.instance()?.getNewAuthorizationData(
                    methodUrl: "/test", httpRequestMethod: .POST, completion: { authData in
                        continuation.resume(returning: (authData.accessTokenData?.accessToken, authData.dpop))
                        if authData.userSignInRequired ?? false {
                            print("SCAPIClient userSignInRequired")
                        }
                    })
            }

            if let accessToken = accessToken {
                urlRequest.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }
        }

        (headers + (request.headers ?? [])).forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
        }

        logger.log(request: urlRequest)

        var data: Data, response: URLResponse
        do {
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                session.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let response = response, let data = data {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: NetworkingError(status: .unknown))
                    }
                }
                .resume()
            }
        } catch let error as NSError {
            return .failure(.init(errorCode: error.code))
        }

        return processDataResponse(request: request, urlRequest: urlRequest, data: data, response: response)
    }

    func processDataResponse(
        request: APIRequest,
        urlRequest: URLRequest,
        data: Data,
        response: URLResponse
    ) -> Result<Data, NetworkingError> {
        logger.log(response: response, data: data)

        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            return .failure(.init(status: .unknown))
        }
        guard 200 ..< 299 ~= statusCode else {
            return .failure(.init(errorCode: statusCode))
        }

        return .success(data)
    }
}

struct SCToken: Codable, SecretDataRepresentable {
    static let empty: SCToken = .init(refreshToken: "", accessToken: "", accessTokenExpirationTime: 0)

    let refreshToken: String
    let accessToken: String
    let accessTokenExpirationTime: Int64

    init(refreshToken: String, accessToken: String, accessTokenExpirationTime: Int64) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.accessTokenExpirationTime = accessTokenExpirationTime
    }

    init?(secretData: SecretDataRepresentable?) {
        guard let secretUTF8String = secretData?.asUTF8String() else { return nil }
        let secretPrts = secretUTF8String.split(separator: "@").map { String($0) }
        guard secretPrts.count == 3  else { return nil }

        self.refreshToken = secretPrts[0]
        self.accessToken = secretPrts[1]
        self.accessTokenExpirationTime = Int64(secretPrts[2]) ?? 0
    }

    func asSecretData() -> Data? {
        "\(refreshToken)@\(accessToken)@\(accessTokenExpirationTime)".data(using: .utf8)
    }
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String { getInfo("CFBundleDisplayName")}
    public var language: String { getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String { getInfo("CFBundleIdentifier")}
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "" }
}
