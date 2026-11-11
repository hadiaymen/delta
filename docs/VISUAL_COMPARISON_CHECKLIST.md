# DELTA — Visual Comparison & Fidelity Checklist

> **Purpose**: Use this checklist to audit and guarantee pixel-accurate compliance with the reference image (`reference/reference-ui.jpg`, MONO UI Reference) and the approved Figma design (`Recreate DELTA Finance UI`).
> Every item must be verified against the design authority before code is merged or approved.

---

## 1. Global Visual Direction & Palette Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **G-01** | Deep Obsidian Background | [x] | Implemented via `Color.deltaBgCanvas` (`#070A06`) in `ColorTokens.swift`. |
| **G-02** | Deep Olive Undertones | [x] | Implemented via `Color.deltaBgOliveDark` (`#121A0F`) in `ColorTokens.swift`. |
| **G-03** | Electric Neon Lime Accents | [x] | Implemented via `Color.deltaSurfaceLime` (`#CCFF00`) in `ColorTokens.swift`. |
| **G-04** | Chartreuse Card Gradient | [x] | Implemented via `DeltaGradients.cardSurface` (`#7DA815` to `#39500A`). |
| **G-05** | Superseded Themes Rejected | [x] | No light/ivory themes included; `.preferredColorScheme(.dark)` enforced. |
| **G-06** | Dark Mode Exclusivity | [x] | RootView & DELTAApp locked to dark mode. |

---

## 2. Geometry, Squircles & Surfacing Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **GEO-01** | Rounded Lime Surfaces | [x] | `LimeSurfaceCard.swift` with `radiusHeroSurface` (32pt) & downward notch. |
| **GEO-02** | Downward Curve / Notch Accent | [x] | Bottom center chevron indicator on lime surface in `LimeSurfaceCard.swift`. |
| **GEO-03** | Dark Rounded-Square Action Buttons | [x] | `SquircleButton.swift` with continuous `radiusSquircleButton` (18pt). |
| **GEO-04** | Raised Center Scan Circle | [x] | `DeltaTabBar.swift` features elevated 58pt circular button with QR glyph. |
| **GEO-05** | Viewport Density & Proportions | [x] | Exact mobile layout density matching reference screens. |

---

## 3. Five-Tab Navigation Composition Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **NAV-01** | Full Dock Neon Lime Styling | [x] | Continuous `#CCFF00` dock background with continuous corner curvature. |
| **NAV-02** | Destination 1: Home | [x] | House symbol and "Home" label in `DeltaTabBar.swift`. |
| **NAV-03** | Destination 2: Cards | [x] | Credit card symbol and "Cards" label in `DeltaTabBar.swift`. |
| **NAV-04** | Destination 3: Scan (Center) | [x] | Elevated circular trigger with QR viewfinder in `DeltaTabBar.swift`. |
| **NAV-05** | Destination 4: History | [x] | Clock symbol and "History" label in `DeltaTabBar.swift`. |
| **NAV-06** | Destination 5: Search | [x] | Magnifying glass and "Search" label in `DeltaTabBar.swift`. |
| **NAV-07** | Active / Selected State | [x] | Selected tab displays dark filled glyph against neon lime surface. |

---

## 4. Screen 1: Log Outlay / Numeric Keypad Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **S1-01** | Header Navigation Bar | [x] | Back squircle, "Send Money", bell squircle in `OutlayEntrySheet.swift`. |
| **S1-02** | "Transfer from" Lime Container | [x] | Lime card with avatar, account `******5890`, dark balance pill `$23,590.73`. |
| **S1-03** | Hero Amount Display | [x] | Centered large amount display with vertical cursor line. |
| **S1-04** | Limit Progress Slider | [x] | "Transfer Limits" slider indicator with `$10,000.00` maximum. |
| **S1-05** | Quick Send Payees Row | [x] | `+` squircle and horizontal contact avatar pills with masked IDs. |
| **S1-06** | 3x4 Squircle Numeric Keypad | [x] | 12 dark squircle keys in `NumericKeypadView.swift` with realistic accumulation. |
| **S1-07** | "Hold To Send" Bottom Button | [x] | Full-width rounded neon lime action surface in `OutlayEntrySheet.swift`. |

---

## 5. Screen 2: Main Dashboard ("Home") Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **S2-01** | User Profile Header | [x] | Avatar ("HA"), "Hadi Aymen", "@hadiaymen", trophy and notification badge in `HomeHeaderView.swift`. |
| **S2-02** | Large Lime Summary Card | [x] | Hero lime card (`#CCFF00`) with downward notch in `LimeSurfaceCard.swift`. |
| **S2-03** | TOTAL SPENT & Dynamic Sum | [x] | Label is "TOTAL SPENT" with real sum calculated from actual Debit transactions in selected month. |
| **S2-04** | Monthly Spending Comparison | [x] | `MetricBadge.swift` dynamically calculates percentage comparison vs previous month debits. |
| **S2-05** | Amount Visibility Toggle | [x] | Eye toggle switches between real formatted currency and `$••••••` in `HomeView.swift`. |
| **S2-06** | Two Quick Actions: Credit & Debit | [x] | Symmetrical dark squircle buttons for Credit (↙) and Debit (↗) in `QuickActionGrid.swift`. |
| **S2-07** | Favourite People Carousel | [x] | "Favourite People" with `+` squircle, horizontal avatar chips, and "View all >" in `FavoriteContactsSection.swift`. |
| **S2-08** | Recent Transactions Feed | [x] | Strict descending chronological sorting by date/time, date grouping, and "View all >" in `RecentTransactionsSection.swift`. |
| **S2-09** | Real Repository Data | [x] | `LocalTransactionRepository.swift` backs all calculations and persistence without static demo mock numbers. |
| **S2-10** | Loading, Empty & Error States | [x] | `LoadingSkeletonView`, `ErrorStateView` with retry, and empty state containers built into `HomeView.swift`. |

---

## 6. Screen 3: Cards & Accounts Deck Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **S3-01** | Cards Top Bar | [x] | Back squircle, "Cards" title, notification bell squircle in `CardsView.swift`. |
| **S3-02** | Stacked Deck Presentation | [x] | Overlapping layered cards with realistic depth, spring stack transitions, and depth scaling in `StackedCardDeckView.swift`. |
| **S3-03** | Visual Dummy Accounts | [x] | DELTA PERSONAL, DELTA CASH, DELTA SAVINGS & user accounts; NO usable card numbers, CVVs or expiry dates. |
| **S3-04** | Four Quick Actions | [x] | Exactly four actions: Split, Credit, Debit, Other with real connected workflows in `CardQuickActionsView.swift`. |
| **S3-05** | Card Stack Interactions | [x] | Horizontal swipe, tap-to-select, selected card expansion, and live balance display. |
| **S3-06** | Account Management (CRUD) | [x] | Add Account, Edit Account, and Remove Account workflows via `AccountFormSheet.swift`. |
| **S3-07** | Bottom Card Peek | [x] | Peeking bottom surface with `+ Add Account` (`+ Add Cards`) above navigation dock. |

---

## 7. Functional Scope & Guardrails Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **FN-01** | Expense Tracker Only | [x] | Application is strictly configured as a personal expense tracker. |
| **FN-02** | Zero Real Banking Operations | [x] | No banking transfer/ACH/payment gateways implemented. |
| **FN-03** | Dummy Visual Cards | [x] | Cards represent personal budget envelopes only (`DummyAccountCard.swift`). |
| **FN-04** | Change Approval Gate | [x] | Zero design alterations; strictly follows reference authority. |
| **FN-05** | Application Identity | [x] | App name permanently set to **DELTA**. |

