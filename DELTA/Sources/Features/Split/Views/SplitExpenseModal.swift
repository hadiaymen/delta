import SwiftUI

/// Complete Split Expense creation and editing modal supporting:
/// 1. Equal Split (with deterministic minor currency remainder distribution)
/// 2. Custom Amount Split (with strict total validation)
/// 3. Percentage Split (with 100% total validation)
public struct SplitExpenseModal: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let initialCard: DummyAccountCard

    // Form State
    @State private var totalExpenseString: String = "120.00"
    @State private var purposeText: String = "Team Italian Dinner"
    @State private var selectedDate: Date = Date()
    @State private var selectedMethod: SplitMethod = .equal
    @State private var selectedAccountID: String
    @State private var isCurrentUserPayer: Bool = true
    @State private var includeCurrentUser: Bool = true
    @State private var createLinkedTransaction: Bool = true

    // Participants
    @State private var participants: [SplitParticipant] = []
    @State private var customShareStrings: [String: String] = [:]       // participant.id -> amount
    @State private var percentageShareStrings: [String: String] = [:]   // participant.id -> percent

    // New Participant Input
    @State private var newParticipantName: String = ""
    @State private var validationError: String? = nil

    public init(service: ExpenseTrackingService, initialCard: DummyAccountCard) {
        self.service = service
        self.initialCard = initialCard
        self._selectedAccountID = State(initialValue: initialCard.id)
    }

    private var parsedTotal: Decimal {
        Decimal(string: totalExpenseString) ?? Decimal.zero
    }

    private var selectedAccountName: String {
        service.cards.first(where: { $0.id == selectedAccountID })?.accountName ?? initialCard.accountName
    }

    public var body: some View {
        DeltaModalSheet(title: "Split Outlay", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Error Banner
                    if let err = validationError {
                        HStack(spacing: 8) {
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
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }

                    // 1. Total Expense Amount
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TOTAL EXPENSE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack {
                            Text("$")
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaSurfaceLime)

                            TextField("0.00", text: $totalExpenseString)
                                .font(DeltaTypography.titleLarge)
                                .foregroundColor(Color.deltaTextOnDark)
                                .keyboardType(.decimalPad)
                                .onChange(of: totalExpenseString) { _ in
                                    recalculateShares()
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

                    // 2. Purpose / Note
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PURPOSE / MERCHANDISE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        TextField("e.g. Group Dinner, Travel Airbnb", text: $purposeText)
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

                    // 3. Three Split Methods Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SPLIT METHOD")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        HStack(spacing: 8) {
                            ForEach(SplitMethod.allCases) { method in
                                let isSelected = selectedMethod == method
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedMethod = method
                                        recalculateShares()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: method.iconName)
                                            .font(.system(size: 12, weight: .bold))
                                        Text(method.rawValue)
                                            .font(DeltaTypography.actionLabel)
                                    }
                                    .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isSelected ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.deltaBorderOlive, lineWidth: isSelected ? 0 : 1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // 4. Source Account Envelope Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CHARGE TO ACCOUNT")
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

                    // 5. Date & Time (Defaults to local device time, fully editable)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE & TIME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        DatePicker(
                            "Date & Time",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .tint(Color.deltaSurfaceLime)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 6. Select Favourite People
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QUICK-ADD FAVOURITE PEOPLE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(service.favouritePeople) { person in
                                    let isAdded = participants.contains(where: { $0.name == person.name })
                                    Button(action: {
                                        toggleFavouritePerson(person)
                                    }) {
                                        HStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(isAdded ? Color.deltaTextOnLime : Color(hex: "233215"))
                                                    .frame(width: 22, height: 22)

                                                Text(person.initials)
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(isAdded ? Color.deltaSurfaceLime : Color.deltaSurfaceLime)
                                            }

                                            Text(person.name)
                                                .font(DeltaTypography.actionLabel)

                                            Image(systemName: isAdded ? "checkmark" : "plus")
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        .foregroundColor(isAdded ? Color.deltaTextOnLime : Color.deltaTextOnDark)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule()
                                                .fill(isAdded ? Color.deltaSurfaceLime : Color.deltaBgOliveDark)
                                                .overlay(Capsule().stroke(Color.deltaBorderOlive, lineWidth: isAdded ? 0 : 1))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // 7. Add Custom Participant Row
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ADD OTHER PARTICIPANT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)

                        HStack(spacing: 8) {
                            TextField("Name (e.g. Liam)", text: $newParticipantName)
                                .font(DeltaTypography.bodyRegular)
                                .foregroundColor(Color.deltaTextOnDark)

                            Button(action: addCustomParticipant) {
                                Text("Add")
                                    .font(DeltaTypography.actionLabel)
                                    .foregroundColor(Color.deltaTextOnLime)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.deltaSurfaceLime))
                            }
                            .disabled(newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)

                    // 8. Participants Breakdown List with Shares
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("PARTICIPANTS (\(participants.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.deltaTextMutedDark)

                            Spacer()

                            // Current User inclusion toggle
                            Toggle("Include Me", isOn: $includeCurrentUser)
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                                .toggleStyle(SwitchToggleStyle(tint: Color.deltaSurfaceLime))
                                .onChange(of: includeCurrentUser) { _ in
                                    syncCurrentUserParticipation()
                                }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 8) {
                            ForEach(Array(participants.enumerated()), id: \.element.id) { idx, participant in
                                participantRow(index: idx, participant: participant)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // 9. Single Linked Transaction Option Toggle
                    Toggle(isOn: $createLinkedTransaction) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Record Linked Original Outlay")
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                            Text("Creates a single linked debit record on your card without duplicating totals.")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.deltaSurfaceLime))
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.deltaBgOliveDark.opacity(0.6))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                    )
                    .padding(.horizontal, 20)

                    // Confirm / Create Split Button
                    Button(action: submitSplit) {
                        Text("Create Split Outlay")
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
                }
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            initializeDefaultParticipants()
        }
    }

    @ViewBuilder
    private func participantRow(index: Int, participant: SplitParticipant) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(participant.isCurrentUser ? Color.deltaSurfaceLime : Color(hex: "233215"))
                    .frame(width: 36, height: 36)

                Text(participant.isCurrentUser ? "ME" : String(participant.name.prefix(2)).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(participant.isCurrentUser ? Color.deltaTextOnLime : Color.deltaSurfaceLime)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(participant.isCurrentUser ? "\(participant.name) (You)" : participant.name)
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)

                Text(participant.isSettled ? "Settled" : "Owed to Payer")
                    .font(DeltaTypography.captionMeta)
                    .foregroundColor(participant.isSettled ? Color.deltaSurfaceLime : Color.deltaExpenseRed)
            }

            Spacer()

            // Share Display or Inputs according to method
            switch selectedMethod {
            case .equal:
                Text(participant.formattedShare)
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaSurfaceLime)

            case .custom:
                HStack(spacing: 2) {
                    Text("$")
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaTextMutedDark)
                    TextField("0.00", text: Binding(
                        get: { customShareStrings[participant.id] ?? "\(participant.shareAmount)" },
                        set: { val in
                            customShareStrings[participant.id] = val
                            if let d = Decimal(string: val) {
                                participants[index].shareAmount = d
                            }
                        }
                    ))
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)
                    .frame(width: 68)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                }
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.deltaBgCanvas))

            case .percentage:
                HStack(spacing: 2) {
                    TextField("0", text: Binding(
                        get: { percentageShareStrings[participant.id] ?? "\(participant.percentage ?? 0)" },
                        set: { val in
                            percentageShareStrings[participant.id] = val
                            if let d = Decimal(string: val) {
                                participants[index].percentage = d
                                recalculateShares()
                            }
                        }
                    ))
                    .font(DeltaTypography.bodySemibold)
                    .foregroundColor(Color.deltaTextOnDark)
                    .frame(width: 48)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    Text("%")
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaTextMutedDark)
                }
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.deltaBgCanvas))
            }

            // Remove button (non-current user)
            if !participant.isCurrentUser {
                Button(action: {
                    participants.removeAll { $0.id == participant.id }
                    recalculateShares()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.deltaTextMutedDark.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.deltaBgOliveDark)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.deltaBorderOlive, lineWidth: 1))
        )
    }

    private func initializeDefaultParticipants() {
        participants = [
            SplitParticipant(name: "Hadi Aymen", identifier: "hadi@delta.dev", isCurrentUser: true, isSettled: true),
            SplitParticipant(name: "Alina", identifier: "*****46", isCurrentUser: false, isSettled: false),
            SplitParticipant(name: "Mark", identifier: "*****37", isCurrentUser: false, isSettled: false)
        ]
        recalculateShares()
    }

    private func syncCurrentUserParticipation() {
        if includeCurrentUser {
            if !participants.contains(where: { $0.isCurrentUser }) {
                participants.insert(
                    SplitParticipant(name: "Hadi Aymen", identifier: "hadi@delta.dev", isCurrentUser: true, isSettled: true),
                    at: 0
                )
            }
        } else {
            participants.removeAll { $0.isCurrentUser }
        }
        recalculateShares()
    }

    private func toggleFavouritePerson(_ person: ContactItem) {
        if let idx = participants.firstIndex(where: { $0.name == person.name }) {
            participants.remove(at: idx)
        } else {
            participants.append(
                SplitParticipant(name: person.name, identifier: person.maskedIdentifier, isCurrentUser: false, isSettled: false)
            )
        }
        recalculateShares()
    }

    private func addCustomParticipant() {
        let clean = newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        participants.append(
            SplitParticipant(name: clean, identifier: "", isCurrentUser: false, isSettled: false)
        )
        newParticipantName = ""
        recalculateShares()
    }

    private func recalculateShares() {
        guard parsedTotal > Decimal.zero, !participants.isEmpty else { return }

        switch selectedMethod {
        case .equal:
            if let calculated = try? SplitCalculationEngine.calculateEqualShares(total: parsedTotal, participants: participants) {
                self.participants = calculated
            }

        case .percentage:
            // Auto-distribute equally if percentages are unset
            let defaultPct = Decimal(100) / Decimal(participants.count)
            for i in 0..<participants.count {
                if participants[i].percentage == nil || participants[i].percentage == Decimal.zero {
                    participants[i].percentage = defaultPct
                }
            }
            if let calculated = try? SplitCalculationEngine.calculatePercentageShares(total: parsedTotal, participants: participants) {
                self.participants = calculated
            }

        case .custom:
            // Retain custom assigned values
            break
        }
    }

    private func submitSplit() {
        guard parsedTotal > Decimal.zero else {
            validationError = "Total amount must be greater than zero."
            return
        }

        guard participants.count >= 2 else {
            validationError = "At least two participants are required to split."
            return
        }

        // Validate according to method
        switch selectedMethod {
        case .equal:
            do {
                self.participants = try SplitCalculationEngine.calculateEqualShares(total: parsedTotal, participants: participants)
                validationError = nil
            } catch {
                validationError = error.localizedDescription
                return
            }

        case .custom:
            do {
                try SplitCalculationEngine.validateCustomShares(total: parsedTotal, participants: participants)
                validationError = nil
            } catch {
                validationError = error.localizedDescription
                return
            }

        case .percentage:
            do {
                self.participants = try SplitCalculationEngine.calculatePercentageShares(total: parsedTotal, participants: participants)
                validationError = nil
            } catch {
                validationError = error.localizedDescription
                return
            }
        }

        Task {
            do {
                try await service.createSplit(
                    title: purposeText.isEmpty ? "Group Split" : purposeText,
                    totalAmount: parsedTotal,
                    method: selectedMethod,
                    payerName: isCurrentUserPayer ? "Hadi Aymen" : (participants.first?.name ?? "Other"),
                    isCurrentUserPayer: isCurrentUserPayer,
                    accountID: selectedAccountID,
                    accountName: selectedAccountName,
                    timestamp: selectedDate,
                    participants: participants,
                    createLinkedTransaction: createLinkedTransaction
                )
                dismiss()
            } catch {
                validationError = error.localizedDescription
            }
        }
    }
}

