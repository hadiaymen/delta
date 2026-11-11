import SwiftUI

/// Form sheet to Add or Edit a personal dummy account card.
public struct AccountFormSheet: View {
    public enum Mode {
        case create
        case edit(card: DummyAccountCard)
    }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let mode: Mode

    @State private var accountName: String
    @State private var initialBalanceString: String
    @State private var categoryName: String
    @State private var selectedTheme: DummyAccountCard.CardTheme
    @State private var errorMessage: String? = nil
    @State private var showDeleteConfirmation: Bool = false

    public init(service: ExpenseTrackingService, mode: Mode) {
        self.service = service
        self.mode = mode

        switch mode {
        case .create:
            self._accountName = State(initialValue: "DELTA ")
            self._initialBalanceString = State(initialValue: "")
            self._categoryName = State(initialValue: "Personal Account")
            self._selectedTheme = State(initialValue: .chartreuseLime)

        case .edit(let card):
            self._accountName = State(initialValue: card.accountName)
            self._initialBalanceString = State(initialValue: "\(card.initialBalance)")
            self._categoryName = State(initialValue: card.accountCategory)
            self._selectedTheme = State(initialValue: card.theme)
        }
    }

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    public var body: some View {
        DeltaModalSheet(
            title: isEditMode ? "Edit Account" : "Add Account",
            onClose: { dismiss() }
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let err = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color.deltaExpenseRed)
                            Text(err)
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaExpenseRed)
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.deltaExpenseRed.opacity(0.12))
                        )
                        .padding(.horizontal, 20)
                    }

                    // Account Name Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACCOUNT NAME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(Color.deltaSurfaceLime)

                            TextField("e.g. DELTA TRAVEL", text: $accountName)
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

                    // Initial Budget / Balance
                    VStack(alignment: .leading, spacing: 6) {
                        Text("INITIAL BALANCE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Text("$")
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaSurfaceLime)

                            TextField("0.00", text: $initialBalanceString)
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

                    // Category Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CATEGORY OR ENVELOPE TYPE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Cash Envelope, Travel Vault", text: $categoryName)
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

                    // Card Visual Theme Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CARD COLOR THEME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            ForEach(DummyAccountCard.CardTheme.allCases, id: \.self) { theme in
                                Button(action: {
                                    selectedTheme = theme
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(themeGradient(for: theme))
                                            .frame(height: 50)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(selectedTheme == theme ? Color.deltaSurfaceLime : Color.clear, lineWidth: 2)
                                            )

                                        if selectedTheme == theme {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Save / Create Button
                    Button(action: saveAccount) {
                        Text(isEditMode ? "Save Changes" : "Create Account")
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnLime)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(HoldToSendButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Remove Account Button (Only in edit mode, non-primary)
                    if case .edit(let card) = mode, !card.isPrimary {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text("Remove Account")
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
            "Remove Account",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove Account Permanently", role: .destructive) {
                if case .edit(let card) = mode {
                    service.deleteAccount(id: card.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove this account? Associated transactions will remain in ledger.")
        }
    }

    private func saveAccount() {
        let cleanName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            errorMessage = "Please enter an account name."
            return
        }

        guard let initialBalance = Decimal(string: initialBalanceString), initialBalance >= 0 else {
            errorMessage = "Please enter a valid starting balance."
            return
        }

        if case .edit(var card) = mode {
            card.accountName = cleanName
            card.initialBalance = initialBalance
            card.accountCategory = categoryName.isEmpty ? "Personal Account" : categoryName
            card.theme = selectedTheme
            service.updateAccount(card)
        } else {
            service.addAccount(
                name: cleanName,
                initialBalance: initialBalance,
                category: categoryName.isEmpty ? "Personal Account" : categoryName,
                theme: selectedTheme
            )
        }
        dismiss()
    }

    private func themeGradient(for theme: DummyAccountCard.CardTheme) -> LinearGradient {
        switch theme {
        case .chartreuseLime:
            return DeltaGradients.cardSurface
        case .forestOlive:
            return DeltaGradients.cardPeekSurface
        case .obsidianDark:
            return LinearGradient(colors: [Color(hex: "1F2A18"), Color(hex: "0D140A")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .electricLime:
            return LinearGradient(colors: [Color(hex: "8BB407"), Color(hex: "4B6409")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

