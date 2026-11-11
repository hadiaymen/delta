import SwiftUI
import Combine

/// View model driving the DELTA Cards screen, card stack interaction, and quick actions.
public final class CardsViewModel: ObservableObject {
    @Published public var selectedCardIndex: Int = 0

    // Modals & Action Sheet Presentation
    @Published public var showAddAccountSheet: Bool = false
    @Published public var showEditAccountSheet: Bool = false
    @Published public var showSplitSheet: Bool = false
    @Published public var showTransactionFormSheet: Bool = false
    @Published public var activeTransactionMode: TransactionFormSheet.FormMode = .create(type: .debit, initialRecipient: nil)
    @Published public var showOptionsSheet: Bool = false
    @Published public var showAlertNotice: Bool = false
    @Published public var alertMessage: String = ""

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var selectedCard: DummyAccountCard? {
        guard !service.cards.isEmpty,
              selectedCardIndex >= 0,
              selectedCardIndex < service.cards.count else {
            return service.cards.first
        }
        return service.cards[selectedCardIndex]
    }

    /// Handles exactly four quick actions: Split, Credit, Debit, Other
    public func handleQuickAction(_ action: CardQuickActionsView.ActionType) {
        guard let card = selectedCard else { return }

        switch action {
        case .split:
            showSplitSheet = true

        case .credit:
            activeTransactionMode = .create(type: .credit, initialRecipient: nil)
            showTransactionFormSheet = true

        case .debit:
            activeTransactionMode = .create(type: .debit, initialRecipient: nil)
            showTransactionFormSheet = true

        case .other:
            showOptionsSheet = true
        }
    }

    public func onAddAccountTapped() {
        showAddAccountSheet = true
    }

    public func onEditAccountTapped() {
        showEditAccountSheet = true
    }
}
