import SwiftUI

/// Reusable native SwiftUI transaction form adhering to the MONO / DELTA design system.
/// Handles both Credit (money received) and Debit (money spent) workflows, as well as editing and deletion.
public struct TransactionFormSheet: View {
    public enum FormMode {
        case create(type: TransactionItem.TransactionType, initialRecipient: String?)
        case edit(transaction: TransactionItem)
    }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let mode: FormMode

    // Form Fields (Initialized to device's current local date and time)
    @State private var transactionType: TransactionItem.TransactionType
    @State private var amountString: String
    @State private var title: String
    @State private var selectedDate: Date
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedAccountID: String
    @State private var purposeNote: String

    // Validation & State Feedback
    @State private var validationErrorMessage: String? = nil
    @State private var showDeleteConfirmation: Bool = false
    @State private var isSubmitting: Bool = false

    private var editingTransactionID: String? {
        if case .edit(let tx) = mode {
            return tx.id
        }
        return nil
    }

    private var isEditMode: Bool {
        editingTransactionID != nil
    }

    public init(service: ExpenseTrackingService, mode: FormMode) {
        self.service = service
        self.mode = mode

        switch mode {
        case .create(let type, let initialRecipient):
            self._transactionType = State(initialValue: type)
            self._amountString = State(initialValue: "")
            self._title = State(initialValue: initialRecipient ?? "")
            self._selectedDate = State(initialValue: Date()) // Device current local date & time
            self._selectedCategory = State(initialValue: type == .debit ? .dining : .income)
            self._selectedAccountID = State(initialValue: service.cards.first?.id ?? "default-checking")
            self._purposeNote = State(initialValue: "")

        case .edit(let tx):
            self._transactionType = State(initialValue: tx.type)
            self._amountString = State(initialValue: tx.plainAmountString)
            self._title = State(initialValue: tx.title)
            self._selectedDate = State(initialValue: tx.timestamp)
            self._selectedCategory = State(initialValue: tx.category)
            self._selectedAccountID = State(initialValue: tx.accountID)
            self._purposeNote = State(initialValue: tx.note ?? "")
        }
    }

    private var parsedDecimalAmount: Decimal? {
        Decimal(string: amountString)
    }

    private var selectedAccountName: String {
        service.cards.first(where: { $0.id == selectedAccountID })?.accountName ?? "Daily Living Envelope"
    }

    public var body: some View {
        DeltaModalSheet(
            title: isEditMode ? "Edit Record" : (transactionType == .credit ? "Record Credit (Received)" : "Record Debit (Spent)"),
            onClose: { dismiss() }
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Validation Error Banner
                    if let error = validationErrorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color.deltaExpenseRed)
                            Text(error)
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaExpenseRed)
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.deltaExpenseRed.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }

                    // 1. Transaction Type Selector (Credit vs Debit)
                    HStack(spacing: 12) {
                        typeTabButton(
                            title: "Credit (Received)",
                            icon: DeltaIcons.transactionInflow,
                            type: .credit,
                            activeColor: Color.deltaIncomeGreen
                        )

                        typeTabButton(
                            title: "Debit (Spent)",
                            icon: DeltaIcons.transactionOutflow,
                            type: .debit,
                            activeColor: Color.deltaExpenseRed
                        )
                    }
                    .padding(.horizontal, 20)

                    // 2. Amount Input Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AMOUNT")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack(spacing: 4) {
                            Text("$")
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(transactionType == .debit ? Color.deltaExpenseRed : Color.deltaIncomeGreen)

                            TextField("0.00", text: $amountString)
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaTextOnDark)
                                .keyboardType(.decimalPad)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 3. Person, Merchant, or Source Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text(transactionType == .credit ? "SOURCE OR SENDER" : "PERSON OR MERCHANT")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack(spacing: 10) {
                            Image(systemName: transactionType == .credit ? "arrow.down.left" : "person.fill")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField(
                                transactionType == .credit ? "e.g. Alina, Salary, Dividend" : "e.g. Whole Foods, Mark, Utility Co",
                                text: $title
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
                    }
                    .padding(.horizontal, 20)

                    // 4. Account Picker (Personal budget envelopes)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACCOUNT ENVELOPE")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(Color.deltaSurfaceLime)

                            Picker("Account", selection: $selectedAccountID) {
                                ForEach(service.cards) { card in
                                    Text(card.accountName).tag(card.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.deltaTextOnDark)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 5. Category Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CATEGORY")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ExpenseCategory.allCases) { cat in
                                    let isSelected = selectedCategory == cat
                                    Button(action: {
                                        selectedCategory = cat
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.iconName)
                                                .font(.system(size: 11))
                                            Text(cat.rawValue)
                                                .font(DeltaTypography.actionLabel)
                                        }
                                        .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                                .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // 6. Device Local Date & Time (Editable)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DATE & TIME")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            DatePicker(
                                "Date & Time",
                                selection: $selectedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                            .tint(Color.deltaSurfaceLime)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 7. Purpose or Short Note
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PURPOSE OR NOTE (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Shared dinner with Alina", text: $purposeNote)
                                .font(DeltaTypography.bodyRegular)
                                .foregroundColor(Color.deltaTextOnDark)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // Save / Confirm Action Button
                    Button(action: {
                        submitForm()
                    }) {
                        Text(isEditMode ? "Save Changes" : (transactionType == .credit ? "Confirm Credit" : "Confirm Debit"))
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnLime)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(HoldToSendButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Delete Record Button (Only in Edit Mode)
                    if isEditMode {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text("Delete Record")
                            }
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaExpenseRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.deltaExpenseRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
        }
        .confirmationDialog(
            "Delete Transaction",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Permanently", role: .destructive) {
                if let id = editingTransactionID {
                    Task {
                        try? await service.deleteTransaction(id: id)
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this transaction? Account balances will recalculate automatically.")
        }
    }

    @ViewBuilder
    private func typeTabButton(
        title: String,
        icon: String,
        type: TransactionItem.TransactionType,
        activeColor: Color
    ) -> some View {
        let isSelected = transactionType == type
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                transactionType = type
                if type == .credit && selectedCategory != .income {
                    selectedCategory = .income
                }
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(DeltaTypography.actionLabel)
            }
            .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? activeColor : Color.deltaBgOliveDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func submitForm() {
        guard let decimalAmount = parsedDecimalAmount else {
            validationErrorMessage = "Please enter a valid amount."
            return
        }

        // Validate using FinancialCalculator
        let validation = FinancialCalculator.validate(amount: decimalAmount, title: title)
        switch validation {
        case .failure(let error):
            validationErrorMessage = error.localizedDescription
            return
        case .success:
            validationErrorMessage = nil
        }

        Task {
            do {
                if let existingID = editingTransactionID,
                   var existing = service.transactions.first(where: { $0.id == existingID }) {
                    // Update existing
                    existing.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    existing.amount = decimalAmount
                    existing.type = transactionType
                    existing.timestamp = selectedDate
                    existing.category = selectedCategory
                    existing.accountID = selectedAccountID
                    existing.accountName = selectedAccountName
                    existing.note = purposeNote.isEmpty ? nil : purposeNote

                    try await service.updateTransaction(existing)
                } else {
                    // Create new
                    try await service.recordTransaction(
                        type: transactionType,
                        amount: decimalAmount,
                        title: title,
                        timestamp: selectedDate,
                        category: selectedCategory,
                        accountID: selectedAccountID,
                        accountName: selectedAccountName,
                        note: purposeNote.isEmpty ? nil : purposeNote
                    )
                }
                dismiss()
            } catch {
                validationErrorMessage = error.localizedDescription
            }
        }
    }
}

