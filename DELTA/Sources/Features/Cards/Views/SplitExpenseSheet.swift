import SwiftUI

/// Real Split Expense workflow modal allowing expense splitting across participants or envelopes.
public struct SplitExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let activeCard: DummyAccountCard

    @State private var totalAmountString: String = "120.00"
    @State private var splitReason: String = "Group Dinner"
    @State private var numberOfPeople: Int = 3
    @State private var selectedContact: ContactItem? = nil
    @State private var isSubmitting: Bool = false

    public init(service: ExpenseTrackingService, activeCard: DummyAccountCard) {
        self.service = service
        self.activeCard = activeCard
    }

    private var parsedTotal: Decimal {
        Decimal(string: totalAmountString) ?? Decimal.zero
    }

    private var userShareAmount: Decimal {
        guard numberOfPeople > 0, parsedTotal > 0 else { return Decimal.zero }
        var quotient = parsedTotal / Decimal(numberOfPeople)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &quotient, 2, .plain)
        return rounded
    }

    public var body: some View {
        DeltaModalSheet(title: "Split Outlay", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Calculation Summary Card
                    VStack(spacing: 8) {
                        Text("YOUR SHARE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextOnLime.opacity(0.8))

                        Text("$\(userShareAmount)")
                            .font(DeltaTypography.displayHero)
                            .foregroundColor(Color.deltaTextOnLime)

                        Text("From total of $\(totalAmountString) split \(numberOfPeople) ways")
                            .font(DeltaTypography.captionMeta)
                            .foregroundColor(Color.deltaTextOnLime.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.deltaSurfaceLime)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Total Bill Amount
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TOTAL BILL AMOUNT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Text("$")
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaExpenseRed)

                            TextField("0.00", text: $totalAmountString)
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

                    // Reason / Merchant
                    VStack(alignment: .leading, spacing: 6) {
                        Text("REASON / MERCHANDISE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        TextField("e.g. Sushi dinner, Airbnb", text: $splitReason)
                            .font(DeltaTypography.bodyRegular)
                            .foregroundColor(Color.deltaTextOnDark)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.deltaBgOliveDark)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                            )
                    }
                    .padding(.horizontal, 20)

                    // Number of Ways Stepper
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SPLIT BETWEEN PEOPLE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Text("\(numberOfPeople) People")
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)

                            Spacer()

                            Button(action: {
                                if numberOfPeople > 2 { numberOfPeople -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }

                            Button(action: {
                                if numberOfPeople < 12 { numberOfPeople += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // Confirm Split Button (Records real transaction)
                    Button(action: confirmSplit) {
                        Text("Record My Share ($\(userShareAmount))")
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnLime)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.deltaSurfaceLime)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(HoldToSendButtonStyle())
                    .disabled(userShareAmount <= 0)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding(.bottom, 28)
            }
        }
    }

    private func confirmSplit() {
        guard userShareAmount > 0 else { return }
        Task {
            await service.logDebit(
                amount: userShareAmount,
                title: "\(splitReason) (Split \(numberOfPeople) ways)",
                category: .dining,
                accountID: activeCard.id,
                accountName: activeCard.accountName,
                note: "Total bill $\(totalAmountString) divided by \(numberOfPeople) participants."
            )
            dismiss()
        }
    }
}

