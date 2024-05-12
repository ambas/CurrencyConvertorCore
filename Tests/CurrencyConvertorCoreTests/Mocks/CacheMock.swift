
@testable import CurrencyConvertorCore

// MARK: - MockCache

final class CacheMock: RatesCache {
    var getCacheCalledReturns: CacheValue<Rates>?
    var getCacheCalled = false
    var updatedRate: Rates?
    var updateCacheCalled = false

    func getCache() -> CacheValue<Rates>? {
        getCacheCalled = true
        return getCacheCalledReturns
    }

    func updateCache(_ rates: Rates?) {
        updatedRate = rates
        updateCacheCalled = true
    }
}
