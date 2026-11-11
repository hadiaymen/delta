import SwiftUI
import Combine

/// Root dependency container for the DELTA application.
public final class AppEnvironment: ObservableObject {
    public let expenseService: ExpenseTrackingService

    public init(expenseService: ExpenseTrackingService = ExpenseTrackingService()) {
        self.expenseService = expenseService
    }
}

