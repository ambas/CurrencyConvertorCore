
@testable import CurrencyConvertorCore
import XCTest

// MARK: - CurrencyResourceServiceTests

final class CurrencyResourceServiceTests: XCTestCase {
    // MARK: Internal

    var sut: CurrencyResourceService!

    override func setUp() {
        super.setUp()
        client = NetworkClientMock()
        cache = CacheMock()
    }

    override func tearDown() {
        sut = nil
        client = nil
        cache = nil
        super.tearDown()
    }

    func testFirstTimeCallResource() async throws {
        // Given
        cache.getCacheCalledReturns = nil
        try client.setupData(mockResult)
        sut = CurrencyResourceServiceImpl(
            client: client,
            cache: cache,
            currentDate: { mockDateWithIncacheExpireDuration },
            cacheExpireDuration: cacheExpireDuration
        )
        let expectation = ["USD": 1.00, "THB": 34.389399, "JPY": 141.78001997]

        // When
        let result = try await sut.fetchRate()

        // Then
        XCTAssertEqual(
            result,
            expectation,
            "The fetched currency rates do not match the expected result"
        )
        XCTAssertTrue(cache.getCacheCalled, "getCacheCalled should have been called")
        XCTAssertEqual(
            cache.updatedRate,
            expectation,
            "Cache was not updated with the fetched rates"
        )
    }

    func testCallWithIncacheExpireDurationPeriod() async throws {
        // Given
        cache.getCacheCalledReturns = .init(
            timestamp: mockCacheTimestamp,
            value: ["USD": 1.00, "THB": 34.389399, "JPY": 141.78001997]
        )
        sut = CurrencyResourceServiceImpl(
            client: client,
            cache: cache,
            currentDate: { mockDateWithIncacheExpireDuration },
            cacheExpireDuration: cacheExpireDuration
        )
        let expectation = ["USD": 1.00, "THB": 34.389399, "JPY": 141.78001997]

        // When
        let result = try await sut.fetchRate()

        // Then
        XCTAssertEqual(
            result,
            expectation,
            "The fetched currency rates do not match the expected result"
        )
        XCTAssertTrue(cache.getCacheCalled, "getCacheCalled should have been called")
        XCTAssertNil(
            cache.updatedRate,
            "Cache should not be updated as it's within cacheExpireDuration"
        )
        XCTAssertFalse(cache.updateCacheCalled, "updateCacheCalled should not have been called")
    }

    func testCallForExpiredCache() async throws {
        // Given
        try client.setupData(mockResult)
        cache.getCacheCalledReturns = .init(
            timestamp: mockCacheTimestamp,
            value: ["USD": 1.00, "THB": 34.389399, "JPY": 9999]
        )
        sut = CurrencyResourceServiceImpl(
            client: client,
            cache: cache,
            currentDate: { mockDateExpired },
            cacheExpireDuration: cacheExpireDuration
        )
        let expectation = ["USD": 1.00, "THB": 34.389399, "JPY": 141.78001997]

        // When
        let result = try await sut.fetchRate()

        // Then
        XCTAssertEqual(
            result,
            expectation,
            "The fetched currency rates do not match the expected result"
        )
        XCTAssertTrue(cache.getCacheCalled, "getCacheCalled should have been called")
        XCTAssertEqual(
            cache.updatedRate,
            expectation,
            "Cache should be updated with the fetched rates"
        )
    }

    // MARK: Private

    private var client: NetworkClientMock!

    private let cacheExpireDuration = 30

    private var cache: CacheMock!
}

// GMT: Sunday, 23 July 2023 06:00:11
private let mockCacheTimestamp = Date(timeIntervalSince1970: 1_690_092_011)

// GMT: Sunday, 23 July 2023 06:10:11
private let mockDateWithIncacheExpireDuration = Date(timeIntervalSince1970: 1_690_092_611)

// GMT: Sunday, 23 July 2023 06:40:11
private let mockDateExpired = Date(timeIntervalSince1970: 1_690_094_411)

private let mockResult = CurrencyRateResult(
    timestamp: Date(timeIntervalSince1970: 1_690_092_011),
    base: "USD",
    rates: ["USD": 1.00, "THB": 34.389399, "JPY": 141.78001997]
)
