import SwiftUI

/// Log Outlay / Send Money sheet matching the left screen of the reference.
/// Built using reusable DELTA design system components.
public struct OutlayEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: OutlayEntryViewModel

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: OutlayEntryViewModel(service: service))
    }

    public var body: some View {
        DeltaModalSheet(title: "Send Money", onClose: { dismiss() }) {
            VStack(spacing: 0) {
                // Lime "Transfer from" Container Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Transfer from")
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaTextOnLime.opacity(0.8))

                        Spacer()

                        Image(systemName: DeltaIcons.optionsMenu)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.deltaTextOnLime)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color.deltaTextOnLime)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("My Account")
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnLime)

                            Text("******5890")
                                .font(DeltaTypography.captionMeta)
                                .foregroundColor(Color.deltaTextOnLime.opacity(0.8))
                        }

                        Spacer()

                        // Dark Balance Badge
                        Text("$23,590.73")
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnDark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.deltaTextOnLime)
                            )

                        Image(systemName: DeltaIcons.swapAccount)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.deltaTextOnLime)
                    }
                }
                .padding(18)
                .background(Color.deltaSurfaceLime)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Hero Amount Display with Cursor
                HStack(alignment: .center, spacing: 2) {
                    Text(viewModel.formattedDisplayAmount)
                        .font(DeltaTypography.displayHero)
                        .foregroundColor(Color.deltaTextOnDark)

                    // Cursor Indicator
                    Rectangle()
                        .fill(Color.deltaSurfaceLime)
                        .frame(width: 2.5, height: 36)
                }
                .padding(.top, 16)

                // Transfer Limits Slider Component
                TransferLimitSlider(
                    title: "Transfer Limits",
                    currentAmount: viewModel.parsedAmount,
                    maxLimit: viewModel.transferLimitMax
                )
                .padding(.horizontal, 24)
                .padding(.top, 10)

                // Quick Send Contacts Row
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Quick Send")
                            .font(DeltaTypography.bodySemibold)
                            .foregroundColor(Color.deltaTextOnDark)

                        Spacer()

                        Text("View all >")
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaTextMutedDark)
                    }

                    HStack(spacing: 10) {
                        // Plus Squircle Button
                        Button(action: {}) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                    .fill(Color.deltaBgOliveDark)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DeltaDimensions.radiusSquircleTile, style: .continuous)
                                            .stroke(Color.deltaBorderOlive, lineWidth: 1)
                                    )

                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.deltaTextOnDark)
                            }
                        }
                        .buttonStyle(SquircleButtonStyle())

                        ForEach(service.contacts.prefix(3)) { contact in
                            ContactAvatarChip(
                                name: contact.name,
                                maskedIdentifier: contact.maskedIdentifier,
                                initials: contact.initials,
                                isSelected: viewModel.selectedRecipient == contact.name,
                                action: {
                                    viewModel.selectedRecipient = contact.name
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                Spacer()

                // 3x4 Squircle Numeric Keypad
                NumericKeypadView { key in
                    viewModel.handleKeypadInput(key)
                }
                .padding(.bottom, 12)

                // Bottom "Hold To Send" Action Surface
                Button(action: {
                    viewModel.executeSend()
                }) {
                    Text("Hold To Send")
                        .font(DeltaTypography.bodySemibold)
                        .foregroundColor(Color.deltaTextOnLime)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.deltaSurfaceLime)
                        .clipShape(
                            RoundedCornerShape(
                                radius: 28,
                                corners: [.topLeft, .topRight]
                            )
                        )
                }
                .buttonStyle(HoldToSendButtonStyle())
            }
        }
        .alert(isPresented: $viewModel.showSuccessToast) {
            Alert(
                title: Text("Expense Outlay Recorded"),
                message: Text("Successfully logged $\(viewModel.rawAmountString) to \(viewModel.selectedRecipient)."),
                dismissButton: .default(Text("Done"), action: {
                    dismiss()
                })
            )
        }
    }
}
