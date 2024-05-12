
import Foundation

struct LiveNetworkClient: NetworkClient {
    enum Constants {
        static let appIDKey = "app_id"
    }

    let baseURL: URL
    let appIDValue: String

    func data<Value>(
        _ type: Value.Type,
        path: String
    ) async throws -> Value
        where Value: Decodable
    {
        var url = baseURL
        url.append(path: path)

        // Inject App id for any request
        url.append(queryItems: [.init(name: Constants.appIDKey, value: appIDValue)])
        let (data, response) = try await URLSession.shared.data(for: .init(url: url))

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkClientError.serverResponseWithError
        }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

// MARK: - NetworkClientError

enum NetworkClientError: Error {
    case serverResponseWithError
}
