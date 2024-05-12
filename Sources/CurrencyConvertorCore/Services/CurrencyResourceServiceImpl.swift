
import Foundation

struct CurrencyResourceServiceImpl: CurrencyResourceService {
    // MARK: Internal

    enum Constants {
        static let path = "latest.json"
    }

    let client: NetworkClient
    let cache: RatesCache
    let currentDate: () -> Date
    let cacheExpireDuration: Int

    /// Fetches the latest currency rates from the API or the cache, if available.
    ///
    /// If a valid cache is present and has not expired, the function returns the cached currency
    /// rates.
    /// Otherwise, the function fetches new currency rates from the API, saves them to the
    /// cache, and returns them.
    ///
    /// - Returns: A dictionary representing the currency rates, where the keys are currency symbols
    ///            and the values are the corresponding exchange rates relative to the base
    /// currency.
    ///
    /// - Throws: An error of type `CurrencyRateFetchError` if there is an issue fetching the
    /// currency rates or updating the cache.
    func fetchRate() async throws -> Rates {
        guard let cacheResult = try await cache.getCache(),
              !cacheExpired(current: currentDate(), lastTimeCache: cacheResult.timestamp)
        else {
            // In case there is no cache or cache is expired.
            // Request for new rates and save to cache
            let currencyRateResult = try await client.data(
                CurrencyRateResult.self,
                path: Constants.path
            )
            try await cache.updateCache(currencyRateResult.rates)
            return currencyRateResult.rates
        }

        return cacheResult.value
    }

    // MARK: Private

    private func cacheExpired(current: Date, lastTimeCache: Date) -> Bool {
        let diffSeconds = Int(current.timeIntervalSince1970 - lastTimeCache.timeIntervalSince1970)
        let minutes = diffSeconds / 60
        return minutes >= Int(cacheExpireDuration)
    }
}
