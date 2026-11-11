import SwiftUI

/// Fast modal sheet to log a real Debit (outflow) or Credit (inflow) transaction.
public struct QuickTransactionModal: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let mode: TransactionItem.TransactionType
    public let initialRecipient: String?

    @State private var amountString: String = "0"
    @State private var titleText: String = ""
    @State private var selectedCategory: ExpenseCategory = .general
    @State private var isSubmitting: Bool = false

    public init(
        service: ExpenseTrackingService,
        mode: TransactionItem.TransactionType,
        initialRecipient: String? = nil
    ) {
        self.service = service
        self.mode = mode
        self.initialRecipient = initialRecipient
        self._titleText = State(initialValue: initialRecipient ?? "")
        self._selectedCategory = State(initialValue: mode == .debit ? .dining : .income)
    }

    private var parsedAmount: Double {
        Double(amountString) ?? 0.0
    }

    public var body: some View {
        DeltaModalSheet(
            title: mode == .debit ? "Log Debit (Spent)" : "Log Credit (Inflow)",
            onClose: { dismiss() }
        ) {
            VStack(spacing: 16) {
                // Large Hero Amount Display with Cursor
                HStack(alignment: .center, spacing: 2) {
                    Text("$\(amountString)")
                        .font(DeltaTypography.displayHero)
                        .foregroundColor(mode == .debit ? Color.deltaExpenseRed : Color.deltaIncomeGreen)

                    Rectangle()
                        .fill(Color.deltaSurfaceLime)
                        .frame(width: 2.5, height: 36)
                }
                .padding(.top, 12)

                // Transaction Title Input
                HStack {
                    Image(systemName: mode == .debit ? "arrow.up.right" : "arrow.down.left")
                        .foregroundColor(Color.deltaTextMutedDark)

                    TextField(
                        mode == .debit ? "Payee, store or reason (e.g. Blue Bottle)" : "Sender or reason (e.g. Salary, Alina)",
                        text: $titleText
                    )
                    .font(DeltaTypography.bodyRegular)
                    .foregroundColor(Color.deltaTextOnDark)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                )
                .padding(.horizontal, 20)

                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Button(action: {
                                selectedCategory = cat
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: cat.iconName)
                                        .font(.system(size: 11))
                                    Text(cat.rawValue)
                                        .font(DeltaTypography.actionLabel)
                                }
                                .foregroundColor(selectedCategory == cat ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == cat ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                        .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: selectedCategory == cat ? 0 : 1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Keypad Matrix
                NumericKeypadView { key in
                    handleKeypress(key)
                }
                .padding(.bottom, 8)

                // Confirm Action Button
                Button(action: {
                    submitTransaction()
                }) {
                    Text(mode == .debit ? "Confirm Debit" : "Confirm Credit")
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnLime)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.deltaSurfaceLime)
                        .clipShape(
                            RoundedCornerShape(radius: 24, corners: [.topLeft, .topRight])
                        )
                }
                .buttonStyle(HoldToSendButtonStyle())
                .disabled(parsedAmount <= 0)
                .opacity(parsedAmount <= 0 ? 0.4 : 1.0)
            }
        }
    }

    private func handleKeypress(_ key: String) {
        switch key {
        case "x", "⌫":
            if !amountString.isEmpty {
                amountString.removeLast()
            }
            if amountString.isEmpty {
                amountString = "0"
            }
        case "↩":
            submitTransaction()
        default:
            if amountString == "0" {
                amountString = key
            } else {
                amountString.append(key)
            }
        }
    }

    private func submitTransaction() {
        guard parsedAmount > 0 else { return }
        Task {
            if mode == .debit {
                await service.logDebit(
                    amount: parsedAmount,
                    title: titleText.isEmpty ? "Debit Expense" : titleText,
                    category: selectedCategory
                )
            } else {
                await service.logCredit(
                    amount: parsedAmount,
                    title: titleText.isEmpty ? "Credit Inflow" : titleText,
                    category: selectedCategory
                )
            }
            dismiss()
        }
    }
}

