
import Foundation

/// The core functionality of a currency converter app.
public final class CurrencyConvertorCore {
    // MARK: Lifecycle

    /// Initializes a new instance of the currency converter core.
        /// - Parameters:
        ///   - amountValidationService: The service responsible for validating currency amounts.
        ///   - currencyConversionService: The service responsible for currency conversion.
    init(
        amountValidationService: AmountValidationService,
        currencyConversionService: CurrencyConversionService
    ) {
        self.amountValidationService = amountValidationService
        self.currencyConversionService = currencyConversionService
    }

    // MARK: Public

    public final class Dependencies {
        // MARK: Lifecycle

        /// Initializes a new instance of the dependencies for the currency converter core.
        /// - Parameters:
        ///   - currentDate: A closure providing the current date. The closure can be replace with mock date to make it testable.
        ///   - cache: The cache to store currency exchange rates.
        ///   - logger: The logger used for logging.
        ///   - baseCurrency: The base currency for currency conversion.
        ///   - cacheExpireDuration: The duration in minute after which the cache should expire.
        ///   - baseAPIURL: The base URL for currency conversion API. Use fake url when working in testing environment
        public init(
            currentDate: @escaping () -> Date,
            cache: RatesCache,
            logger: Logger,
            baseCurrency: String,
            cacheExpireDuration: Int,
            baseAPIURL: URL,
            appIDValue: String
        ) {
            self.currentDate = currentDate
            self.cache = cache
            self.logger = logger
            self.baseCurrency = baseCurrency
            self.cacheExpireDuration = cacheExpireDuration
            self.baseAPIURL = baseAPIURL
            self.appIDValue = appIDValue
        }

        // MARK: Internal

        let currentDate: () -> Date
        let cache: RatesCache
        let logger: Logger
        let baseCurrency: String
        let cacheExpireDuration: Int
        let baseAPIURL: URL
        let appIDValue: String
    }

    public struct Configuration {
        let baseURL: URL
        let cacheExpirePolicy: TimeInterval
    }

    public let currencyConversionService: CurrencyConversionService
    public let amountValidationService: AmountValidationService
}
