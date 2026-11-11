import SwiftUI

/// Search destination screen utilizing the centralized TransactionCard component.
public struct SearchView: View {
    @ObservedObject public var service: ExpenseTrackingService
    @StateObject private var viewModel: SearchViewModel

    public init(service: ExpenseTrackingService) {
        self.service = service
        self._viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Top Bar
                HStack {
                    Spacer()

                    Text("Search")
                        .font(DeltaTypography.screenTitle)
                        .foregroundColor(Color.deltaTextOnDark)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Search Bar Input
                HStack(spacing: 10) {
                    Image(systemName: DeltaIcons.tabSearch)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.deltaTextMutedDark)

                    TextField("Search expenses, tags, or IDs...", text: $viewModel.searchText)
                        .font(DeltaTypography.bodyRegular)
                        .foregroundColor(Color.deltaTextOnDark)
                        .autocorrectionDisabled()

                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.deltaBgOliveDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.deltaBorderOlive, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Category Chips Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExpenseCategory.allCases) { category in
                            let isSelected = viewModel.selectedCategory == category
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if isSelected {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 12))

                                    Text(category.rawValue)
                                        .font(DeltaTypography.actionLabel)
                                }
                                .foregroundColor(isSelected ? Color.deltaTextOnLime : Color.deltaTextMutedDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
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

                // Search Results Ledger
                VStack(spacing: 12) {
                    ForEach(viewModel.searchResults) { item in
                        TransactionCard(
                            title: item.title,
                            subtitle: item.trxID,
                            amountString: item.formattedAmount,
                            timeString: item.timeString,
                            direction: item.type == .debit ? .outflow : .inflow,
                            action: {}
                        )
                    }
                }
                .padding(.horizontal, 20)

                // Bottom Padding for Nav Dock
                Spacer()
                    .frame(height: 110)
            }
        }
        .background(Color.deltaBgCanvas.ignoresSafeArea())
    }
}
