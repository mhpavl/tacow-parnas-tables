//
//  VendingMachine.swift
//
//  Reference implementation for the "Parnas Table → State Machine → App" demo.
//  Every `case` in `transition(from:on:stock:)` maps to exactly ONE row of the
//  Parnas table in ../VendingMachine-Spec.md. Swift's exhaustive switch enforces
//  completeness; the guards keep the Collecting/selectProduct rows disjoint.
//

import Foundation

// MARK: - Domain

/// Accepted coins, in cents.
enum Coin: Int, CaseIterable, CustomStringConvertible {
    case nickel = 5
    case dime = 10
    case quarter = 25
    case loonie = 100
    case toonie = 200

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

/// A product, its price in cents, and whatever the machine sells.
struct Product: Identifiable, Hashable, CustomStringConvertible {
    let id: String
    let name: String
    let price: Int   // cents

    var description: String { "\(name) (\(price.asDollars))" }
}

// MARK: - States, Events, Outputs

enum VendingState: Equatable, CustomStringConvertible {
    case idle
    case collecting(balance: Int)   // cents accumulated
    case dispensing(Product)

    var description: String {
        switch self {
        case .idle: return "Idle"
        case .collecting(let balance): return "Collecting(\(balance.asDollars))"
        case .dispensing(let product): return "Dispensing(\(product.name))"
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
enum StockStatus {
    case inStock
    case outOfStock
}

enum Output: Equatable, CustomStringConvertible {
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

struct TransitionResult: Equatable {
    let newState: VendingState
    let outputs: [Output]
}

// MARK: - The transition function (one case == one table row)

/// Pure function. `stock` is the resolved inventory guard for the selected product.
func transition(
    from state: VendingState,
    on event: VendingEvent,
    stock: StockStatus = .inStock
) -> TransitionResult {
    switch (state, event) {

    // Row 1: Idle + insertCoin → Collecting
    case (.idle, .insertCoin(let coin)):
        return TransitionResult(
            newState: .collecting(balance: coin.rawValue),
            outputs: [.showBalance(coin.rawValue)]
        )

    // Row 2: Idle + selectProduct → Idle (no money in)
    case (.idle, .selectProduct):
        return TransitionResult(newState: .idle, outputs: [.showInsufficientFunds])

    // Row 3: Idle + cancel → Idle (nothing to refund)
    case (.idle, .cancel):
        return TransitionResult(newState: .idle, outputs: [])

    // Row 4: Collecting + insertCoin → Collecting (accumulate)
    case (.collecting(let balance), .insertCoin(let coin)):
        let newBalance = balance + coin.rawValue
        return TransitionResult(
            newState: .collecting(balance: newBalance),
            outputs: [.showBalance(newBalance)]
        )

    // Rows 5/6/7: Collecting + selectProduct — split by guards
    case (.collecting(let balance), .selectProduct(let product)):
        switch stock {
        case .outOfStock:                                   // Row 7
            return TransitionResult(
                newState: .collecting(balance: balance),
                outputs: [.showOutOfStock]
            )
        case .inStock where balance >= product.price:       // Row 5
            return TransitionResult(
                newState: .dispensing(product),
                outputs: [.dispense(product), .makeChange(balance - product.price)]
            )
        case .inStock:                                      // Row 6 (balance < price)
            return TransitionResult(
                newState: .collecting(balance: balance),
                outputs: [.showInsufficientFunds]
            )
        }

    // Row 8: Collecting + cancel → Idle (full refund)
    case (.collecting(let balance), .cancel):
        return TransitionResult(newState: .idle, outputs: [.refund(balance)])

    // Row 9: Dispensing + dispenseComplete → Idle
    case (.dispensing, .dispenseComplete):
        return TransitionResult(newState: .idle, outputs: [])

    // Explicitly ignored (the blank cells in the completeness matrix):
    // while dispensing, ignore coins/selections/cancel; dispenseComplete is a
    // no-op outside Dispensing.
    case (.dispensing, .insertCoin),
         (.dispensing, .selectProduct),
         (.dispensing, .cancel),
         (.idle, .dispenseComplete),
         (.collecting, .dispenseComplete):
        return TransitionResult(newState: state, outputs: [])
    }
}

// MARK: - Helpers

extension Int {
    /// Cents → "$1.25"
    var asDollars: String {
        String(format: "$%.2f", Double(self) / 100.0)
    }
}
