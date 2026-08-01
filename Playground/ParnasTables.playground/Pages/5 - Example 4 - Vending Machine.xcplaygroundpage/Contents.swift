//: [Previous: Order Processing](@previous)
//:
//: # Example 4: Vending Machine State Machine
//:
//: ## The Demo Machine for "Tables → State Machines → Apps"
//: A small **Mealy Machine** (outputs depend on current state *and* input) that we
//: co-design with an AI assistant and then let Xcode 27's agent turn into a SwiftUI
//: app. It's deliberately tiny — 3 states, 4 events — but its **guard conditions**
//: ("enough credit?" and "in stock?") are exactly the three-dimensional
//: *State × Event × Guard* input that Parnas tables are built for.
//:
//: ```
//: ┌────────────────┬───────────────────┬─────────────────────┬────────────────┬──────────────────────┐
//: │ Current State  │ Event             │ Guard               │ New State      │ Outputs              │
//: ├────────────────┼───────────────────┼─────────────────────┼────────────────┼──────────────────────┤
//: │ Idle           │ insertCoin(c)     │ —                   │ Collecting(c)  │ showBalance          │
//: │ Idle           │ selectProduct     │ —                   │ Idle           │ insufficientFunds    │
//: │ Idle           │ cancel            │ —                   │ Idle           │ —                    │
//: │ Collecting(b)  │ insertCoin(c)     │ —                   │ Collecting(b+c)│ showBalance          │
//: │ Collecting(b)  │ selectProduct(p)  │ inStock ∧ b ≥ price │ Dispensing     │ dispense, makeChange │
//: │ Collecting(b)  │ selectProduct(p)  │ inStock ∧ b < price │ Collecting(b)  │ insufficientFunds    │
//: │ Collecting(b)  │ selectProduct(p)  │ ¬inStock            │ Collecting(b)  │ outOfStock           │
//: │ Collecting(b)  │ cancel            │ —                   │ Idle           │ refund(b)            │
//: │ Dispensing     │ dispenseComplete  │ —                   │ Idle           │ —                    │
//: └────────────────┴───────────────────┴─────────────────────┴────────────────┴──────────────────────┘
//: where final/terminal handling: while Dispensing, coins/selections/cancel are ignored.
//: ```
//:
//: The three rows that share `(Collecting, selectProduct)` are kept **disjoint** by
//: their guards — `inStock ∧ b ≥ price`, `inStock ∧ b < price`, and `¬inStock`
//: partition the space with no gap and no overlap.
//:

import Foundation

print("=" + String(repeating: "=", count: 70))
print("EXAMPLE 4: VENDING MACHINE STATE MACHINE")
print("=" + String(repeating: "=", count: 70) + "\n")

// MARK: - Domain

/// Accepted coins, in cents.
enum Coin: Int, CaseIterable, CustomStringConvertible {
    case nickel = 5, dime = 10, quarter = 25, loonie = 100, toonie = 200
    var description: String {
        switch self {
        case .nickel: return "5¢"
        case .dime: return "10¢"
        case .quarter: return "25¢"
        case .loonie: return "$1"
        case .toonie: return "$2"
        }
    }
}

struct Product: CustomStringConvertible {
    let name: String
    let price: Int   // cents
    var description: String { "\(name) (\(price.asDollars))" }
}

enum VendingState: CustomStringConvertible {
    case idle
    case collecting(balance: Int)
    case dispensing(Product)
    var description: String {
        switch self {
        case .idle: return "Idle"
        case .collecting(let b): return "Collecting(\(b.asDollars))"
        case .dispensing(let p): return "Dispensing(\(p.name))"
        }
    }
}

enum VendingEvent {
    case insertCoin(Coin)
    case selectProduct(Product)
    case cancel
    case dispenseComplete
}

/// The inventory guard, resolved by the caller before the transition.
enum StockStatus { case inStock, outOfStock }

enum Output: CustomStringConvertible {
    case showBalance(Int)
    case showInsufficientFunds
    case showOutOfStock
    case dispense(Product)
    case makeChange(Int)
    case refund(Int)
    var description: String {
        switch self {
        case .showBalance(let b): return "showBalance(\(b.asDollars))"
        case .showInsufficientFunds: return "showInsufficientFunds()"
        case .showOutOfStock: return "showOutOfStock()"
        case .dispense(let p): return "dispense(\(p.name))"
        case .makeChange(let c): return "makeChange(\(c.asDollars))"
        case .refund(let r): return "refund(\(r.asDollars))"
        }
    }
}

struct TransitionResult {
    let newState: VendingState
    let outputs: [Output]
}

// MARK: - The transition function (one case == one table row)

func transition(
    from state: VendingState,
    on event: VendingEvent,
    stock: StockStatus = .inStock
) -> TransitionResult {
    switch (state, event) {

    // Row 1: Idle + insertCoin → Collecting
    case (.idle, .insertCoin(let coin)):
        return TransitionResult(newState: .collecting(balance: coin.rawValue),
                                outputs: [.showBalance(coin.rawValue)])

    // Row 2: Idle + selectProduct → Idle (no money in)
    case (.idle, .selectProduct):
        return TransitionResult(newState: .idle, outputs: [.showInsufficientFunds])

    // Row 3: Idle + cancel → Idle (nothing to refund)
    case (.idle, .cancel):
        return TransitionResult(newState: .idle, outputs: [])

    // Row 4: Collecting + insertCoin → Collecting (accumulate)
    case (.collecting(let balance), .insertCoin(let coin)):
        let newBalance = balance + coin.rawValue
        return TransitionResult(newState: .collecting(balance: newBalance),
                                outputs: [.showBalance(newBalance)])

    // Rows 5/6/7: Collecting + selectProduct — split by guards
    case (.collecting(let balance), .selectProduct(let product)):
        switch stock {
        case .outOfStock:                                   // Row 7
            return TransitionResult(newState: .collecting(balance: balance),
                                    outputs: [.showOutOfStock])
        case .inStock where balance >= product.price:       // Row 5
            return TransitionResult(newState: .dispensing(product),
                                    outputs: [.dispense(product), .makeChange(balance - product.price)])
        case .inStock:                                      // Row 6 (balance < price)
            return TransitionResult(newState: .collecting(balance: balance),
                                    outputs: [.showInsufficientFunds])
        }

    // Row 8: Collecting + cancel → Idle (full refund)
    case (.collecting(let balance), .cancel):
        return TransitionResult(newState: .idle, outputs: [.refund(balance)])

    // Row 9: Dispensing + dispenseComplete → Idle
    case (.dispensing, .dispenseComplete):
        return TransitionResult(newState: .idle, outputs: [])

    // Explicitly ignored (the blank cells in the completeness matrix):
    // while Dispensing, ignore coins/selections/cancel; dispenseComplete is a
    // no-op outside Dispensing.
    case (.dispensing, .insertCoin),
         (.dispensing, .selectProduct),
         (.dispensing, .cancel),
         (.idle, .dispenseComplete),
         (.collecting, .dispenseComplete):
        return TransitionResult(newState: state, outputs: [])
    }
}

//: ## Simulating a Purchase

let cola = Product(name: "Cola", price: 150)
let chips = Product(name: "Chips", price: 200)   // pretend this one is sold out

print("Scenario: buy a Cola, then try a sold-out Chips\n")

var currentState = VendingState.idle
print("Initial State: \(currentState)\n")

let script: [(VendingEvent, StockStatus, String)] = [
    (.insertCoin(.loonie),      .inStock,    "Insert $1"),
    (.insertCoin(.quarter),     .inStock,    "Insert 25¢"),
    (.selectProduct(cola),      .inStock,    "Select Cola ($1.50) — short 25¢"),
    (.insertCoin(.quarter),     .inStock,    "Insert 25¢"),
    (.selectProduct(cola),      .inStock,    "Select Cola ($1.50) — now covered"),
    (.dispenseComplete,         .inStock,    "Dispense finishes"),
    (.insertCoin(.toonie),      .inStock,    "Insert $2"),
    (.selectProduct(chips),     .outOfStock, "Select Chips — sold out"),
    (.cancel,                   .inStock,    "Cancel — refund"),
]

for (event, stock, description) in script {
    let result = transition(from: currentState, on: event, stock: stock)
    print("• \(description)")
    print("    \(currentState) → \(result.newState)")
    if !result.outputs.isEmpty {
        print("    Outputs: \(result.outputs.map(\.description).joined(separator: ", "))")
    }
    print()
    currentState = result.newState
}

//: ## Key Takeaways
//:
//: * **Guards split one State+Event into three disjoint rows** — the property a
//:   flowchart hides and a table makes provable.
//: * **No `default` case:** every table row is an explicit `case`. Comment one out
//:   and Swift refuses to compile — the compiler now enforces the table.
//: * **Explicitly-ignored transitions** (the blank cells) are decisions, not
//:   oversights: while `Dispensing`, coins and selections are intentionally no-ops.
//:
//: ## From Table to App
//:
//: This same `transition(from:on:stock:)` is the whole brain of a SwiftUI app: the
//: view sends *events*, and the only thing that mutates state is this function.
//: See `Demo/` in the repo for the reference SwiftUI screen, the Xcode 27 demo
//: script, and the slides.
//:
//: ---
//:
//: [Next: Summary](@next)

extension Int {
    /// Cents → "$1.25"
    var asDollars: String { String(format: "$%.2f", Double(self) / 100.0) }
}
