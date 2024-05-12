
@testable import CurrencyConvertorCore

final class LoggerMock: Logger {
    var logCalled = false

    func log(_: Error, file _: StaticString, line _: UInt) {
        logCalled = true
    }
}
