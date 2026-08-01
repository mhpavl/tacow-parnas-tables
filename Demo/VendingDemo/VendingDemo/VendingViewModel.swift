//
//  VendingViewModel.swift
//  VendingDemo
//
//  The view model owns the *world* (inventory) and the machine's current
//  `State`. Its single rule: the only place `state` is ever reassigned is in
//  `send(_:)`, and that value always comes straight out of `transition(...)`.
//  The view calls `send(_:)` with events and never touches `state` directly.
//

import SwiftUI

@MainActor
@Observable
final class VendingViewModel {

    // MARK: World

    /// One slot in the machine. `quantity` is the world state the guard reads;
    /// the model's `State` never stores it.
    struct Slot: Identifiable {
        let id = UUID()
        let product: Product
        let price: Int          // cents
        var quantity: Int
        var isSoldOut: Bool { quantity <= 0 }
    }

    /// The coin denominations, in cents.
    let coins: [Int] = [5, 10, 25, 100, 200]

    private(set) var inventory: [Slot] = [
        Slot(product: Product(name: "Water"),  price: 75,  quantity: 3),
        Slot(product: Product(name: "Cola"),   price: 125, quantity: 2),
        Slot(product: Product(name: "Chips"),  price: 150, quantity: 4),
        Slot(product: Product(name: "Candy"),  price: 100, quantity: 1),
        Slot(product: Product(name: "Coffee"), price: 200, quantity: 2),
        Slot(product: Product(name: "Juice"),  price: 125, quantity: 0), // starts sold out
    ]

    // MARK: Machine state (only mutated in `send`)

    private(set) var state: State = .idle
    private(set) var message: String = "Insert coins to begin"

    /// True while the motor is running — the view uses this to lock input,
    /// mirroring the machine's rows 11–13 (which would ignore events anyway).
    var isDispensing: Bool {
        if case .dispensing = state { return true }
        return false
    }

    /// Running balance for display; non-zero only in `.collecting`.
    var balance: Int {
        if case .collecting(let b) = state { return b }
        return 0
    }

    // MARK: Event intake — the ONLY state mutation path

    func send(_ event: Event) {
        let result = transition(from: state, on: event, stock: stockStatus(for: event))
        state = result.newState
        apply(result.output)
    }

    // MARK: Guard resolution

    /// Resolves the `StockStatus` guard for the selected product. For every
    /// non-`selectProduct` event this is "don't care" — the value is ignored
    /// by `transition`, so a placeholder is fine.
    private func stockStatus(for event: Event) -> StockStatus {
        guard case .selectProduct(let product) = event,
              let slot = inventory.first(where: { $0.product == product }),
              !slot.isSoldOut
        else { return .soldOut }
        return .inStock(price: slot.price)
    }

    // MARK: Output handling (message + world side effects)

    private func apply(_ output: Output) {
        switch output {
        case .none:
            // No message of its own — reflect the state we landed in.
            switch state {
            case .idle:              message = "Insert coins to begin"
            case .collecting:        message = "Balance: \(Self.money(balance))"
            case .dispensing:        message = "Dispensing…"
            }

        case .insertCoinsFirst:
            message = "Insert coins first"

        case .insufficientFunds(let shortfall):
            message = "Insufficient funds — add \(Self.money(shortfall))"

        case .soldOut:
            message = "Sold out — choose another"

        case .dispense(let product, let change):
            decrementStock(of: product)
            message = change > 0
                ? "Dispensing \(product.name) — change \(Self.money(change))"
                : "Dispensing \(product.name)"
            scheduleDispenseCompletion()

        case .refund(let amount):
            message = "Refunded \(Self.money(amount))"

        case .vendComplete:
            message = "Enjoy!"
        }
    }

    /// Decrementing stock is a change to the *world*, not the machine state,
    /// so it lives here rather than in `transition`.
    private func decrementStock(of product: Product) {
        guard let index = inventory.firstIndex(where: { $0.product == product }) else { return }
        inventory[index].quantity -= 1
    }

    /// The hardware's `dispenseComplete` signal: after ~1s the motor finishes
    /// and we feed the event back through the one mutation path.
    private func scheduleDispenseCompletion() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            self.send(.dispenseComplete)
        }
    }

    // MARK: Formatting

    static func money(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents) / 100)
    }
}
