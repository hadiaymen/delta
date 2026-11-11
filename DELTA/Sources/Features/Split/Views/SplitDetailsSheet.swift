import SwiftUI

/// Detailed view of an active Split record with individual settlement tracking, editing, and deletion.
public struct SplitDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    public let split: SplitRecord

    @State private var showDeleteConfirmation: Bool = false

    public init(service: ExpenseTrackingService, split: SplitRecord) {
        self.service = service
        self.split = split
    }

    public var body: some View {
        DeltaModalSheet(title: split.title, onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Summary Hero Card
                    VStack(spacing: 8) {
                        HStack {
                            Text(split.method.rawValue.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.deltaTextOnLime.opacity(0.8))

                            Spacer()

                            Text(split.isFullySettled ? "FULLY SETTLED" : "\(split.settledCount) OF \(split.participantCount) SETTLED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(split.isFullySettled ? Color(hex: "173A05") : Color.deltaTextOnLime)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.black.opacity(0.12)))
                        }

                        Text(split.formattedTotalAmount)
                            .font(DeltaTypography.displayHero)
                            .foregroundColor(Color.deltaTextOnLime)

                        HStack {
                            Text("Paid by \(split.payerName)")
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaTextOnLime.opacity(0.85))

                            Spacer()

                            Text("Account: \(split.accountName)")
                                .font(DeltaTypography.actionLabel)
                                .foregroundColor(Color.deltaTextOnLime.opacity(0.85))
                        }
                    }
                    .padding(20)
                    .background(Color.deltaSurfaceLime)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Outstanding Receivables Banner (if current user is payer)
                    if split.isCurrentUserPayer && !split.isFullySettled {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("OUTSTANDING TO YOU")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color.deltaTextMutedDark)

                                Text("$\(split.totalOwedToPayer)")
                                    .font(DeltaTypography.sectionHeader)
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }

                            Spacer()

                            Text("Tap participant below to toggle settled")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextMutedDark)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }

                    // Participants Breakdown List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PARTICIPANTS & SETTLEMENTS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.deltaTextMutedDark)
                            .padding(.horizontal, 20)

                        VStack(spacing: 8) {
                            ForEach(split.participants) { participant in
                                Button(action: {
                                    toggleSettlement(for: participant)
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(participant.isSettled ? Color.deltaSurfaceLime : Color(hex: "233215"))
                                                .frame(width: 38, height: 38)

                                            Image(systemName: participant.isSettled ? "checkmark" : "clock")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(participant.isSettled ? Color.deltaTextOnLime : Color.deltaSurfaceLime)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(participant.isCurrentUser ? "\(participant.name) (You)" : participant.name)
                                                .font(DeltaTypography.bodySemibold)
                                                .foregroundColor(Color.deltaTextOnDark)

                                            Text(participant.isSettled ? "Settled" : "Unsettled (Tap to settle)")
                                                .font(DeltaTypography.captionMeta)
                                                .foregroundColor(participant.isSettled ? Color.deltaSurfaceLime : Color.deltaExpenseRed)
                                        }

                                        Spacer()

                                        Text(participant.formattedShare)
                                            .font(DeltaTypography.bodySemibold)
                                            .foregroundColor(Color.deltaTextOnDark)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.deltaBgOliveDark)
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.deltaBorderOlive, lineWidth: 1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Delete Split Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text("Delete Split Record")
                        }
                        .font(DeltaTypography.actionLabel)
                        .foregroundColor(Color.deltaExpenseRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.deltaExpenseRed.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaExpenseRed.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 28)
            }
        }
        .confirmationDialog(
            "Delete Split Record",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Permanently", role: .destructive) {
                Task {
                    try? await service.deleteSplit(id: split.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deleting this split will also remove the linked expense outlay and settle records consistently.")
        }
    }

    private func toggleSettlement(for participant: SplitParticipant) {
        Task {
            try? await service.toggleParticipantSettlement(splitID: split.id, participantID: participant.id)
        }
    }
}

