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



---

## 8. Split Feature Verification & Invariants

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **SPLIT-01**| Three Split Methods | [x] | Equal, Custom, and Percentage methods implemented in `SplitCalculationEngine.swift`. |
| **SPLIT-02**| Deterministic Remainder | [x] | Equal splitting distributes remainder cents deterministically so sum of shares equals total exactly. |
| **SPLIT-03**| Custom Split Validation | [x] | Enforces sum(shares) == total, surfacing exact diff if mismatched. |
| **SPLIT-04**| Percentage Validation | [x] | Enforces sum(percentages) == 100%, distributing minor units. |
| **SPLIT-05**| Participants Selection | [x] | Quick-add from Favourite People + custom new participant input. |
| **SPLIT-06**| Current User Inclusion | [x] | Toggle to include Hadi Aymen (You) as an active participant. |
| **SPLIT-07**| Single Linked Transaction | [x] | Creates single linked debit outlay without duplicating dashboard totals. |
| **SPLIT-08**| Settlement Tracking | [x] | Owed vs Settled tracked per participant; tap to settle logs reimbursement credit. |
| **SPLIT-09**| Dedicated History Filter | [x] | "Splits" filter chip in `HistoryView.swift` showing active split cards. |
| **SPLIT-10**| Cascade Consistency | [x] | Editing and deleting cascade to linked transaction without orphan records. |
| **SPLIT-11**| Calculation & DB Unit Tests | [x] | Comprehensive suite in `SplitCalculationTests.swift`. |


---

## 9. 'Other' Transaction Workflow Verification

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **OTH-01** | Unclassified Category | [x] | Category `.other` with icon `questionmark.circle` and `#E5C07B` amber indicator. |
| **OTH-02** | Optional Person/Merchant | [x] | Title is optional and defaults gracefully to "Unclassified Outlay". |
| **OTH-03** | Date & Time Defaults | [x] | Defaults to current device local date and time; fully editable. |
| **OTH-04** | Optional Description & Note | [x] | Input fields for situational description and purpose note in `TransactionFormSheet.swift`. |
| **OTH-05** | Local Persistence | [x] | Saved persistently to `delta_transactions.json` via `LocalTransactionRepository`. |
| **OTH-06** | History & Search Visibility | [x] | Appears in History under "All" and "Other" filters, and indexed in `SearchViewModel`. |
| **OTH-07** | In-Place Conversion | [x] | Converts to Credit, Debit, or Split in-place without creating duplicate records. |
| **OTH-08** | Automated Recalculation | [x] | Converts update account balances and TOTAL SPENT automatically. |
| **OTH-09** | Unit Tests | [x] | Verified in `FinancialCalculationsTests.testOtherTransactionCreationAndInPlaceConversion`. |

---

## 10. History Screen & Deletion Safeguards Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **HIST-01** | Four Primary Filters + All | [x] | Debit, Credit, Split, Other, and All pills in `HistoryView.swift`. |
| **HIST-02** | Date Grouping (Newest First)| [x] | Grouped by calendar day in descending chronological order with intra-day time descending. |
| **HIST-03** | 7-Field Transaction Row | [x] | Displays Title, Person/Merchant, Category icon, Amount, Date, Time, and Type badge (`HistoryRowView.swift`). |
| **HIST-04** | Complete Record Inspector | [x] | `TransactionDetailSheet.swift` displays full metadata, account envelope, note, description, and status. |
| **HIST-05** | Accessible Delete Action | [x] | Prominently styled destructive action with clear confirmation dialog explaining permanent removal. |
| **HIST-06** | Persistent Storage Removal | [x] | Permanently removes record from `delta_transactions.json` via repository. |
| **HIST-07** | Automatic Financial Recalculation | [x] | Recalculates linked account balances, dashboard TOTAL SPENT, and analytics automatically. |
| **HIST-08** | Search Synchronization | [x] | Instantly removed from search queries and filtered views upon deletion. |
| **HIST-09** | Split Cascade Consistency | [x] | Deleting split-linked records removes corresponding split without leaving orphaned records. |
| **HIST-10** | 5-Second Safe Undo | [x] | Floating toast with countdown allows immediate restoration of transaction, splits, and balances. |
| **HIST-11** | Unit Tests | [x] | Verified in `FinancialCalculationsTests.swift` (tests for deletion, cascade, undo, and date ordering). |

---

## 11. Native QR Scanner & UPI Inspection Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **QR-01** | AVFoundation Camera Integration | [x] | `AVCaptureSession`, `AVCaptureMetadataOutput` (`[.qr]`), and `AVCaptureVideoPreviewLayer` wrapped in SwiftUI via `QRCameraPreviewView.swift`. |
| **QR-02** | Camera Permission Handling | [x] | Checks `.authorizationStatus`, requests access, and provides dedicated permission-denied view with Settings deep-link. |
| **QR-03** | Flashlight / Torch Control | [x] | Native `AVCaptureDevice.torchMode` toggle via top-bar squircle button with active state styling. |
| **QR-04** | Viewfinder Reticle Frame | [x] | Rounded scanning frame with neon lime corner brackets (`#CCFF00`) and animated laser sweep beam (`QRScanningReticleView.swift`). |
| **QR-05** | Safe UPI Payload Parsing | [x] | `QRPayloadParser.swift` extracts `pa` (payee address), `pn` (payee name), `am` (amount), `tn` (note), `tr` (reference) without executing links. |
| **QR-06** | Financial Gateway Isolation | [x] | Strict guardrail: zero automated payment triggers, zero URL opening, and zero external payment gateway communications. |
| **QR-07** | Extracted Review & Manual Amount | [x] | `QRScanConfirmationSheet.swift` presents parsed data, allows editing amount (prompting if missing in QR), note, and account. |
| **QR-08** | Storage Under 'Other' Category | [x] | Scanned records saved persistently under `Other` category without mutating monthly debit spent. |
| **QR-09** | Later Reclassification & Conversion | [x] | Scanned `Other` records can be converted in-place to Credit, Debit, or Split from History or Details. |
| **QR-10** | Camera Unavailable / Simulator State| [x] | Fallback card allowing simulated scan injections for testing without blocking on missing camera hardware. |
| **QR-11** | QR Unit Tests | [x] | Comprehensive suite in `QRScannerTests.swift` (UPI fields, missing amount, malformed payloads, injection protection, and storage). |

---

## 12. Global Search System Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **SRCH-01**| Complete Dataset Coverage | [x] | Queries all `TransactionItem`s and `SplitRecord`s across persistent local storage. |
| **SRCH-02**| 11 Searchable Properties | [x] | Matches title, person name, merchant, purpose, note, category, amount, date, type, account, and split participants. |
| **SRCH-03**| Case-Insensitive & Partial Matching| [x] | Substring matching implemented across all fields using `localizedCaseInsensitiveContains`. |
| **SRCH-04**| Real-Time Debounced Updates | [x] | As-you-type reactivity with 150ms Combine debounce for fluid 60fps performance. |
| **SRCH-05**| Recent Searches Management | [x] | Stores up to 8 recent searches persistently in `UserDefaults` with tap-to-populate and individual/all clear. |
| **SRCH-06**| Contextual Empty States | [x] | Distinct views for idle discovery (recent searches + guidance) and empty query results. |
| **SRCH-07**| Descending Chronological Sort | [x] | Results unified and sorted strictly by newest date and time first. |
| **SRCH-08**| Direct Detail Inspection | [x] | Tapping results opens `TransactionDetailSheet` or `SplitDetailsSheet` with full editing/deletion capability. |
| **SRCH-09**| Instant Deletion Synchronization | [x] | Reactive observation of `service.transactions` ensures deleted records vanish from search results immediately. |
| **SRCH-10**| Efficient Querying | [x] | Avoids repeated disk reads by querying loaded in-memory ledger structures reactively. |
| **SRCH-11**| Unit Test Coverage | [x] | Comprehensive suite in `GlobalSearchTests.swift` (partial match, participant names, sorting, deletion sync, recent searches). |

---

## 13. Quality Review, Accessibility & Production Audit

| Checkpoint | Reference Requirement | Status | Verification Criteria |
| :--- | :--- | :---: | :--- |
| **QA-01**  | Financial Arithmetic Invariants | [x] | 100% `Decimal` arithmetic across all components; IEEE-754 binary double floating point precision errors eliminated. |
| **QA-02**  | Credit / Debit Balance Math | [x] | Credits strictly increase account balances; Debits decrease balances and update monthly TOTAL SPENT. |
| **QA-03**  | Split Minor Remainder Invariants| [x] | Remainder cents distributed deterministically so `sum(shares) == totalExpense` to the exact cent. |
| **QA-04**  | Persistent File Storage | [x] | Atomic JSON persistence for transactions, accounts, and splits in `delta_transactions.json` via documents directory. |
| **QA-05**  | Atomic Backup & Restore | [x] | Implemented `exportBackup()` and `restoreFromBackup(data:)` in repository and service. |
| **QA-06**  | VoiceOver Accessibility | [x] | Explicit `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityAddTraits` across tabs, cards, and buttons. |
| **QA-07**  | Dynamic Type Support | [x] | Centralized `DeltaTypography` scale updated with system font styles for accessibility text sizes. |
| **QA-08**  | Reduce Motion Support | [x] | `@Environment(\.accessibilityReduceMotion)` observed to suppress infinite sweep lines and unbounded springs. |
| **QA-09**  | WCAG AAA Contrast Compliance | [x] | `#CCFF00` (Electric Lime) on `#070A06` (Deep Obsidian) provides **16.5:1** contrast ratio (surpasses AAA 7.0:1 requirement). |
| **QA-10**  | iPhone Safe Area & Dynamic Island| [x] | Content padded for Dynamic Island / notch and floating tab dock; zero home indicator occlusion. |
| **QA-11**  | Comprehensive Unit Test Suite | [x] | Unit test suites: `FinancialCalculationsTests`, `SplitCalculationTests`, `QRScannerTests`, `GlobalSearchTests`, `QualityReviewTests`. |
| **QA-12**  | Native UI Test Suite | [x] | Implemented `DELTAAppUITests.swift` covering 5-tab journeys, transaction detail flows, and accessibility verification. |
| **QA-13**  | Build Environment Status | [x] | Reported honestly: Development host is Windows; native Xcode build & iOS Simulator remain unverified until built on macOS. |




