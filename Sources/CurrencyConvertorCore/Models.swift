//
//  File.swift
//  
//
//  Created by Ambas Chobsanti on 2024/05/12.
//

import Foundation


public protocol NetworkClient {
    func data<Value: Decodable>(_ type: Value.Type, path: String) async throws -> Value
}

public protocol AmountValidationService {
    /// Validates and constructs the new amount after a new digit input.
    ///
    /// This function takes the current amount and the new value to be appended and returns the new
    /// amount
    /// after validating and applying the input rules.
    ///
    /// - Parameters:
    ///   - currentAmount: The current amount as a string representation.
    ///   - newValue: The new value to be appended to the current amount.
    /// - Returns: The new amount as a string after applying the input validation rules and
    /// appending the new value.
    /// - Throws: An error of type `ValidateError` if the new input is invalid based on the
    /// validation rules.
    func makeValidatedAmount(currentAmount: String, newValue: String) throws -> String

    /// Returns the new amount after deleting the last digit.
    ///
    /// This function takes the current amount as a string representation and returns the new amount
    /// after deleting the last digit. If the current amount is "0" or has only one character
    /// (single digit),
    /// the function returns "0" to avoid empty amounts.
    ///
    /// - Parameter currentAmount: The current amount as a string representation.
    /// - Returns: The new amount as a string after deleting the last digit.
    func makeAmountAfterDelete(currentAmount: String) -> String
}

public protocol CurrencyResourceService {
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
    /// - Throws: An error of type `CurrencyRateFetchError` if there is an issue fetching the
    /// currency rates
    ///           or updating the cache.
    func fetchRate() async throws -> Rates
}

public struct CurrencyRateResult: Codable {
    // MARK: Lifecycle

    public init(timestamp: Date, base: String, rates: Rates) {
        self.timestamp = timestamp
        self.base = base
        self.rates = rates
    }

    // MARK: Public

    public let timestamp: Date
    public let base: String
    public let rates: Rates
}

public protocol RatesCache {
    func getCache() async throws -> CacheValue<Rates>?
    func updateCache(_ rates: Rates?) async throws
}

public struct CacheValue<Value: Codable>: Codable {
    // MARK: Lifecycle

    public init(timestamp: Date, value: Value) {
        self.timestamp = timestamp
        self.value = value
    }

    // MARK: Public

    public let timestamp: Date
    public let value: Value
}
