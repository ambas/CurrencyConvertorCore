
@testable import CurrencyConvertorCore
import XCTest

final class AmountValidationServiceTests: XCTestCase {
    // MARK: Internal

    var logger: Logger!

    override func setUp() {
        super.setUp()
        logger = LoggerMock()
        sut = AmountValidationServiceImpl(logger: logger)
    }

    func testAddDot() throws {
        // Given
        let currentAmount = "0"

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".")

        // Then
        XCTAssertEqual(result, "0.", "Adding dot to '0' failed")
    }

    func testAddValueAfterDot() throws {
        // Given
        let currentAmount = "0."

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "1")

        // Then
        XCTAssertEqual(result, "0.1", "Adding value after dot ('0.1') failed")
    }

    func testAddValueAfterSingleZero() throws {
        // Given
        let currentAmount = "0"

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "1")

        // Then
        XCTAssertEqual(result, "1", "Adding value after single zero ('1') failed")
    }

    func testAddValueAfterNonZero() throws {
        // Given
        let currentAmount = "1"

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "1")

        // Then
        XCTAssertEqual(result, "11", "Adding value after non-zero ('11') failed")
    }

    func testAddDotAfterDot() throws {
        // Given
        let currentAmount = "1."

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".")

        // Then
        XCTAssertEqual(result, "1.", "Adding dot after dot ('1.') failed")
    }

    func testAddDotAfterDotInside() throws {
        // Given
        let currentAmount = "1.1"

        // When
        let result = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".")

        // Then
        XCTAssertEqual(result, "1.1", "Adding dot after dot inside ('1.1') failed")
    }

    func testWrongInput() throws {
        // Given
        let currentAmount = "1.1"

        // Then
        XCTAssertThrowsError(
            try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "1."),
            "Adding dot after value ('1.1') should throw an error"
        )
        XCTAssertThrowsError(
            try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".1"),
            "Adding value after dot ('.1') should throw an error"
        )
        XCTAssertThrowsError(
            try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "1."),
            "Adding dot after value ('1.') should throw an error"
        )
        XCTAssertThrowsError(
            try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "#"),
            "Adding invalid input ('#') should throw an error"
        )
    }

    func testExceedNineDigitInteger() throws {
        // Given
        let currentAmount = "999999999"

        // When
        let result1 = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "9")
        let result2 = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".")

        // Then
        XCTAssertEqual(
            result1,
            currentAmount,
            "The result should be equal to the current amount since the newValue '9' exceeds the nine-digit integer"
        )
        XCTAssertEqual(
            result2,
            currentAmount,
            "The result should be equal to the current amount since the newValue '.' exceeds the nine-digit integer"
        )
    }

    func testExceedNineDigitDouble() throws {
        // Given
        let currentAmount = "99999999.9"

        // When
        let result1 = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: "9")
        let result2 = try sut.makeValidatedAmount(currentAmount: currentAmount, newValue: ".")

        // Then
        XCTAssertEqual(
            result1,
            currentAmount,
            "The result should be equal to the current amount since the newValue '9' exceeds the nine-digit double."
        )
        XCTAssertEqual(
            result2,
            currentAmount,
            "The result should be equal to the current amount since the newValue '.' exceeds the nine-digit double."
        )
    }

    func testDeletionFromNonZeroMultiDigitAmount() {
        // Given
        let currentAmount = "12345"

        // When
        let result = sut.makeAmountAfterDelete(currentAmount: currentAmount)

        // Then
        XCTAssertEqual(result, "1234", "Failed to delete from non-zero multi-digit amount")
    }

    func testDeletionFromZeroAmount() {
        // Given
        let currentAmount = "0"

        // When
        let result = sut.makeAmountAfterDelete(currentAmount: currentAmount)

        // Then
        XCTAssertEqual(result, "0", "Deletion from zero amount should result in zero")
    }

    func testDeletionFromSingleDigitNonZeroAmount() {
        // Given
        let currentAmount = "5"

        // When
        let result = sut.makeAmountAfterDelete(currentAmount: currentAmount)

        // Then
        XCTAssertEqual(result, "0", "Failed to delete from single-digit non-zero amount")
    }

    func testDeletionFromSingleDigitZeroAmount() {
        // Given
        let currentAmount = "0"

        // When
        let result = sut.makeAmountAfterDelete(currentAmount: currentAmount)

        // Then
        XCTAssertEqual(result, "0", "Deletion from single-digit zero amount should result in zero")
    }

    // MARK: Private

    private var sut: AmountValidationServiceImpl!
}
