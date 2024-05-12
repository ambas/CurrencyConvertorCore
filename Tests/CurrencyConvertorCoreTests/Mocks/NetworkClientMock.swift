

import Foundation
@testable import CurrencyConvertorCore

final class NetworkClientMock: NetworkClient {
    // MARK: Internal

    enum MockNetworkClientError: Error {
        case dataNotSetBeforeFetchDate
    }

    func data<Value>(
        _ type: Value.Type,
        path _: String
    ) async throws -> Value
        where Value: Decodable
    {
        guard let data else {
            throw MockNetworkClientError.dataNotSetBeforeFetchDate
        }
        return try JSONDecoder().decode(type.self, from: data)
    }

    /// Call this setup function before start network request
    func setupData<Value: Encodable>(_ value: Value) throws {
        let data = try JSONEncoder().encode(value)
        self.data = data
    }

    // MARK: Private

    private var data: Data?
}
