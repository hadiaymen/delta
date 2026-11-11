import SwiftUI

/// Confirmation sheet presented after a QR code is detected and validated.
/// Allows the user to inspect extracted UPI fields, edit the amount, add a note/description,
/// and log the record safely under 'Other' without initiating any external payment.
public struct QRScanConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let payload: ParsedQRPayload
    public var onSaved: (() -> Void)? = nil

    @State private var payeeTitle: String
    @State private var amountString: String
    @State private var note: String
    @State private var descriptionText: String
    @State private var selectedAccountID: String
    @State private var validationErrorMessage: String? = nil

    public init(
        service: ExpenseTrackingService,
        payload: ParsedQRPayload,
        onSaved: (() -> Void)? = nil
    ) {
        self.service = service
        self.payload = payload
        self.onSaved = onSaved

        _payeeTitle = State(initialValue: payload.displayTitle)
        if let amt = payload.amount {
            _amountString = State(initialValue: String(format: "%.2f", NSDecimalNumber(decimal: amt).doubleValue))
        } else {
            _amountString = State(initialValue: "")
        }
        _note = State(initialValue: payload.transactionNote ?? "")
        _descriptionText = State(initialValue: "")
        _selectedAccountID = State(initialValue: service.accounts.first?.id ?? "default-checking")
    }

    public var body: some View {
        DeltaModalSheet(title: "Scanned QR Outlay", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Safety Guardrail Notice
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.deltaSurfaceLime)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Safe Ledger Capture Only")
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaTextOnDark)

                            Text("No payment is initiated or processed. This safely logs an expense into your personal budget.")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                    }
                    .padding(14)
                    .background(Color.deltaBgOliveDark)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    // Hero Payee & Reference Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.deltaBgCanvas.opacity(0.6))
                                    .frame(width: 40, height: 40)
                                Image(systemName: payload.type == .upi ? "qrcode" : "doc.text")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(payload.type.rawValue.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color.deltaTextMutedDark)

                                Text(payeeTitle)
                                    .font(DeltaTypography.cardTitle)
                                    .foregroundColor(Color.deltaTextOnDark)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text("OTHER")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "070A06"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(hex: "E5C07B")))
                        }

                        if let vpa = payload.payeeAddress, !vpa.isEmpty {
                            HStack(spacing: 6) {
                                Text("Payee VPA:")
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextMutedDark)

                                Text(vpa)
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextOnDark)
                            }
                        }

                        if let ref = payload.referenceID, !ref.isEmpty {
                            HStack(spacing: 6) {
                                Text("Scan Reference:")
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextMutedDark)

                                Text(ref)
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextMutedDark.opacity(0.8))
                            }
                        }
                    }
                    .padding(18)
                    .background(Color.deltaBgSubtle.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Editable Fields Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Amount Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("AMOUNT SPENT")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.deltaTextMutedDark)

                                Spacer()

                                if payload.amount == nil {
                                    Text("Enter manually")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color.deltaSurfaceLime)
                                }
                            }

                            HStack {
                                Text("$")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.deltaTextOnDark)

                                TextField("0.00", text: $amountString)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.deltaTextOnDark)
                                    .keyboardType(.decimalPad)
                                    .accentColor(Color.deltaSurfaceLime)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.deltaBgOliveDark)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.deltaBorderOlive, lineWidth: 1)
                            )
                        }

                        // Payee / Title Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PAYEE / MERCHANT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Starbucks or Sarah", text: $payeeTitle)
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.deltaBgOliveDark)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                    )
                        }

                        // Purpose / Note Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PURPOSE / NOTE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("e.g. Coffee, Lunch or Team event", text: $note)
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.deltaBgOliveDark)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                )
                        }

                        // Additional Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ADDITIONAL DETAILS (OPTIONAL)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.deltaTextMutedDark)

                            TextField("Add invoice, order ID or memo", text: $descriptionText)
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.deltaBgOliveDark)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                )
                        }

                        // Account Envelope Selector
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ACCOUNT ENVELOPE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.deltaTextMutedDark)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(service.accounts) { acc in
                                        Button(action: { selectedAccountID = acc.id }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "creditcard")
                                                    .font(.system(size: 11))
                                                Text(acc.accountName)
                                                    .font(DeltaTypography.actionLabel)
                                            }
                                            .foregroundColor(selectedAccountID == acc.id ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedAccountID == acc.id ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                                    .overlay(
                                                        Capsule().stroke(Color.deltaBorderOlive, lineWidth: selectedAccountID == acc.id ? 0 : 1)
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Validation Error Banner
                    if let err = validationErrorMessage {
                        Text(err)
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaExpenseRed)
                            .padding(.horizontal, 20)
                    }

                    // Save Action Buttons
                    VStack(spacing: 12) {
                        Button(action: confirmAndSave) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Log as Other Outlay")
                                    .font(DeltaTypography.bodySemibold)
                            }
                            .foregroundColor(Color.deltaTextOnLime)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        Text("Saved under Other. You can reclassify or convert to Debit, Credit, or Split at any time from History.")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextMutedDark)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)

                    Spacer().frame(height: 30)
                }
            }
        }
    }

    private func confirmAndSave() {
        let cleanAmountString = amountString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let decimalAmount = Decimal(string: cleanAmountString), decimalAmount > 0 else {
            validationErrorMessage = "Please enter a valid positive outlay amount."
            return
        }

        let chosenAccount = service.accounts.first(where: { $0.id == selectedAccountID }) ?? service.accounts.first
        let accID = chosenAccount?.id ?? "default-checking"
        let accName = chosenAccount?.accountName ?? "Daily Living Envelope"

        var fullDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let ref = payload.referenceID, !ref.isEmpty {
            if fullDescription.isEmpty {
                fullDescription = "Scan Ref: \(ref)"
            } else {
                fullDescription += " | Scan Ref: \(ref)"
            }
        }

        Task {
            do {
                try await service.recordTransaction(
                    type: .other,
                    amount: decimalAmount,
                    title: payeeTitle,
                    timestamp: Date(),
                    category: .other,
                    accountID: accID,
                    accountName: accName,
                    note: note.isEmpty ? nil : note,
                    descriptionText: fullDescription.isEmpty ? nil : fullDescription
                )
                await MainActor.run {
                    onSaved?()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    validationErrorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}

