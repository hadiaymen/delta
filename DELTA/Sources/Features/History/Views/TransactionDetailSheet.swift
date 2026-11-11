import SwiftUI

/// Detailed view of a single logged transaction displaying complete metadata,
/// category, account allocation, conversion options for Other, and an accessible Delete workflow.
public struct TransactionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let transaction: TransactionItem
    public var onDeleted: (() -> Void)? = nil

    @State private var showDeleteConfirmation: Bool = false
    @State private var isEditing: Bool = false
    @State private var showingLinkedSplit: SplitRecord? = nil

    public init(
        service: ExpenseTrackingService,
        transaction: TransactionItem,
        onDeleted: (() -> Void)? = nil
    ) {
        self.service = service
        self.transaction = transaction
        self.onDeleted = onDeleted
    }

    public var body: some View {
        DeltaModalSheet(title: "Transaction Details", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero Amount & Type Card
                    VStack(spacing: 10) {
                        HStack {
                            // Category Icon in Dark Circle
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.18))
                                    .frame(width: 38, height: 38)

                                Image(systemName: transaction.category.iconName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(transaction.amountColor)
                            }

                            Text(transaction.category.rawValue.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.deltaTextMutedDark)

                            Spacer()

                            // Type Badge
                            Text(typeBadgeLabel)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(badgeTextColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(badgeBackgroundColor))
                        }

                        Text(transaction.formattedAmount)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(transaction.amountColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)

                        HStack {
                            Text(transaction.title)
                                .font(DeltaTypography.cardTitle)
                                .foregroundColor(Color.deltaTextOnDark)

                            Spacer()

                            Text(transaction.trxID)
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                    }
                    .padding(20)
                    .background(Color.deltaBgOliveDark)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Linked Split Notification (if applicable)
                    if let splitID = transaction.linkedSplitID,
                       let split = service.splits.first(where: { $0.id == splitID }) {
                        Button(action: {
                            showingLinkedSplit = split
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.deltaTextOnLime)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Part of Split Expense")
                                        .font(DeltaTypography.actionLabel)
                                        .foregroundColor(Color.deltaTextOnLime)
                                    Text("\(split.participantCount) participants • \(split.isFullySettled ? "Fully settled" : "\(split.settledCount) settled")")
                                        .font(DeltaTypography.captionMeta)
                                        .foregroundColor(Color.deltaTextOnLime.opacity(0.8))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.deltaTextOnLime.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .padding(.horizontal, 20)
                    }

                    // Metadata Details List
                    VStack(spacing: 0) {
                        detailRow(icon: "person.circle", title: "Party / Merchant", value: transaction.title)
                        Divider().background(Color.deltaBorderOlive.opacity(0.5))

                        detailRow(icon: "calendar", title: "Date", value: transaction.dateString)
                        Divider().background(Color.deltaBorderOlive.opacity(0.5))

                        detailRow(icon: "clock", title: "Time", value: transaction.timeString)
                        Divider().background(Color.deltaBorderOlive.opacity(0.5))

                        detailRow(icon: "creditcard", title: "Account / Envelope", value: transaction.accountName)

                        if let note = transaction.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Divider().background(Color.deltaBorderOlive.opacity(0.5))
                            detailRow(icon: "text.bubble", title: "Purpose / Note", value: note)
                        }

                        if let desc = transaction.descriptionText, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Divider().background(Color.deltaBorderOlive.opacity(0.5))
                            detailRow(icon: "doc.plaintext", title: "Description", value: desc)
                        }
                    }
                    .background(Color.deltaBgSubtle.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Action Controls
                    VStack(spacing: 12) {
                        // Edit / Reclassify Button
                        Button(action: {
                            isEditing = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                Text(transaction.type == .other ? "Reclassify / Edit Record" : "Edit Transaction")
                                    .font(DeltaTypography.actionLabel)
                            }
                            .foregroundColor(Color.deltaTextOnDark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.deltaBgOliveDark)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.deltaBorderOlive, lineWidth: 1)
                            )
                        }

                        // Accessible Delete Action
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Delete Record")
                                    .font(DeltaTypography.actionLabel)
                            }
                            .foregroundColor(Color.deltaExpenseRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.deltaExpenseRed.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.deltaExpenseRed.opacity(0.35), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)

                    Spacer().frame(height: 40)
                }
            }
        }
        .confirmationDialog(
            "Delete Transaction?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Permanently", role: .destructive) {
                Task {
                    try? await service.deleteTransaction(id: transaction.id)
                    await MainActor.run {
                        onDeleted?()
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove this transaction from your persistent ledger. Linked account balances, dashboard totals, and search indexes will update automatically. You will have 5 seconds to undo.")
        }
        .sheet(isPresented: $isEditing) {
            TransactionFormSheet(
                service: service,
                mode: .edit(transaction: transaction)
            )
        }
        .sheet(item: $showingLinkedSplit) { split in
            SplitDetailsSheet(service: service, split: split)
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.deltaTextMutedDark)
                .frame(width: 20)

            Text(title)
                .font(DeltaTypography.captionMeta)
                .foregroundColor(Color.deltaTextMutedDark)

            Spacer()

            Text(value)
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextOnDark)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private var typeBadgeLabel: String {
        if transaction.linkedSplitID != nil {
            return "SPLIT"
        }
        switch transaction.type {
        case .debit:
            return "DEBIT"
        case .credit:
            return "CREDIT"
        case .other:
            return "OTHER"
        }
    }

    private var badgeTextColor: Color {
        switch transaction.type {
        case .debit:
            return Color.deltaExpenseRed
        case .credit:
            return Color(hex: "070A06")
        case .other:
            return Color(hex: "070A06")
        }
    }

    private var badgeBackgroundColor: Color {
        switch transaction.type {
        case .debit:
            return Color.deltaExpenseRed.opacity(0.18)
        case .credit:
            return Color.deltaIncomeGreen
        case .other:
            return Color(hex: "E5C07B")
        }
    }
}

