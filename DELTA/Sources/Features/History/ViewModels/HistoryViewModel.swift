import SwiftUI
import Combine

/// View model driving the History ledger screen with the 4 required category filters plus All view,
/// date grouping (newest first), and Undo state management.
public final class HistoryViewModel: ObservableObject {
    @Published public var selectedFilter: FilterOption = .all
    @Published public var searchQuery: String = ""
    @Published public var showUndoBanner: Bool = false
    @Published public var undoCountdownSeconds: Int = 5
    @Published public var activeDetailTransaction: TransactionItem? = nil
    @Published public var activeDetailSplit: SplitRecord? = nil

    private var undoTimer: AnyCancellable?

    public enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case debit = "Debit"
        case credit = "Credit"
        case split = "Split"
        case other = "Other"

        public var id: String { rawValue }

        public var iconName: String {
            switch self {
            case .all:
                return "list.bullet"
            case .debit:
                return DeltaIcons.transactionOutflow
            case .credit:
                return DeltaIcons.transactionInflow
            case .split:
                return "arrow.triangle.branch"
            case .other:
                return "questionmark.circle"
            }
        }
    }

    public let service: ExpenseTrackingService

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    /// Filtered transactions based on selected filter and search query
    public var filteredTransactions: [TransactionItem] {
        service.transactions.filter { item in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .debit:
                matchesFilter = item.type == .debit
            case .credit:
                matchesFilter = item.type == .credit
            case .split:
                matchesFilter = item.linkedSplitID != nil
            case .other:
                matchesFilter = item.type == .other
            }

            if searchQuery.isEmpty {
                return matchesFilter
            } else {
                let matchesTitle = item.title.localizedCaseInsensitiveContains(searchQuery)
                let matchesTrxID = item.trxID.localizedCaseInsensitiveContains(searchQuery)
                let matchesDesc = item.descriptionText?.localizedCaseInsensitiveContains(searchQuery) ?? false
                let matchesNote = item.note?.localizedCaseInsensitiveContains(searchQuery) ?? false
                let matchesAccount = item.accountName.localizedCaseInsensitiveContains(searchQuery)
                return matchesFilter && (matchesTitle || matchesTrxID || matchesDesc || matchesNote || matchesAccount)
            }
        }
    }

    /// Filtered splits for the dedicated Split view
    public var filteredSplits: [SplitRecord] {
        service.splits.filter { split in
            if searchQuery.isEmpty {
                return true
            } else {
                return split.title.localizedCaseInsensitiveContains(searchQuery) ||
                       split.payerName.localizedCaseInsensitiveContains(searchQuery) ||
                       split.participants.contains(where: { $0.name.localizedCaseInsensitiveContains(searchQuery) })
            }
        }
    }

    /// Groups transactions by calendar date in strict descending order (newest date first, newest time first)
    public var groupedTransactions: [(dateLabel: String, date: Date, items: [TransactionItem])] {
        let calendar = Calendar.current
        let items = filteredTransactions

        // Group by start of calendar day for exact chronological ordering
        let groupedByDay = Dictionary(grouping: items) { item in
            calendar.startOfDay(for: item.timestamp)
        }

        // Sort days descending (newest date first)
        let sortedDays = groupedByDay.keys.sorted(by: >)

        return sortedDays.map { dayDate in
            let dayItems = (groupedByDay[dayDate] ?? []).sorted { $0.timestamp > $1.timestamp }
            let label = formattedDateLabel(for: dayDate)
            return (dateLabel: label, date: dayDate, items: dayItems)
        }
    }

    private func formattedDateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM dd, yyyy"
            return formatter.string(from: date)
        }
    }

    // MARK: - Undo Toast Management
    public func triggerUndoToast() {
        showUndoBanner = true
        undoCountdownSeconds = 5
        undoTimer?.cancel()

        undoTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.undoCountdownSeconds > 1 {
                    self.undoCountdownSeconds -= 1
                } else {
                    self.dismissUndoToast()
                }
            }
    }

    public func dismissUndoToast() {
        showUndoBanner = false
        undoTimer?.cancel()
        undoTimer = nil
        service.finalizeDeletion()
    }

    public func performUndo() {
        Task {
            await service.undoLastDeletion()
            await MainActor.run {
                showUndoBanner = false
                undoTimer?.cancel()
                undoTimer = nil
            }
        }
    }
}
