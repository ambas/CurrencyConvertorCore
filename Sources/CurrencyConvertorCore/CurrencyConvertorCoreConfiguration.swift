

public extension CurrencyConvertorCore {
    static func live(dependency: Dependencies) -> CurrencyConvertorCore {
        .init(
            amountValidationService: AmountValidationServiceImpl(logger: dependency.logger),
            currencyConversionService: CurrencyConversionServiceImpl(
                baseCurrencySymbol: dependency.baseCurrency,
                resourceService: CurrencyResourceServiceImpl(
                    client: LiveNetworkClient(baseURL: dependency.baseAPIURL, appIDValue: dependency.appIDValue),
                    cache: dependency.cache,
                    currentDate: dependency.currentDate,
                    cacheExpireDuration: dependency.cacheExpireDuration
                ),
                logger: dependency.logger
            )
        )
    }

    static func uiTest(_ testCaseID: String?) -> CurrencyConvertorCore {
        .init(
            amountValidationService: AmountValidationServiceFake(),
            currencyConversionService: CurrencyConversionServiceFake(testCaseID: testCaseID)
        )
    }
}
