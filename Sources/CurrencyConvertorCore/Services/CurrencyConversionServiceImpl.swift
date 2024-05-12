
final class CurrencyConversionServiceImpl: CurrencyConversionService {
    // MARK: Lifecycle

    init(
        baseCurrencySymbol: CurrencySymbol,
        resourceService: CurrencyResourceService,
        logger: Logger
    ) {
        self.baseCurrencySymbol = baseCurrencySymbol
        self.resourceService = resourceService
        self.logger = logger
    }

    // MARK: Internal

    let baseCurrencySymbol: CurrencySymbol
    let resourceService: CurrencyResourceService
    let logger: Logger

    /// Converts the given `Money` amount to the specified target currency.
    ///
    /// - Parameters:
    ///   - source: The source `Money` object to convert from.
    ///   - target: The symbol of the target currency.
    /// - Returns: A `Money` object representing the converted amount in the target currency.
    /// - Throws: An error of type `CurrencyConversionError` if the conversion fails or if the
    /// target currency is not found.
    func convert(source: Money, target: CurrencySymbol) async throws -> Money {
        let cache = try await resourceService.fetchRate()
        if source.currencySymbol == baseCurrencySymbol {
            return try convertFromBaseCurrency(source: source, target: target, rates: cache)
        } else {
            return try convertFromOtherCurrency(source: source, target: target, rates: cache)
        }
    }

    /// Converts the given `Money` amount to multiple target currencies.
    ///
    /// - Parameters:
    ///   - source: The source `Money` object to convert from.
    ///   - targets: An array of target currency symbols.
    /// - Returns: An array of `Money` objects representing the converted amounts in the target
    /// currencies.  The order of the results matches the order of the target currency symbols.
    ///
    /// - Throws: An error of type `CurrencyConversionError` if the conversion fails or if a target
    /// currency is not found.
    func convert(source: Money, targets: [CurrencySymbol]) async throws -> [Money] {
        let cache = try await resourceService.fetchRate()
        return targets.compactMap { target in
            do {
                if source.currencySymbol == baseCurrencySymbol {
                    return try convertFromBaseCurrency(
                        source: source,
                        target: target,
                        rates: cache
                    )
                } else {
                    return try convertFromOtherCurrency(
                        source: source,
                        target: target,
                        rates: cache
                    )
                }
            } catch {
                logger.log(error, file: #file, line: #line)
                return nil
            }
        }
    }

    /// Fetches an array of all available currency symbols.
    ///
    /// - Returns: An array of currency symbols.
    /// - Throws: An error of type `CurrencyConversionError` if fetching the currency rates fails.
    func fetchAllCurrency() async throws -> [CurrencySymbol] {
        let cache = try await resourceService.fetchRate()
        return cache.keys.map { String($0) }
    }

    // MARK: Private

    private func convertFromBaseCurrency(
        source: Money,
        target: String,
        rates: Rates
    ) throws -> Money {
        guard let targetValue = rates[target] else {
            logger.log(CurrencyConversionError.canNotFindTargetCurrency, file: #file, line: #line)
            throw CurrencyConversionError.canNotFindTargetCurrency
        }
        guard let baseValue = Double(source.value) else {
            logger.log(CurrencyConversionError.invalidAmountInput, file: #file, line: #line)
            throw CurrencyConversionError.invalidAmountInput
        }
        let result = targetValue * baseValue
        return .init(value: formatted(result), currencySymbol: target)
    }

    private func convertFromOtherCurrency(
        source: Money,
        target: String,
        rates: Rates
    ) throws -> Money {
        guard let sourceToUSDRate = rates[source.currencySymbol],
              let targetToUSDRate = rates[target]
        else {
            logger.log(CurrencyConversionError.canNotFindTargetCurrency, file: #file, line: #line)
            throw CurrencyConversionError.canNotFindTargetCurrency
        }

        guard let sourceValue = Double(source.value) else {
            logger.log(CurrencyConversionError.canNotFindTargetCurrency, file: #file, line: #line)
            throw CurrencyConversionError.canNotFindTargetCurrency
        }
        let base = sourceValue / sourceToUSDRate

        let result = base * targetToUSDRate
        return .init(value: formatted(result), currencySymbol: target)
    }

    private func formatted(_ value: Double) -> String {
        String(value)
    }
}

// MARK: - CurrencyConversionError

enum CurrencyConversionError: Error, Equatable {
    case canNotFindTargetCurrency
    case invalidAmountInput
}
