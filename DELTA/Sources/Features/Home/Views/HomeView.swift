import SwiftUI

/// Main Home Dashboard View matching the middle phone of the approved reference design.
/// Features Hadi Aymen profile header, TOTAL SPENT monthly calculation, two quick actions (Credit & Debit),
/// Favourite People carousel, and Recent Transactions in strict descending chronological order.
public struct HomeView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: HomeViewModel

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: HomeViewModel(service: service))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // 1 & 2. Profile Header with Hadi Aymen and Notification Shortcut
                HomeHeaderView(
                    service: service,
                    onNotificationTapped: {
                        viewModel.onNotificationTapped()
                    },
                    onTrophyTapped: {
                        viewModel.onTrophyTapped()
                    }
                )

                // 3, 4, 5 & 6. Large Lime Financial Summary Card
                LimeSurfaceCard(showNotch: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        // Card Header: TOTAL SPENT & Menu
                        HStack {
                            Text("TOTAL SPENT")
                                .font(.system(size: 13, weight: .bold, design: .default))
                                .tracking(0.8)
                                .foregroundColor(Color.deltaTextOnLime.opacity(0.82))

                            Spacer()

                            Button(action: {
                                service.toggleAmountVisibility()
                            }) {
                                Image(systemName: DeltaIcons.optionsMenu)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.deltaTextOnLime)
                                    .padding(4)
                            }
                        }

                        // Hero Amount & Amount Visibility Toggle
                        HStack(alignment: .center, spacing: 12) {
                            Text(service.formattedTotalSpent)
                                .font(DeltaTypography.displayHero)
                                .foregroundColor(Color.deltaTextOnLime)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            // 5. Amount Visibility Toggle
                            Button(action: {
                                service.toggleAmountVisibility()
                            }) {
                                Image(systemName: service.isAmountVisible ? DeltaIcons.balanceVisible : DeltaIcons.balanceHidden)
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundColor(Color.deltaTextOnLime)
                            }
                        }

                        // 4. Monthly Spending Comparison Metric Badge
                        MetricBadge(
                            text: service.spendingComparisonText,
                            isPositive: !service.spendingComparisonIsIncrease
                        )

                        // 6. Two Quick Actions: Credit and Debit
                        QuickActionGrid(
                            onCredit: { viewModel.onCreditTapped() },
                            onDebit: { viewModel.onDebitTapped() }
                        )
                        .padding(.top, 4)
                    }
                }

                // Spacing to Dark Canvas Content
                Spacer()
                    .frame(height: 24)

                // State Handling: Loading, Error, or Loaded Content
                switch service.state {
                case .loading:
                    LoadingSkeletonView()
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                case .error(let errorMessage):
                    ErrorStateView(errorMessage: errorMessage) {
                        viewModel.retryLoading()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                case .idle, .loaded, .empty:
                    VStack(spacing: 28) {
                        // 7 & 9. Horizontally Scrollable Favourite People Section with View All
                        FavoriteContactsSection(
                            people: service.favouritePeople,
                            onAddPerson: {
                                viewModel.onViewAllPeopleTapped()
                            },
                            onSelectPerson: { person in
                                viewModel.onSelectPerson(person)
                            },
                            onViewAll: {
                                viewModel.onViewAllPeopleTapped()
                            }
                        )

                        // 8 & 9. Recent Transactions Section (Strict Descending Chronological Order) with View All
                        RecentTransactionsSection(
                            transactions: service.transactions,
                            onViewAll: {
                                viewModel.onViewAllTransactionsTapped()
                            },
                            onSelectTransaction: { item in
                                viewModel.onSelectTransaction(item)
                            }
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Bottom Padding for Floating Tab Dock
                Spacer()
                    .frame(height: 110)
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
        // Unified Transaction Form Sheet (Create Credit, Create Debit, Edit/Delete)
        .sheet(isPresented: $viewModel.showTransactionFormSheet) {
            TransactionFormSheet(
                service: service,
                mode: viewModel.activeFormMode
            )
        }
        // View All People Directory Sheet
        .sheet(isPresented: $viewModel.showPeopleDirectorySheet) {
            PeopleDirectorySheet(service: service)
        }
        // View All Recent Transactions Sheet
        .sheet(isPresented: $viewModel.showAllTransactionsSheet) {
            AllTransactionsSheet(service: service)
        }
        // Notification Alert / Modal
        .alert("DELTA Notifications", isPresented: $viewModel.showNotificationsSheet) {
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text("You have \(service.unreadNotificationCount) budget alerts. Monthly spending is tracking on budget.")
        }
        // Milestone Alert
        .alert("Savings Milestone", isPresented: $viewModel.showTrophyMilestone) {
            Button("Nice!", role: .cancel) {}
        } message: {
            Text("Congratulations, Hadi Aymen! You stayed within your dining budget this week.")
        }
    }
}

// MARK: - Loading Skeleton Shimmer
private struct LoadingSkeletonView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.deltaBgOliveDark)
                .frame(height: 48)
                .opacity(isAnimating ? 0.35 : 0.75)

            VStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .frame(height: 62)
                        .opacity(isAnimating ? 0.35 : 0.75)
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Error State View with Retry
private struct ErrorStateView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.deltaExpenseRed)

            Text("Error Loading Data")
                .font(DeltaTypography.sectionHeader)
                .foregroundColor(Color.deltaTextOnDark)

            Text(errorMessage)
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextMutedDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: onRetry) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(DeltaTypography.actionLabel)
                .foregroundColor(Color.deltaTextOnLime)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.deltaSurfaceLime)
                )
            }
            .buttonStyle(SquircleButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.deltaBgOliveDark)
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
        )
    }
}
