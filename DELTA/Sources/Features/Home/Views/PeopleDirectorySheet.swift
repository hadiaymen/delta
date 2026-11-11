import SwiftUI

/// Directory of all favourite contacts and payees with addition flow.
public struct PeopleDirectorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var service: ExpenseTrackingService

    @State private var showingAddAlert: Bool = false
    @State private var newName: String = ""
    @State private var newPhone: String = ""

    public init(service: ExpenseTrackingService) {
        self.service = service
    }

    public var body: some View {
        DeltaModalSheet(title: "Favourite People", onClose: { dismiss() }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Search / Add Header
                    HStack {
                        Text("Manage Payees (\(service.favouritePeople.count))")
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaTextMutedDark)

                        Spacer()

                        Button(action: {
                            showingAddAlert = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add New")
                            }
                            .font(DeltaTypography.actionLabel)
                            .foregroundColor(Color.deltaSurfaceLime)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // People List
                    ForEach(service.favouritePeople) { person in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "233215"))
                                    .frame(width: 44, height: 44)

                                Text(person.initials)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.deltaSurfaceLime)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(person.name)
                                    .font(DeltaTypography.bodySemibold)
                                    .foregroundColor(Color.deltaTextOnDark)

                                Text(person.maskedIdentifier)
                                    .font(DeltaTypography.captionMeta)
                                    .foregroundColor(Color.deltaTextMutedDark)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.deltaTextMutedDark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.deltaBgOliveDark)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.deltaBorderOlive, lineWidth: 1))
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .alert("Add Favourite Person", isPresented: $showingAddAlert) {
            TextField("Full Name (e.g. Samira Khan)", text: $newName)
            TextField("Masked Phone or ID (e.g. *****19)", text: $newPhone)
            Button("Add") {
                if !newName.isEmpty {
                    Task {
                        await service.addFavouritePerson(
                            name: newName,
                            identifier: newPhone.isEmpty ? "*****" + String(Int.random(in: 10...99)) : newPhone
                        )
                        newName = ""
                        newPhone = ""
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

