# Vending Machine — State Machine Spec

This is the artifact at the center of the demo. It starts as a **plain-English
brief** (what you tell the assistant), becomes a **Parnas table** (what you and the
assistant co-build and review), and only *then* becomes code.

---

## 1. The plain-English brief

> A vending machine sits **idle** until someone inserts coins. As coins go in it
> **collects** a running balance and shows it. The customer can **select a product**:
> if that product is in stock and the balance covers its price, the machine
> **dispenses** it and returns any change; if the balance is short, it says so and
> keeps the money in; if the product is sold out, it says so. At any time the
> customer can **cancel** and get a full refund. After dispensing, it returns to
> idle.

That paragraph is genuinely all a domain expert needs to give. The work of the
segment is turning it into something *complete and disjoint* — which is what the
assistant helps with.

---

## 2. The Parnas table (the reviewed spec)

A **Mealy machine**: outputs depend on both current state and input. Three-dimensional
input — **State × Event × Guard** — is what a plain flowchart hides and a table makes
obvious.

| # | Current State  | Event              | Guard                          | New State      | Outputs                          |
|---|----------------|--------------------|--------------------------------|----------------|----------------------------------|
| 1 | Idle           | insertCoin(c)      | —                              | Collecting(c)  | showBalance                      |
| 2 | Idle           | selectProduct(p)   | —                              | Idle           | showInsufficientFunds            |
| 3 | Idle           | cancel             | —                              | Idle           | —                                |
| 4 | Collecting(b)  | insertCoin(c)      | —                              | Collecting(b+c)| showBalance                      |
| 5 | Collecting(b)  | selectProduct(p)   | inStock ∧ b ≥ price            | Dispensing     | dispense(p), makeChange(b−price) |
| 6 | Collecting(b)  | selectProduct(p)   | inStock ∧ b < price            | Collecting(b)  | showInsufficientFunds            |
| 7 | Collecting(b)  | selectProduct(p)   | ¬inStock                       | Collecting(b)  | showOutOfStock                   |
| 8 | Collecting(b)  | cancel             | —                              | Idle           | refund(b)                        |
| 9 | Dispensing     | dispenseComplete   | —                              | Idle           | —                                |

**Domain of the machine**
- **States:** `Idle`, `Collecting(balance)`, `Dispensing`
- **Events:** `insertCoin(Coin)`, `selectProduct(Product)`, `cancel`, `dispenseComplete`
- **Guards:** `inStock`, and `balance ≥ price` vs `balance < price`
- **Outputs:** `showBalance`, `showInsufficientFunds`, `showOutOfStock`,
  `dispense(Product)`, `makeChange(amount)`, `refund(amount)`

---

## 3. Completeness & disjointness — the part the assistant earns its keep on

This is the moment to slow down on stage. Ask the assistant:
*"Is this table complete and disjoint? What's missing?"*

**Completeness** — every (State × Event) pair must be covered:

|                    | insertCoin | selectProduct | cancel | dispenseComplete |
|--------------------|:----------:|:-------------:|:------:|:----------------:|
| **Idle**           | row 1      | row 2         | row 3  | *n/a → no-op*    |
| **Collecting**     | row 4      | rows 5/6/7    | row 8  | *n/a → no-op*    |
| **Dispensing**     | *ignore*   | *ignore*      | *ignore* | row 9          |

The blank/*ignore* cells are a decision, not an oversight — while dispensing, the
machine ignores coins and selections. Naming those explicitly is the whole point:
Swift's exhaustive `switch` will *force* you to say what happens, so "we forgot"
becomes impossible.

**Disjointness** — rows 5/6/7 share (Collecting, selectProduct); they're kept
mutually exclusive by their guards:
- `inStock ∧ b ≥ price` (5)
- `inStock ∧ b < price` (6)
- `¬inStock` (7)

These three partition the guard space with no overlap and no gap. That's the
property a flowchart can't prove and a table can.

---

## 4. Why this beats an if/else nest

The tempting implementation is nested `if`s inside a `switch` on state. That hides
the guard split (rows 5–7) inside imperative flow, where a reviewer can't see
whether the three cases are exhaustive and non-overlapping. The table makes the
partition a *thing you can point at* — and the generated Swift maps one row → one
`case`, so the code and the reviewable artifact stay in lockstep.

See [`Reference/VendingMachine.swift`](Reference/VendingMachine.swift) for the
one-row-per-case implementation.

---

## 5. What the shipped app actually implements

The table above is the **starting** artifact — the 9-row version you and the assistant
produce in Beats 1–2. The app checked in at
[`../VendingDemo/VendingMachine.swift`](../VendingDemo/VendingMachine.swift) is the
version that survived the rest of the demo, and it differs in two ways worth knowing
before you read it:

1. **14 rows, not 9.** Taking §3's completeness argument literally, every one of the
   12 (State × Event) cells gets its own labelled row — including the "ignore it"
   cells — and the (Collecting, selectProduct) guard split adds two more. Nothing is
   left to a blank cell or a `default`; the `switch` is over the whole
   `(State, Event, StockStatus)` tuple.
2. **A 5% convenience fee** (Beat 5 of [`Xcode27-Script.md`](Xcode27-Script.md)). The
   affordability guard becomes `balance ≥ total(p)` and change is
   `balance − total(p)`, where `total(p) = round(price × 1.05)`. Both rows call one
   `requiredTotal(forPrice:)`, so the guard and the change can never disagree.

Row map for the shipped version:

| # | State | Event | Guard | New State | Output |
|---|-------|-------|-------|-----------|--------|
| 1 | Idle | insertCoin(c) | — | Collecting(c) | — |
| 2 | Idle | selectProduct | — | Idle | insertCoinsFirst |
| 3 | Idle | cancel | — | Idle | — |
| 4 | Idle | dispenseComplete | — | Idle | — *(defensive no-op)* |
| 5 | Collecting(b) | insertCoin(c) | — | Collecting(b+c) | — |
| 6 | Collecting(b) | selectProduct(p) | inStock ∧ b ≥ total(p) | Dispensing(p) | dispense(p, change: b − total(p)) |
| 7 | Collecting(b) | selectProduct(p) | inStock ∧ b < total(p) | Collecting(b) | insufficientFunds(shortfall) |
| 8 | Collecting(b) | selectProduct(p) | ¬inStock | Collecting(b) | soldOut |
| 9 | Collecting(b) | cancel | — | Idle | refund(b) |
| 10 | Collecting(b) | dispenseComplete | — | Collecting(b) | — *(defensive no-op)* |
| 11 | Dispensing(p) | insertCoin | — | Dispensing(p) | — *(coin slot locked)* |
| 12 | Dispensing(p) | selectProduct | — | Dispensing(p) | — *(input ignored)* |
| 13 | Dispensing(p) | cancel | — | Dispensing(p) | — *(cannot cancel mid-vend)* |
| 14 | Dispensing(p) | dispenseComplete | — | Idle | vendComplete |

Balance display moved out of the Outputs column: the balance is *already* in the state
(`collecting(balance:)`), so the view derives it rather than the machine emitting a
`showBalance`. Stock quantity is world state, not machine state — it lives in
[`../VendingDemo/VendingViewModel.swift`](../VendingDemo/VendingViewModel.swift), which
resolves the `StockStatus` guard before each transition.
