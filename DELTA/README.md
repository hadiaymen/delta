# DELTA — Native iOS Application Foundation

> **Mandatory Design Authority**: Reference image (`reference/reference-ui.jpg`, MONO UI Reference) and approved Figma specification.
> **Scope**: Personal Expense Tracker built natively in Swift & SwiftUI targeting iOS 17+.

---

## 1. Project Overview & Architecture

DELTA is structured as a clean, modular SwiftUI application with strict separation between design system tokens, core services, and feature modules.

```
DELTA/
├── Package.swift                     # Swift Package Manager manifest (iOS 17+)
├── Resources/
│   └── Info.plist                    # App metadata, bundle ID, camera permissions
└── Sources/
    ├── App/
    │   ├── DELTAApp.swift            # @main SwiftUI App entry point
    │   ├── RootView.swift            # 5-tab coordinator & safe area / dynamic island shell
    │   └── AppEnvironment.swift      # Dependency injection container
    ├── Core/
    │   ├── Models/
    │   │   └── ExpenseCategory.swift # Budget envelope categories (Dining, Groceries, etc.)
    │   └── Services/
    │       └── ExpenseTrackingService.swift # Local-first expense tracking state
    ├── DesignSystem/
    │   ├── Theme/
    │   │   ├── ColorTokens.swift     # Deep obsidian, dark olive, neon lime, card gradients
    │   │   ├── Typography.swift      # High-contrast grotesque/fintech typography scale
    │   │   ├── Dimensions.swift      # Squircle corner radii, button sizes, dock metrics
    │   │   └── Gradients.swift       # Signature chartreuse-to-olive linear gradients
    │   └── Components/
    │       ├── SquircleButton.swift  # Tactile dark rounded-square action buttons
    │       ├── LimeSurfaceCard.swift # Downward-notched neon lime hero surface container
    │       ├── MetricBadge.swift     # Compact pill badge (↑ 24% Last week)
    │       ├── NavigationDestination.swift # 5 strict destinations enum
    │       └── DeltaTabBar.swift     # Floating neon lime dock with raised center Scan button
    └── Features/
        ├── Home/                     # Main dashboard view matching center reference screen
        ├── Cards/                    # Stacked account deck matching right reference screen
        ├── Scan/                     # Receipt & QR scanner view (elevated center tab)
        ├── History/                  # Full transaction ledger with filters
        ├── Search/                   # Query expenses, payees, tags, and categories
        └── OutlayEntry/              # Numeric keypad modal matching left reference screen
```

---

## 2. Five Main Navigation Destinations

1. **Home**: Primary balance overview (`$23,590.73`), privacy toggle, 4 squircle triggers (Send, Request, Payment, Withdraw), frequent contacts row, and recent transactions feed.
2. **Cards**: Stacked visual dummy cards (chartreuse front card with VISA / cardholder metadata, peeking rear card), 2x4 quick actions grid, and `+ Add Cards` peek.
3. **Scan**: Elevated circular center button (`58pt` diameter) on the neon lime dock triggering receipt optical scanning and instant expense logging.
4. **History**: Filterable transaction audit trail (All, Outflows, Inflows).
5. **Search**: Search bar with category chips (Dining, Utilities, Groceries, Shopping) and live result filtering.

---

## 3. How to Open and Run in Xcode

1. Open Xcode on macOS (Xcode 15+ / iOS 17 SDK).
2. Choose **File > Open...** and select `delta/DELTA` (or `Package.swift`).
3. Select an iOS 17+ Simulator (e.g., iPhone 15 Pro, iPhone 16 Pro).
4. Press **Cmd + R** to run.

---

## 4. Environment & Compilation Notice

> [!WARNING]
> Because this workspace is running in a Windows environment where Xcode and the Apple Swift toolchain are unavailable, the native Swift and SwiftUI source code has been authored to strict iOS 17+ API standards, but **native compilation remains unverified** until opened on macOS with Xcode.

