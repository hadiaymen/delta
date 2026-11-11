# DELTA — Design System & Visual Specification

> **Mandatory Authority**: Reference image (`reference/reference-ui.jpg`, MONO UI Reference) & approved Figma specification (`Recreate DELTA Finance UI`).
> **Superseded Direction**: All prior white/ivory/light themes are permanently replaced.
> **Scope**: DELTA is a personal expense tracker. Dummy account cards are purely visual representations of user expense categories/budgets. Real banking transfers and payment initiations are strictly prohibited.

---

## 1. Color Palette Tokens

The DELTA visual character is defined by a high-contrast contrast between deep obsidian blacks, muted organic dark olives, and electric neon lime surfaces.

```
       DEEP OBSIDIAN CANVAS             PRIMARY SURFACES              CARD GRADIENT
   ┌──────────────────────────┐    ┌──────────────────────────┐    ┌──────────────────────────┐
   │                          │    │                          │    │  #7DA815 (Chartreuse)    │
   │   #070A06 (Base Canvas)  │    │  #CCFF00 (Electric Lime) │    │           │              │
   │   #0B100A (Card Canvas)  │    │  #C4F822 (Bright Lime)   │    │           ▼              │
   │   #121A0F (Olive Dark)   │    │  #080C08 (Dark On-Lime)  │    │  #39500A (Forest Olive)  │
   └──────────────────────────┘    └──────────────────────────┘    └──────────────────────────┘
```

### 1.1 Palette Specifications

| Token Name | Hex Code | Tailwind Equivalent / CSS Variable | Usage |
| :--- | :--- | :--- | :--- |
| **`bg-canvas`** | `#070A06` | `--color-bg-canvas: #070A06` | Primary background across all screens |
| **`bg-canvas-subtle`** | `#0B100A` | `--color-bg-subtle: #0B100A` | Secondary section background |
| **`bg-olive-dark`** | `#121A0F` | `--color-bg-olive-dark: #121A0F` | Card action buttons, pill containers, list items |
| **`bg-olive-hover`** | `#1A2416` | `--color-bg-olive-hover: #1A2416` | Pressed / hover states for dark buttons |
| **`surface-lime`** | `#CCFF00` | `--color-surface-lime: #CCFF00` | Primary top hero card surface & bottom nav dock |
| **`surface-lime-bright`** | `#C4F822` | `--color-surface-lime-bright: #C4F822`| Accent highlights and badges |
| **`surface-lime-muted`** | `#A6D908` | `--color-surface-lime-muted: #A6D908` | Secondary lime indicators, subheaders on lime |
| **`card-grad-start`** | `#7DA815` | `--color-card-grad-start: #7DA815` | Stacked card top gradient stop |
| **`card-grad-end`** | `#39500A` | `--color-card-grad-end: #39500A` | Stacked card bottom gradient stop |
| **`card-stacked-peek`** | `#1E2B08` | `--color-card-peek: #1E2B08` | Darker undertone for secondary stacked card behind |
| **`text-primary-dark`** | `#080C08` | `--color-text-on-lime: #080C08` | Typography rendered on neon lime surfaces |
| **`text-primary-light`**| `#F3F6F0` | `--color-text-on-dark: #F3F6F0` | Primary headings and values on dark canvas |
| **`text-secondary-light`**|`#8E998B` | `--color-text-muted-dark: #8E998B` | Subtitles, TrxIDs, timestamps on dark canvas |
| **`text-secondary-dark`** |`#2B3523` | `--color-text-muted-lime: #2B3523` | Secondary labels on neon lime surface |
| **`accent-expense-red`** | `#FF5C5C` | `--color-expense-red: #FF5C5C` | Negative outflow / expense amounts (`-$450.00`) |
| **`accent-income-green`**| `#CCFF00` | `--color-income-green: #CCFF00` | Positive inflow / income amounts (`+$1,250.00`) |
| **`border-subtle-olive`**| `#1B2616` | `--color-border-olive: #1B2616` | 1px clean separators on dark backgrounds |

---

## 2. Typography Hierarchy

The typographic tone is technical, clean, and modern fintech. Fonts recommended: **Plus Jakarta Sans**, **Inter**, or **SF Pro Display**.

| Element | Size / Line Height | Weight | Letter Spacing | Color Context |
| :--- | :--- | :--- | :--- | :--- |
| **Display Hero Amount** | `38px` / `44px` | Bold (`700`) | `-0.03em` (Tight) | On Lime: `#080C08` / On Dark: `#F3F6F0` |
| **Screen Title** | `18px` / `24px` | SemiBold (`600`) | `-0.01em` | On Lime: `#080C08` / On Dark: `#F3F6F0` |
| **Section Header** | `16px` / `22px` | SemiBold (`600`) | `-0.01em` | `#F3F6F0` with `#8E998B` "View all >" |
| **Action Button Label** | `12px` / `16px` | Medium (`500`) | `0em` | On Lime: `#080C08` / On Dark: `#8E998B` |
| **Card Cardholder Name**| `16px` / `20px` | Bold (`700`) | `0em` | Clean off-white `#F5FAF0` on card gradient |
| **Card Masked Number** | `15px` / `20px` | SemiBold (`600`) | `0.08em` (Mono tracking) | Embossed soft lime `#DDF5A8` |
| **Transaction Title** | `14px` / `18px` | SemiBold (`600`) | `-0.01em` | `#F3F6F0` |
| **Transaction TrxID** | `11px` / `14px` | Regular (`400`) | `0.02em` | `#8E998B` |
| **Transaction Amount** | `14px` / `18px` | Bold (`700`) | `-0.01em` | Red `#FF5C5C` / Lime `#CCFF00` |
| **Keypad Digits** | `22px` / `28px` | SemiBold (`600`) | `0em` | `#F3F6F0` centered in dark squircle |

---

## 3. Geometry, Border Radii & Elevation

The visual signature is characterized by exaggerated rounded pill headers juxtaposed with sharp precision squircle buttons.

| Component Level | Border Radius | Description |
| :--- | :--- | :--- |
| **Hero Surface Header** | `32px` to `36px` bottom corners | Creates the iconic downward rounded neon envelope |
| **Stacked Account Cards**| `24px` | Smooth rounded credit-card proportions (aspect ratio ~ 1.58:1) |
| **Action Squircle Buttons**| `18px` to `20px` | `w-14 h-14` or `w-16 h-16` rounded square containers |
| **Center Scan Button** | `9999px` (Full circle) | Elevated `56px` diameter circle nested on the neon dock |
| **Navigation Dock** | `32px` to `40px` | Floating pill bar floating above the screen bottom indicator |
| **Keypad Buttons** | `18px` | Grid squircle keys with tactile dark surface |
| **Pill Badges** | `9999px` | Compact status tags (e.g., `↑ 24%  Last week`) |

---

## 4. Detailed Screen Compositions

### 4.1 Screen 1: Log Outlay & Expense Entry ("Send / Quick Send" Equivalent)
*Note: In DELTA, this represents logging a single expense outlay or payment record.*

- **Top Navigation**:
  - Left: Back arrow icon in dark rounded square (`42x42px`, `#121A0F`).
  - Center: Title "Send Money" (Expense Log).
  - Right: Bell icon in dark rounded square (`42x42px`, `#121A0F`).
- **Account Selection Card**:
  - Lime surface container (`#CCFF00`) with rounded corners (`28px`).
  - Label: "Transfer from" / "Expense Account".
  - Selected account pill: Avatar, masked account ID `******5890`, dark balance pill badge `$23,590.73`, swap account trigger.
- **Hero Outlay Value**:
  - Displayed prominently in deep canvas: `$1,500.00` with subtle vertical cursor line.
  - Category / Expense Limit Slider: Horizontal progress bar indicator showing limit threshold (`$10,000.00`).
- **Quick Allocation Contacts / Payees**:
  - Header: "Quick Send" with "View all >".
  - Horizontal list: Circular `+` squircle button followed by frequent payee/store avatars (Alina, Mark, etc.) with masked IDs.
- **Keypad Matrix**:
  - 3x4 grid of dark rounded-square buttons (`#121A0F`) with off-white digits (`1` to `9`, return icon, `0`, backspace `x`).
- **Confirmation Action**:
  - Bottom neon lime curved surface: "Hold To Send" (Hold to record expense) with tactile interaction.

### 4.2 Screen 2: Main Dashboard ("Home")
- **Top Bar**:
  - User avatar thumbnail + user display name ("Janvis David") and handle (`@janvisd`).
  - Two right-aligned dark squircle action icons: Trophy / Achievement badge and Notification Bell.
- **Hero Lime Balance Container**:
  - Large rounded electric lime card (`#CCFF00`) dominating the upper 40% of the viewport.
  - Header: "Total Balance" with right three-dot menu `...`.
  - Amount: `$23,590.73` with visibility toggle eye icon.
  - Status Tag: Dark green pill badge `↑ 24%  Last week`.
  - 4 Squircle Action Triggers (Dark obsidian squares `#11160E` with crisp icons):
    1. **Send** (Diagonal up-right arrow) $\rightarrow$ Log Outlay
    2. **Request** (Diagonal down-left arrow) $\rightarrow$ Log Inflow
    3. **Payment** (Scanner/split icon) $\rightarrow$ Split / Tag Bill
    4. **Withdraw** (Tray/vault icon) $\rightarrow$ Category Transfer
  - Bottom edge features a subtle curved notch indicator.
- **Favorite Contacts / Frequent Payees**:
  - Header: "Favourite Contacts" with "View all >".
  - Add button `+` in dark rounded square + horizontal row of contact avatars with masked identifiers.
- **Recent Transactions Section**:
  - Header: "Transactions" with "View all >".
  - Group Header: "Today".
  - Transaction List Items:
    - Item 1: Dark squircle with diagonal up-right arrow, "Send Money to Kuraishi H.", `TrxID: CJ4901TUZO`, red amount `-$450.00`, timestamp `05:29 PM`.
    - Item 2: Dark squircle with diagonal down-left arrow, "Receive from Alina", `TrxID: CJ79OZ8UX4`, lime amount `+$1,250.00`, timestamp `12:37 PM`.
- **Bottom Navigation Dock**:
  - Neon lime dock (`#CCFF00`) housing 5 destinations.

### 4.3 Screen 3: Account & Category Deck ("Cards")
- **Top Bar**:
  - Back arrow in dark squircle, screen title "Cards", notification bell in dark squircle.
- **Stacked Card Presentation**:
  - Top Card: Linear chartreuse gradient (`#7DA815` $\rightarrow$ `#39500A`) with cardholder name ("Janvis David"), "VISA" dummy emblem, `))) Credit` contactless symbol, expiry `Valid thru 12/30`, masked dummy number `7820 5500 0835 3501`.
  - Background Stacked Card: Dark forest olive card edge peeking behind the main card, creating physical depth.
- **Quick Actions 2x4 Grid**:
  - Eight dark squircle buttons (`#121A0F`) with lime line icons:
    - Row 1: Send Money, Topup, Statements, Bills Pay
    - Row 2: Loans (Budget Loans), Freeze Cards, Limit Request, Deposits
- **Secondary Card Stack Peek**:
  - Bottom card surface (`+ Add Cards`) peeking above the navigation dock.
- **Bottom Navigation Dock**:
  - Neon lime dock with active state on "Cards" icon.

---

## 5. Five-Tab Navigation Specification

The navigation bar is a unified neon lime floating dock positioned at the bottom of each primary view.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│     [ Home ]      [ Cards ]       ( [QR] )       [ History ]  [ Search ]│
│                                    ( Scan )                             │
└─────────────────────────────────────────────────────────────────────────┘
   (Neon Lime Dock #CCFF00)      (Elevated Central Action)
```

1. **Home**: Dashboard view, balance overview, quick action triggers, recent transaction log.
2. **Cards**: Stacked visual dummy cards representing expense accounts and budget envelopes.
3. **Scan**: Elevated circular center button (`56px` diameter) with dark core and QR/barcode glyph. Triggers receipt scanning for instant expense logging.
4. **History**: Full chronological transaction ledger with filters by date, category, and account.
5. **Search**: Search and filtering tool for transactions, payees, tags, and amounts.

---

## 6. Iconography & Interaction Rules

- **Icon Style**: Linear strokes (`1.75px` to `2px` stroke weight), rounded caps and joins, matching the minimalist fintech icon family in the reference.
- **Squircle Buttons**: Fixed aspect ratio `1:1`, smooth `border-radius: 18px`, deep olive background `#121A0F`, icon color `#CCFF00` or `#F3F6F0`.
- **Haptic & Visual Feedback**: Subtle scale transformation (`scale(0.97)`) on press; soft neon glow highlight on active/focused states.
- **No Light Mode Override**: The dark/olive/lime visual system is the sole approved mode for DELTA. Light/ivory modes are superseded and must not be toggled or rendered.



---

## 7. Centralized SwiftUI Design Tokens & Reusable Components Architecture

The DELTA design system in Swift is organized under `DELTA/Sources/DesignSystem`:

### 7.1 Centralized Token Registry (`DeltaTokens`)
- **Colors** (`ColorTokens.swift`): Foundational obsidian canvas (`#070A06`), dark olive surfaces (`#121A0F`), electric neon lime (`#CCFF00`), and expense/income semantic accents.
- **Gradients** (`Gradients.swift`): Signature chartreuse gradient (`#7DA815` $\rightarrow$ `#39500A`), peeking card depth gradient, and scan radial halos.
- **Typography** (`Typography.swift`): High-contrast grotesque/fintech hierarchy (`displayHero`, `titleLarge`, `screenTitle`, `sectionHeader`, `cardNumber`, `captionMeta`).
- **Dimensions & Spacing** (`Dimensions.swift`): Strict spacing scale (`2pt`–`40pt`), corner radii (`18pt` squircles, `24pt` cards, `32pt` hero surfaces, `38pt` dock), and component sizes.
- **Shadows** (`Shadows.swift`): Physics-based elevation tokens (`cardElevation`, `navDockElevation`, `scanButtonGlow`, `squircleOnLime`).
- **Icons** (`Icons.swift`): Centralized SF Symbol and custom glyph registry mapping all destinations, actions, and status indicators.
- **Animations** (`Animations.swift`): Snappy spring dynamics (`tactilePress: 0.22s/0.65`, `tabTransition: 0.32s/0.72`, `sheetTransition: 0.38s/0.82`).

### 7.2 Reusable SwiftUI Component Suite
1. **`TransactionCard`**: Full-fidelity transaction row with squircle container, colored status glyph, TrxID, formatted amount, and tactile press response.
2. **`VisualAccountCard`**: Aspect-ratio standard (1.58:1) credit/envelope card with gradient fill, contactless icon, embossed cardholder, VISA mark, and masked account number.
3. **`SquircleButton`**: 1:1 squircle action trigger with spring feedback across dark, outlined, and lime accent variants.
4. **`LimeSurfaceCard`**: Downward-curved hero surface card with center notch accent.
5. **`MetricBadge`**: Compact pill badge for performance and delta metrics (`↑ 24%  Last week`).
6. **`ContactAvatarChip`**: Horizontal carousel contact chip with avatar circle, name, and masked phone/account.
7. **`TransferLimitSlider`**: Tactile transfer limit indicator with lime progress track.
8. **`DeltaModalSheet`**: Drag-dismissible modal sheet shell with rounded top corners and header navigation.
9. **`DeltaTabBar`**: Five-destination neon lime dock with elevated, circular central Scan button.


---

## 8. Credit & Debit Workflows & Financial Arithmetic Engine

### 8.1 Workflows
- **Credit (Money Received)**: Represents inflows, deposits, income, and refunds. Highlighted with neon lime (`#CCFF00`) and tagged with `arrow.down.left`.
- **Debit (Money Spent)**: Represents outflows, purchases, and expenses. Highlighted with salmon-red (`#FF5C5C`) and tagged with `arrow.up.right`.
- **Reusable Form (`TransactionFormSheet`)**:
  - Fields: Amount (`Decimal`), Person/Merchant/Source name, Account Envelope picker, Category selector, Date & Time pickers (defaulting to current local device time, fully editable), and optional purpose note.
  - Full validation via `FinancialCalculator.validate`.
  - Supports creating new records, editing existing records, and permanent deletion with confirmation.

### 8.2 Accurate Decimal Precision
- All currency operations utilize Swift `Decimal` arithmetic to guarantee zero floating-point rounding errors.
- Automatic account balance calculation: `currentBalance = initialBalance + credits - debits`.
- Duplicate prevention: Automatically blocks duplicate transactions occurring within 60 seconds with identical attributes.
- Comprehensive unit tests implemented in `Tests/DELTATests/FinancialCalculationsTests.swift`.


---

## 9. Complete Split Feature Architecture

### 9.1 Three Split Methods
1. **Equal Split**:
   - Minor currency remainder (cents) is distributed deterministically across participants.
   - For example: \$100.00 split 3 ways yields \$33.34, \$33.33, and \$33.33, guaranteeing that $\sum \text{shares} = \text{total}$ down to the exact cent without rounding drift.
2. **Custom Amount Split**:
   - Each participant is assigned a specific `Decimal` amount.
   - Strictly validated so $\sum \text{shares} = \text{total}$; otherwise, a validation error detailing the difference is surfaced.
3. **Percentage Split**:
   - Percentages are assigned to participants and strictly validated to equal 100%.
   - Shares are computed from percentages with minor currency remainders distributed deterministically.

### 9.2 Participants & Settlement Tracking
- Participants can be selected from **Favourite People** or added ad-hoc.
- The current user (**Hadi Aymen**) can be toggled as an included participant.
- Each participant tracks individual shares, settlement status (`isSettled`), and timestamp.
- Outstanding amounts owed to the payer are tracked separately from settled shares.

### 9.3 Ledger Link & Dashboard Invariants
- When the current user pays for the split, a **single linked original expense transaction** is created against the selected account card.
- **Zero Duplicate Outlay Policy**: The original expense is recorded once and never duplicated in dashboard monthly calculations.
- Marking an unsettled participant as settled records an incoming reimbursement credit, preserving accurate net outlay calculation.
- **Dedicated History Filter**: A "Splits" filter chip in the History view allows auditing all active and settled split records.
- Deleting a split removes the split record and cleans up the linked transaction consistently.


---

## 10. 'Other' (Unclassified) Transaction Workflow

### 10.1 Purpose & Classification
- The **Other** workflow is dedicated to financial records whose classification is currently unknown, pending, or unclear.
- Fields:
  - **Amount**: Required (`Decimal` precision).
  - **Person / Merchant**: Optional (defaults to "Unclassified Outlay" if omitted).
  - **Date & Time**: Defaulting to the device's current local date and time (fully editable).
  - **Description**: Optional text field for situational context (e.g. "Receipt in jacket pocket").
  - **Account**: Optional (defaults to selected active envelope or general).
  - **Note**: Optional short note.
- Saved into the `Other` category and assigned visual color `#E5C07B` (muted amber) with icon `questionmark.circle`.

### 10.2 In-Place Conversion (Zero Duplication Invariant)
- Records can be opened, edited, or converted later from History, Search, or Cards.
- **Conversion Targets**:
  1. **Convert to Debit**: Updates transaction type to `.debit`, assigns category, and updates monthly spent.
  2. **Convert to Credit**: Updates transaction type to `.credit`, assigns category, and recalculates balances.
  3. **Convert to Split**: Pre-populates a `SplitRecord` linked directly to the original record (`linkedTransactionID`).
- **Zero Duplicate Policy**: Conversion strictly performs an in-place update on the existing record rather than generating a duplicate.
- Persisted locally to disk and indexed in global search results across title, description, note, and account.
