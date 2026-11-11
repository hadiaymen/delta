import SwiftUI

/// DELTA — Native iOS Personal Expense Tracker
/// Built with SwiftUI for iOS 17+.
@main
struct DELTAApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .preferredColorScheme(.dark)
        }
    }
}

