import SwiftUI
import Combine

/// View model driving the DELTA Home Dashboard and transaction form workflows.
public final class HomeViewModel: ObservableObject {
    @Published public var showTransactionFormSheet: Bool = false
    @Published public var activeFormMode: TransactionFormSheet.FormMode = .create(type: .debit, initialRecipient: nil)

    @Published public var showPeopleDirectorySheet: Bool = false
    @Published public var showAllTransactionsSheet: Bool = false
    @Published public var showNotificationsSheet: Bool = false
    @Published public var showTrophyMilestone: Bool = false

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public func onCreditTapped() {
        activeFormMode = .create(type: .credit, initialRecipient: nil)
        showTransactionFormSheet = true
    }

    public func onDebitTapped() {
        activeFormMode = .create(type: .debit, initialRecipient: nil)
        showTransactionFormSheet = true
    }

    public func onSelectPerson(_ person: ContactItem) {
        activeFormMode = .create(type: .debit, initialRecipient: person.name)
        showTransactionFormSheet = true
    }

    public func onSelectTransaction(_ item: TransactionItem) {
        activeFormMode = .edit(transaction: item)
        showTransactionFormSheet = true
    }

    public func onViewAllPeopleTapped() {
        showPeopleDirectorySheet = true
    }

    public func onViewAllTransactionsTapped() {
        showAllTransactionsSheet = true
    }

    public func onNotificationTapped() {
        showNotificationsSheet = true
    }

    public func onTrophyTapped() {
        showTrophyMilestone = true
    }

    public func retryLoading() {
        Task {
            await service.loadData()
        }
    }
}
