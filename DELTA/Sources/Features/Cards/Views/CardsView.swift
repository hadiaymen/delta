import SwiftUI

/// Cards and Accounts screen matching the right-hand phone in the reference.
/// Features stacked dummy cards, horizontal swipe, tap-to-select, expansion,
/// exactly four Quick Actions (Split, Credit, Debit, Other), and full Account CRUD.
public struct CardsView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: CardsViewModel
    public let onBackTapped: () -> Void

    public init(service: ExpenseTrackingService, onBackTapped: @escaping () -> Void = {}) {
        self.service = service
        self.onBackTapped = onBackTapped
        self._viewModel = StateObject(wrappedValue: CardsViewModel(service: service))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Top Navigation Bar
                HStack {
                    SquircleButton(
                        iconName: DeltaIcons.chevronBack,
                        size: DeltaDimensions.sizeTopBarButton,
                        style: .dark,
                        action: onBackTapped
                    )

                    Spacer()

                    Text("Cards")
                        .font(DeltaTypography.screenTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Spacer()

                    SquircleButton(
                        iconName: DeltaIcons.notificationBell,
                        size: DeltaDimensions.sizeTopBarButton,
                        style: .dark,
                        action: {
                            viewModel.alertMessage = "No new account notices."
                            viewModel.showAlertNotice = true
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Overlapping Layered Card Stack Presentation Deck
                StackedCardDeckView(
                    cards: service.cards,
                    selectedIndex: $viewModel.selectedCardIndex
                )
                .padding(.top, 8)

                // Selected Account Balance Header & Detail Pill
                if let selectedCard = viewModel.selectedCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SELECTED ACCOUNT")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(Color.deltaTextMutedDark)

                            Text(selectedCard.accountName)
                                .font(DeltaTypography.bodySemibold)
                                .foregroundColor(Color.deltaTextOnDark)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("BALANCE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(Color.deltaTextMutedDark)

                            Text(selectedCard.formattedBalance)
                                .font(DeltaTypography.sectionHeader)
                                .foregroundColor(Color.deltaSurfaceLime)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.deltaBgOliveDark.opacity(0.6))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deltaBorderOlive, lineWidth: 1))
                    )
                    .padding(.horizontal, 20)
                }

                // Exactly Four Quick Actions (Split, Credit, Debit, Other)
                CardQuickActionsView { action in
                    viewModel.handleQuickAction(action)
                }
                .padding(.top, 4)

                // Peeking "+ Add Account" Surface
                Button(action: {
                    viewModel.onAddAccountTapped()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))

                        Text("+ Add Account")
                            .font(DeltaTypography.bodySemibold)
                    }
                    .foregroundColor(Color.deltaTextOnLime)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.deltaSurfaceLime)
                    .clipShape(
                        RoundedCornerShape(radius: 24, corners: [.topLeft, .topRight])
                    )
                    .padding(.horizontal, 20)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)

                // Bottom Padding for Nav Dock
                Spacer()
                    .frame(height: 110)
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
        // Add Account Sheet
        .sheet(isPresented: $viewModel.showAddAccountSheet) {
            AccountFormSheet(service: service, mode: .create)
        }
        // Edit Account Sheet
        .sheet(isPresented: $viewModel.showEditAccountSheet) {
            if let card = viewModel.selectedCard {
                AccountFormSheet(service: service, mode: .edit(card: card))
            }
        }
        // Split Expense Sheet
        .sheet(isPresented: $viewModel.showSplitSheet) {
            if let card = viewModel.selectedCard {
                SplitExpenseModal(service: service, initialCard: card)
            }
        }
        // Credit / Debit Transaction Sheet
        .sheet(isPresented: $viewModel.showTransactionFormSheet) {
            TransactionFormSheet(service: service, mode: viewModel.activeTransactionMode)
        }
        // Account Options Sheet (Other)
        .sheet(isPresented: $viewModel.showOptionsSheet) {
            if let card = viewModel.selectedCard {
                AccountOptionsSheet(
                    service: service,
                    card: card,
                    onEditTapped: {
                        viewModel.onEditAccountTapped()
                    }
                )
            }
        }
        .alert("Notice", isPresented: $viewModel.showAlertNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
