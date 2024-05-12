
@testable import CurrencyConvertorCore
import XCTest

final class CurrencyConversionServiceIntegrationTests: XCTestCase {
    func testConvertCurrency() async throws {
        // Given
        let sourceMoney = Money(value: "100", currencySymbol: "USD")
        let targetCurrencySymbol = "EUR"

        let mockRates: Rates = [
            "USD": 1.0,
            "EUR": 0.85,
        ]

        let cacheMock = CacheMock()
        let networkClientMock = NetworkClientMock()
        cacheMock.getCacheCalledReturns = .init(timestamp: .now, value: mockRates)

        let mockResourceService = CurrencyResourceServiceImpl(
            client: networkClientMock,
            cache: cacheMock,
            currentDate: { Date() },
            cacheExpireDuration: 30
        )

        let currencyConversionService = CurrencyConversionServiceImpl(
            baseCurrencySymbol: "USD",
            resourceService: mockResourceService,
            logger: LoggerMock()
        )
        let expected = Money(value: "85.0", currencySymbol: targetCurrencySymbol)

        // When
        let convertedMoney = try await currencyConversionService.convert(
            source: sourceMoney,
            target: targetCurrencySymbol
        )

        // Then
        XCTAssertEqual(convertedMoney, expected, "Currency value conversion failed")
    }

    func testConvertCurrencyForExpiredCache() async throws {
        // Given
        let sourceMoney = Money(value: "100", currencySymbol: "USD")
        let targetCurrencySymbol = "EUR"

        let mockRates: Rates = [
            "USD": 1.0,
            "EUR": 0.85,
        ]

        let cacheMock = CacheMock()
        let dataMock = CurrencyRateResult(timestamp: .now, base: "USD", rates: mockRates)
        let networkClientMock = NetworkClientMock()
        try networkClientMock.setupData(dataMock)

        let mockResourceService = CurrencyResourceServiceImpl(
            client: networkClientMock,
            cache: cacheMock,
            currentDate: { Date() },
            cacheExpireDuration: -1
        )

        let currencyConversionService = CurrencyConversionServiceImpl(
            baseCurrencySymbol: "USD",
            resourceService: mockResourceService,
            logger: LoggerMock()
        )

        // When
        let convertedMoney = try await currencyConversionService.convert(
            source: sourceMoney,
            target: targetCurrencySymbol
        )
        let expected = Money(value: "85.0", currencySymbol: targetCurrencySymbol)

        // Then
        XCTAssertEqual(convertedMoney, expected, "Currency value conversion failed")
        XCTAssertTrue(cacheMock.updateCacheCalled, "Expected updateCache to be called")
    }

    func testConvertMultipleCurrencies() async throws {
        // Given
        let sourceMoney = Money(value: "100", currencySymbol: "USD")
        let targetCurrencySymbols = ["EUR", "THB", "JPY", "USD"]

        let mockRates: Rates = [
            "USD": 1.00,
            "EUR": 0.85,
            "THB": 34.18,
            "JPY": 141.145,
        ]

        let cacheMock = CacheMock()
        let networkClientMock = NetworkClientMock()
        cacheMock.getCacheCalledReturns = .init(timestamp: .now, value: mockRates)

        let mockResourceService = CurrencyResourceServiceImpl(
            client: networkClientMock,
            cache: cacheMock,
            currentDate: { Date() },
            cacheExpireDuration: 30
        )

        let currencyConversionService = CurrencyConversionServiceImpl(
            baseCurrencySymbol: "USD",
            resourceService: mockResourceService,
            logger: LoggerMock()
        )
        let expected = [
            Money(value: "85.0", currencySymbol: "EUR"),
            Money(value: "3418.0", currencySymbol: "THB"),
            Money(value: "14114.500000000002", currencySymbol: "JPY"),
            Money(value: "100.0", currencySymbol: "USD"),
        ]

        // When
        let convertedMoney = try await currencyConversionService.convert(
            source: sourceMoney,
            targets: targetCurrencySymbols
        )

        // Then
        XCTAssertEqual(convertedMoney, expected, "Multiple currency conversion failed.")
    }
}
