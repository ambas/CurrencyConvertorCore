
import Foundation

final class AmountValidationServiceImpl: AmountValidationService {
    // MARK: Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: Internal

    let logger: Logger

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
    func makeValidatedAmount(currentAmount: String, newValue: String) throws -> String {
        if currentAmount.filter({ $0 != "." && $0 != "," }).count >= 9 {
            return currentAmount
        } else if newValue == "." && currentAmount.contains(".") {
            return currentAmount
        } else if newValue == "." {
            return currentAmount + "."
        } else if currentAmount == "0" {
            return newValue
        } else if Double(currentAmount + newValue) != nil {
            return currentAmount + newValue
        } else {
            logger.log(ValidateError.invalidAmountInput, file: #file, line: #line)
            throw ValidateError.invalidAmountInput
        }
    }

    /// Returns the new amount after deleting the last digit.
    ///
    /// This function takes the current amount as a string representation and returns the new amount
    /// after deleting the last digit. If the current amount is "0" or has only one character
    /// the function returns "0" to avoid empty amounts.
    ///
    /// - Parameter currentAmount: The current amount as a string representation.
    /// - Returns: The new amount as a string after deleting the last digit.
    func makeAmountAfterDelete(currentAmount: String) -> String {
        if currentAmount == "0" || currentAmount.count == 1 {
            return "0"
        } else {
            return String(currentAmount.dropLast())
        }
    }
}

// MARK: - ValidateError

enum ValidateError: Error {
    case invalidAmountInput
}

public protocol Logger {
    func log(_ message: Error, file: StaticString, line: UInt)
}
