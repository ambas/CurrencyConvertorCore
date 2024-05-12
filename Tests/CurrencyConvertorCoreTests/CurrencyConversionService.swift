
@testable import CurrencyConvertorCore
import XCTest

// MARK: - CurrencyConversionServiceTests

final class CurrencyConversionServiceTests: XCTestCase {
    var sut: CurrencyConversionServiceImpl!
    var resourceServiceMock: ResourceServiceMock!
    var loggerMock: LoggerMock!
    let baseCurrencySymbol = "USD"

    override func setUp() {
        super.setUp()
        loggerMock = LoggerMock()
        resourceServiceMock = ResourceServiceMock()
        sut = CurrencyConversionServiceImpl(
            baseCurrencySymbol: baseCurrencySymbol,
            resourceService: resourceServiceMock,
            logger: loggerMock
        )
    }

    override func tearDown() {
        sut = nil
        resourceServiceMock = nil
        super.tearDown()
    }

    func testConvertUSDCurrency() async throws {
        // Given
        let targetSymbol = "JPY"

        // When
        let result1 = try await sut.convert(
            source: .init(value: "1", currencySymbol: baseCurrencySymbol),
            target: targetSymbol
        )
        let result2 = try await sut.convert(
            source: .init(value: "2", currencySymbol: baseCurrencySymbol),
            target: targetSymbol
        )

        // Then
        XCTAssertEqual(result1.value.dropLast(6), "141.78", "USD to JPY conversion failed")
        XCTAssertEqual(
            result1.currencySymbol,
            targetSymbol,
            "Currency symbol mismatch after conversion"
        )
        XCTAssertEqual(result2.value.dropLast(6), "283.56", "USD to JPY conversion failed")
        XCTAssertEqual(
            result2.currencySymbol,
            targetSymbol,
            "Currency symbol mismatch after conversion"
        )
    }

    func testConvertOtherCurrency() async throws {
        // Given
        let targetSymbol = "THB"

        // When
        let result = try await sut.convert(
            source: .init(value: "100", currencySymbol: "JPY"),
            target: targetSymbol
        )

        // Then
        XCTAssertEqual(result.value.dropLast(13), "24.25", "JPY to THB conversion failed")
        XCTAssertEqual(
            result.currencySymbol,
            targetSymbol,
            "Currency symbol mismatch after conversion"
        )
    }

    func testConvertMultipleTargetCurrency() async throws {
        // Given
        let targetSymbols = ["THB", "SGD"]

        // When
        let result = try await sut.convert(
            source: .init(value: "100", currencySymbol: "JPY"),
            targets: targetSymbols
        )

        // Then
        XCTAssertEqual(result[0].value.dropLast(13), "24.25", "JPY to THB conversion failed")
        XCTAssertEqual(result[1].value.dropLast(13), "0.938", "JPY to SGD conversion failed")
        XCTAssertEqual(
            result[0].currencySymbol,
            targetSymbols[0],
            "Currency symbol mismatch after THB conversion"
        )
        XCTAssertEqual(
            result[1].currencySymbol,
            targetSymbols[1],
            "Currency symbol mismatch after SGD conversion"
        )
    }

    func testConvertToNotExistCurrency() async throws {
        // Given
        let targetSymbol = "KYD"

        // When
        do {
            _ = try await sut.convert(
                source: .init(value: "100", currencySymbol: "JPY"),
                target: targetSymbol
            )
        } catch {
            // Then
            XCTAssertEqual(
                error as? CurrencyConversionError,
                .canNotFindTargetCurrency,
                "Unexpected error while converting to non-existent currency"
            )
            XCTAssertTrue(loggerMock.logCalled)
        }
    }
}

// MARK: - ResourceServiceMock

final class ResourceServiceMock: CurrencyResourceService {
    // MARK: Internal

    func fetchRate() async throws -> Rates {
        return mockRate
    }

    // MARK: Private

    private let mockRate = ["JPY": 141.78001997, "THB": 34.389399, "SGD": 1.3306]
}
