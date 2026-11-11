# PROJECT_RULES.md — DELTA Personal Expense Tracker

> **Mandatory Design Authority**: The reference image (`reference/reference-ui.jpg`, MONO UI Reference) and approved Figma design define the strict, non-negotiable visual and architectural benchmark for **DELTA**.
> Any previous white/ivory visual direction is completely **superseded and prohibited**. No visual deviations are permitted without explicit written approval.

---

## 1. Application Identity & Core Purpose

- **Application Name**: **DELTA**
- **Domain**: Personal Expense Tracker & Financial Organization Tool.
- **Strict Functional Boundary**:
  - DELTA is **NOT** a bank, payment processor, or money transfer application.
  - **Forbidden Functionality**: Never implement real-world banking transfers, payment gateway initiations, wire/ACH routing, credit pulls, or live card payment operations.
  - **Account Representations**: All "Cards" displayed in the interface are **dummy visual cards** representing user-defined expense buckets, personal budget accounts, or cash/savings categories (e.g., "Daily Discretionary", "Groceries & Dining", "Travel & Leisure", "Household Reserve").
  - **Action Equivalents for Expense Tracking**:
    - *Send / - Amount* $\rightarrow$ Log expense / outlay.
    - *Receive / + Amount* $\rightarrow$ Log income / refund / deposit.
    - *Scan* $\rightarrow$ Scan physical receipt / expense QR for local tracking.
    - *Cards* $\rightarrow$ Switch expense accounts / budget category limits.
    - *History* $\rightarrow$ View expense ledger and categorization.
    - *Search* $\rightarrow$ Filter and query past expenses.

---

## 2. Permanent Visual & Design Authority Mandates

All developers, designers, and agents working on DELTA must adhere strictly to these permanent standards:

### 2.1 Color Foundation
- **Deep Black & Olive Backgrounds**: Deep obsidian canvas (`#080C08`, `#0B100A`) complemented by dark forest-olive containers (`#121A0F`, `#162013`).
- **Electric Neon Lime & Chartreuse**: Vibrant electric lime (`#CCFF00`, `#C4F822`) used for primary hero surfaces, accent badges, and the primary navigation dock.
- **Chartreuse & Olive Card Gradients**: Stacked cards feature linear gradients transitioning from vibrant lime/chartreuse (`#7DA815`) to deep organic olive (`#39500A` / `#223007`).
- **Superseded Style**: Pure white, ivory, light-gray, or pastel themes are explicitly forbidden.

### 2.2 Surface Geometry & Density
- **Rounded Lime Surfaces**: Large hero containers feature deep, fluid corners (`border-radius: 28px` to `36px`) with downward-pointing pill/notch accents.
- **Dark Rounded-Square Action Buttons**: Action buttons across surfaces are squircle/rounded-square shapes (`border-radius: 16px` to `20px`) in obsidian-olive (`#11160E` / `#161F13`) featuring crisp icon glyphs.
- **High-Density Proportions**: Exact visual density matching the mobile reference viewport (approx. 390px–430px base width, tight spacing, compact yet readable data chips).

### 2.3 Stacked Card Presentation
- Visual card carousel/deck displaying layered dummy account cards.
- Background card peeking behind the active card with organic depth, subtle border highlight, and glossy card metadata layout (holder name, card brand watermark, masked number, expiry).

### 2.4 Five-Tab Navigation Composition
The bottom navigation bar must strictly maintain the 5-tab layout rendered on a neon lime dock:
1. **Home** (Dashboard overview, balance, recent transactions)
2. **Cards** (Account & category card deck, quick card settings)
3. **Scan** (Elevated, center circular trigger with dark embossed glyph & radial focus)
4. **History** (Full transaction ledger, filterable expense log)
5. **Search** (Global expense search, merchant & category filter)

---

## 3. Strict Development Guardrails

1. **Do Not Implement Features Yet**: Current phase is establishing the design system, visual authority, project rules, and visual comparison checklist. No feature code is to be implemented until explicitly requested.
2. **Zero Unapproved Design Changes**: Spacing, color codes, border radii, iconography style, and navigation placement must match the reference authority. Modifying any token requires explicit user confirmation.
3. **Data Privacy & Security**: All tracked expense data remains local/user-controlled. Dummy card numbers must always remain visual mocks (e.g., `7820 5500 0835 3501`) and never bind to real PANs.
4. **Typography Strictness**: High-contrast grotesque/geometric sans-serif typography. Currency units, decimal places, and transaction identifiers must strictly mirror the visual hierarchy of the reference image.

