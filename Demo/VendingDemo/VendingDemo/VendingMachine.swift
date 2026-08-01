//
//  VendingMachine.swift
//  VendingDemo
//
//  A direct Swift 6 translation of the vending-machine Parnas table
//  (a Mealy machine). The `transition` switch has exactly one case per
//  table row, in table order. Completeness across all 12 (State × Event)
//  cells is enforced by Swift's exhaustive switch — there is no `default`.
//

import Foundation

// MARK: - Domain types

/// A product the machine can vend. Identity only — its price and availability
/// are supplied at decision time via `StockStatus`, so the price never has to
/// be kept in sync inside the model.
struct Product: Equatable, Hashable, Sendable {
    let name: String
}

/// The machine's states.
///
/// The core invariant `balance > 0 ⟺ .collecting` is encoded in the *types*:
/// only `.collecting` carries a balance, so a non-zero balance literally
/// cannot be represented in `.idle` or `.dispensing`.
enum State: Equatable, Sendable {
    case idle
    case collecting(balance: Int)
    case dispensing(product: Product)
}

/// The input alphabet. `dispenseComplete` is the hardware signalling that the
/// motor has finished (drives rows 4, 10, 14).
enum Event: Equatable, Sendable {
    case insertCoin(Int)
    case selectProduct(Product)
    case cancel
    case dispenseComplete
}

/// The guard input for a `selectProduct` event. Consulted only by rows 6–8;
/// every other row treats it as "don't care" (— in the table) via `_`.
enum StockStatus: Equatable, Sendable {
    case soldOut
    case inStock(price: Int)
}

/// The Outputs column of the table.
enum Output: Equatable, Sendable {
    case none
    case insertCoinsFirst
    case insufficientFunds(shortfall: Int)
    case soldOut
    case dispense(Product, change: Int)   // begins the vend + returns change
    case refund(Int)
    case vendComplete                     // "Enjoy"
}

/// The result of one transition: the next state and the emitted output.
struct TransitionResult: Equatable, Sendable {
    let newState: State
    let output: Output
}

// MARK: - Pricing policy

/// The 5% "convenience fee" applied to every purchase.
let convenienceFeeRate = 0.05

/// The amount actually required to vend `price`, including the convenience fee,
/// rounded to the nearest cent. Rows 6 and 7 both call this so the affordability
/// guard and the returned change can never disagree. Change the rounding rule
/// here (e.g. `.up` to never undercharge the fee) and both rows follow.
func requiredTotal(forPrice price: Int) -> Int {
    Int((Double(price) * (1 + convenienceFeeRate)).rounded())
}

// MARK: - Transition function

/// Pure transition function for the vending-machine Mealy table.
///
/// One `case` per table row, in table order. `stock` is meaningful only for
/// `selectProduct` (rows 6–8); all other rows ignore it with `_`, matching the
/// table's `—` guard. Exhaustiveness of the `(State, Event, StockStatus)` tuple
/// guarantees all 12 cells are covered without a `default`.
func transition(from state: State, on event: Event, stock: StockStatus) -> TransitionResult {
    switch (state, event, stock) {

    // Row 1 — Idle / InsertCoin(c)  →  Collecting; balance ← c   (assumes c > 0)
    case (.idle, .insertCoin(let c), _):
        return TransitionResult(newState: .collecting(balance: c), output: .none)

    // Row 2 — Idle / SelectProduct  →  Idle; "Insert coins first"  (no-op; stock not checked)
    case (.idle, .selectProduct(_), _):
        return TransitionResult(newState: .idle, output: .insertCoinsFirst)

    // Row 3 — Idle / Cancel  →  Idle; —   (no-op; idempotent)
    case (.idle, .cancel, _):
        return TransitionResult(newState: .idle, output: .none)

    // Row 4 — Idle / DispenseComplete  →  Idle; —   (impossible; defensive no-op)
    case (.idle, .dispenseComplete, _):
        return TransitionResult(newState: .idle, output: .none)

    // Row 5 — Collecting / InsertCoin(c)  →  Collecting; balance ← balance + c
    case (.collecting(let balance), .insertCoin(let c), _):
        return TransitionResult(newState: .collecting(balance: balance + c), output: .none)

    // Row 6 — Collecting / SelectProduct(p)  [inStock ∧ balance ≥ total(p)]
    //         →  Dispensing; Dispense(p); ReturnChange(balance − total(p)); balance ← 0
    //         total(p) = price + 5% convenience fee (see requiredTotal).
    case (.collecting(let balance), .selectProduct(let p), .inStock(let price))
        where balance >= requiredTotal(forPrice: price):
        return TransitionResult(newState: .dispensing(product: p),
                                output: .dispense(p, change: balance - requiredTotal(forPrice: price)))

    // Row 7 — Collecting / SelectProduct(p)  [inStock ∧ balance < total(p)]
    //         →  Collecting; "Insufficient funds" (shortfall measured against total)
    case (.collecting(let balance), .selectProduct(_), .inStock(let price)):
        return TransitionResult(newState: .collecting(balance: balance),
                                output: .insufficientFunds(shortfall: requiredTotal(forPrice: price) - balance))

    // Row 8 — Collecting / SelectProduct(p)  [¬inStock]  →  Collecting; "Sold out"
    case (.collecting(let balance), .selectProduct(_), .soldOut):
        return TransitionResult(newState: .collecting(balance: balance), output: .soldOut)

    // Row 9 — Collecting / Cancel  →  Idle; Refund(balance); balance ← 0
    case (.collecting(let balance), .cancel, _):
        return TransitionResult(newState: .idle, output: .refund(balance))

    // Row 10 — Collecting / DispenseComplete  →  Collecting; —   (impossible; defensive no-op)
    case (.collecting(let balance), .dispenseComplete, _):
        return TransitionResult(newState: .collecting(balance: balance), output: .none)

    // Row 11 — Dispensing / InsertCoin  →  Dispensing; —   (no-op; coin slot locked)
    case (.dispensing(let p), .insertCoin(_), _):
        return TransitionResult(newState: .dispensing(product: p), output: .none)

    // Row 12 — Dispensing / SelectProduct  →  Dispensing; —   (no-op; input ignored)
    case (.dispensing(let p), .selectProduct(_), _):
        return TransitionResult(newState: .dispensing(product: p), output: .none)

    // Row 13 — Dispensing / Cancel  →  Dispensing; —   (no-op; cannot cancel mid-vend)
    case (.dispensing(let p), .cancel, _):
        return TransitionResult(newState: .dispensing(product: p), output: .none)

    // Row 14 — Dispensing / DispenseComplete  →  Idle; "Enjoy"
    case (.dispensing(_), .dispenseComplete, _):
        return TransitionResult(newState: .idle, output: .vendComplete)
    }
}
