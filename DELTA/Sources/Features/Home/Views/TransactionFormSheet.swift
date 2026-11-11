import SwiftUI

/// Reusable native SwiftUI transaction form adhering to the MONO / DELTA design system.
/// Handles Credit (received), Debit (spent), and Other (unclassified) workflows.
/// Supports in-place conversion from 'Other' into Credit, Debit, or Split without duplicate records.
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
    @State private var descriptionText: String

    // Conversion & State Feedback
    @State private var validationErrorMessage: String? = nil
    @State private var showDeleteConfirmation: Bool = false
    @State private var showConvertToSplitSheet: Bool = false

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
            self._selectedCategory = State(initialValue: type == .other ? .other : (type == .debit ? .dining : .income))
            self._selectedAccountID = State(initialValue: service.cards.first?.id ?? "delta-personal")
            self._purposeNote = State(initialValue: "")
            self._descriptionText = State(initialValue: "")

        case .edit(let tx):
            self._transactionType = State(initialValue: tx.type)
            self._amountString = State(initialValue: tx.plainAmountString)
            self._title = State(initialValue: tx.title)
            self._selectedDate = State(initialValue: tx.timestamp)
            self._selectedCategory = State(initialValue: tx.category)
            self._selectedAccountID = State(initialValue: tx.accountID)
            self._purposeNote = State(initialValue: tx.note ?? "")
            self._descriptionText = State(initialValue: tx.descriptionText ?? "")
        }
    }

    private var parsedDecimalAmount: Decimal? {
        Decimal(string: amountString)
    }

    private var selectedAccountName: String {
        service.cards.first(where: { $0.id == selectedAccountID })?.accountName ?? "DELTA PERSONAL"
    }

    public var body: some View {
        DeltaModalSheet(
            title: sheetTitle,
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.deltaExpenseRed.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }

                    // 1. Transaction Type Selector Tabs (Credit, Debit, Other)
                    HStack(spacing: 8) {
                        typeTabButton(
                            title: "Credit",
                            icon: DeltaIcons.transactionInflow,
                            type: .credit,
                            activeColor: Color.deltaIncomeGreen
                        )

                        typeTabButton(
                            title: "Debit",
                            icon: DeltaIcons.transactionOutflow,
                            type: .debit,
                            activeColor: Color.deltaExpenseRed
                        )

                        typeTabButton(
                            title: "Other",
                            icon: "questionmark.circle",
                            type: .other,
                            activeColor: Color(hex: "E5C07B")
                        )
                    }
                    .padding(.horizontal, 20)

                    // In-Place Conversion Panel for 'Other' Records
                    if isEditMode && transactionType == .other {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONVERT CLASSIFICATION (IN-PLACE)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "E5C07B"))

                            HStack(spacing: 8) {
                                Button(action: { convertTo(type: .debit) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.right")
                                        Text("To Debit")
                                    }
                                    .font(DeltaTypography.actionLabel)
                                    .foregroundColor(Color.deltaTextOnLime)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(Capsule().fill(Color.deltaExpenseRed.opacity(0.85)))
                                }

                                Button(action: { convertTo(type: .credit) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.left")
                                        Text("To Credit")
                                    }
                                    .font(DeltaTypography.actionLabel)
                                    .foregroundColor(Color.deltaTextOnLime)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(Capsule().fill(Color.deltaIncomeGreen))
                                }

                                Button(action: { showConvertToSplitSheet = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.branch")
                                        Text("To Split")
                                    }
                                    .font(DeltaTypography.actionLabel)
                                    .foregroundColor(Color.deltaTextOnDark)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(Capsule().fill(Color.deltaBgOliveDark))
                                    .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: 1))
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E5C07B").opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "E5C07B").opacity(0.3), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }

                    // 2. Amount Input Field (Required)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AMOUNT")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack(spacing: 4) {
                            Text("$")
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(amountAccentColor)

                            TextField("0.00", text: $amountString)
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaTextOnDark)
                                .keyboardType(.decimalPad)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 3. Person, Merchant, or Source Name (Optional for Other)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(transactionType == .other ? "PERSON OR MERCHANT (OPTIONAL)" : (transactionType == .credit ? "SOURCE OR SENDER" : "PERSON OR MERCHANT"))
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack(spacing: 10) {
                            Image(systemName: transactionType == .other ? "questionmark" : (transactionType == .credit ? "arrow.down.left" : "person.fill"))
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField(
                                transactionType == .other ? "Optional (e.g. Mystery charge, Cash found)" : "e.g. Whole Foods, Alina",
                                text: $title
                            )
                            .font(DeltaTypography.bodyRegular)
                            .foregroundColor(Color.deltaTextOnDark)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 4. Optional Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DESCRIPTION (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Receipt found in coat pocket", text: $descriptionText)
                                .font(DeltaTypography.bodyRegular)
                                .foregroundColor(Color.deltaTextOnDark)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 5. Account Envelope Picker (Optional)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACCOUNT ENVELOPE (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold))
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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 6. Category Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CATEGORY")
                            .font(.system(size: 11, weight: .bold))
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

                    // 7. Device Local Date & Time (Current by default, editable)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DATE & TIME")
                            .font(.system(size: 11, weight: .bold))
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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 8. Purpose or Short Note (Optional)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PURPOSE OR NOTE (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Review statement next week", text: $purposeNote)
                                .font(DeltaTypography.bodyRegular)
                                .foregroundColor(Color.deltaTextOnDark)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // Save / Confirm Action Button
                    Button(action: {
                        submitForm()
                    }) {
                        Text(isEditMode ? "Save Changes" : (transactionType == .other ? "Save Unclassified Record" : (transactionType == .credit ? "Confirm Credit" : "Confirm Debit")))
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnLime)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
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
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
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
            Text("Are you sure you want to delete this record? Balances will recalculate automatically.")
        }
        .sheet(isPresented: $showConvertToSplitSheet) {
            if let card = service.cards.first(where: { $0.id == selectedAccountID }) ?? service.cards.first {
                SplitExpenseModal(service: service, initialCard: card)
            }
        }
    }

    private var sheetTitle: String {
        if isEditMode {
            return "Edit Record"
        }
        switch transactionType {
        case .credit: return "Record Credit"
        case .debit: return "Record Debit"
        case .other: return "Record Other / Unclassified"
        }
    }

    private var amountAccentColor: Color {
        switch transactionType {
        case .debit: return Color.deltaExpenseRed
        case .credit: return Color.deltaIncomeGreen
        case .other: return Color(hex: "E5C07B")
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
                if type == .other && selectedCategory != .other {
                    selectedCategory = .other
                } else if type == .credit && selectedCategory == .other {
                    selectedCategory = .income
                } else if type == .debit && selectedCategory == .other {
                    selectedCategory = .dining
                }
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(DeltaTypography.actionLabel)
            }
            .foregroundColor(isSelected ? (type == .other ? Color.black : Color.deltaTextOnLime) : Color.deltaTextMutedDark)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? activeColor : Color.deltaBgOliveDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func convertTo(type: TransactionItem.TransactionType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            transactionType = type
            if type == .debit {
                selectedCategory = .dining
            } else if type == .credit {
                selectedCategory = .income
            }
        }
        submitForm()
    }

    private func submitForm() {
        guard let decimalAmount = parsedDecimalAmount else {
            validationErrorMessage = "Please enter a valid amount."
            return
        }

        let allowEmpty = transactionType == .other
        let validation = FinancialCalculator.validate(amount: decimalAmount, title: title, allowEmptyTitle: allowEmpty)
        switch validation {
        case .failure(let error):
            validationErrorMessage = error.localizedDescription
            return
        case .success:
            validationErrorMessage = nil
        }

        let resolvedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (transactionType == .other ? "Unclassified Outlay" : "Transaction") : title

        Task {
            do {
                if let existingID = editingTransactionID,
                   var existing = service.transactions.first(where: { $0.id == existingID }) {
                    existing.title = resolvedTitle
                    existing.amount = decimalAmount
                    existing.type = transactionType
                    existing.timestamp = selectedDate
                    existing.category = selectedCategory
                    existing.accountID = selectedAccountID
                    existing.accountName = selectedAccountName
                    existing.note = purposeNote.isEmpty ? nil : purposeNote
                    existing.descriptionText = descriptionText.isEmpty ? nil : descriptionText

                    try await service.updateTransaction(existing)
                } else {
                    try await service.recordTransaction(
                        type: transactionType,
                        amount: decimalAmount,
                        title: resolvedTitle,
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
