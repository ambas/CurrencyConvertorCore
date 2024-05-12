
// MARK: - CurrencyConversionServiceFake

final class CurrencyConversionServiceFake: CurrencyConversionService {
    // MARK: Lifecycle

    init(testCaseID: String?) {
        switch testCaseID {
        case "error_case":
            convertReturnsStack = [resultMock, resultMock, resultMock, resultMock, nil]
        case "happy_case":
            convertReturnsStack = [resultMock, resultMock, resultMock, resultMock]
        default: convertReturnsStack = []
        }
    }

    // MARK: Internal

    var convertReturnsStack: [[Money]?]
    let resultMock: [Money] = [
        .init(value: "1.0", currencySymbol: "USD"),
        .init(value: "1.0", currencySymbol: "THB"),
        .init(value: "1.0", currencySymbol: "JPY"),
    ]

    func convert(source _: Money, targets _: [String]) async throws -> [Money] {
        if let result = convertReturnsStack.popLast(), let moneys = result {
            return moneys
        } else {
            throw ErrorMock.sampleError
        }
    }

    func fetchAllCurrency() async throws -> [String] {
        if let result = convertReturnsStack.popLast(), let moneys = result {
            return moneys.map { $0.currencySymbol }
        } else {
            throw ErrorMock.sampleError
        }
    }
}

// MARK: - AmountValidationServiceFake

struct AmountValidationServiceFake: AmountValidationService {
    func makeValidatedAmount(currentAmount _: String, newValue _: String) throws -> String {
        return ""
    }

    func makeAmountAfterDelete(currentAmount _: String) -> String {
        return ""
    }
}

// MARK: - ErrorMock

enum ErrorMock: Error {
    case sampleError
}


public protocol CurrencyConversionService {
    /// Converts the given `Money` amount to the specified target currency.
    ///
    /// - Parameters:
    ///   - source: The source `Money` object to convert from.
    ///   - target: The symbol of the target currency.
    /// - Returns: A `Money` object representing the converted amount in the target currency.
    /// - Throws: An error of type `CurrencyConversionError` if the conversion fails or if the
    /// target currency is not found.
    func convert(source: Money, targets: [String]) async throws -> [Money]

    /// Converts the given `Money` amount to multiple target currencies.
    ///
    /// - Parameters:
    ///   - source: The source `Money` object to convert from.
    ///   - targets: An array of target currency symbols.
    /// - Returns: An array of `Money` objects representing the converted amounts in the target
    /// currencies.
    ///            The order of the results matches the order of the target currency symbols.
    /// - Throws: An error of type `CurrencyConversionError` if the conversion fails or if a target
    /// currency is not found.
    func fetchAllCurrency() async throws -> [String]
}

public struct Money: Identifiable, Codable, Equatable {
    // MARK: Lifecycle

    public init(value: String, currencySymbol: CurrencySymbol) {
        self.value = value
        self.currencySymbol = currencySymbol
    }

    // MARK: Public

    public let value: String
    public let currencySymbol: CurrencySymbol

    public var id: String { currencySymbol }
}

public typealias Rates = [CurrencySymbol: Double]
public typealias CurrencySymbol = String
