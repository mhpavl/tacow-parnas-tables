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
