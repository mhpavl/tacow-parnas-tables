//
//  ContentView.swift
//
//  Reference SwiftUI screen that drives the vending-machine state machine.
//  The UI is a thin shell: every button sends an *event*, and the ONLY thing that
//  mutates state is `transition(from:on:stock:)`. The view renders whatever state
//  and outputs come back. This is the app the Xcode 27 agent should generate from
//  the reviewed Parnas table — kept here as a stage-safe backup.
//

import SwiftUI

// MARK: - View model (owns the machine)

@MainActor
@Observable
final class VendingMachineModel {
    private(set) var state: VendingState = .idle
    private(set) var message: String = "Insert coins to begin"
    private(set) var lastDispensed: Product?

    /// Demo inventory. Flip a `stock` to `.outOfStock` live to exercise row 7.
    let inventory: [Product] = [
        Product(id: "A1", name: "Cola",   price: 150),
        Product(id: "A2", name: "Water",  price: 125),
        Product(id: "A3", name: "Chips",  price: 200),
        Product(id: "A4", name: "Gum",    price: 75),
    ]
    var stock: [String: StockStatus] = ["A3": .outOfStock]   // Chips sold out

    var balance: Int {
        if case .collecting(let b) = state { return b }
        return 0
    }

    func send(_ event: VendingEvent, stock stockStatus: StockStatus = .inStock) {
        let result = transition(from: state, on: event, stock: stockStatus)
        state = result.newState
        apply(result.outputs)

        // Dispensing is transient: auto-fire completion after a beat.
        if case .dispensing = state {
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                send(.dispenseComplete)
            }
        }
    }

    func select(_ product: Product) {
        send(.selectProduct(product), stock: stock[product.id] ?? .inStock)
    }

    private func apply(_ outputs: [Output]) {
        for output in outputs {
            switch output {
            case .showBalance(let b):        message = "Balance: \(b.asDollars)"
            case .showInsufficientFunds:     message = "Insufficient funds"
            case .showOutOfStock:            message = "Sold out"
            case .dispense(let p):           message = "Dispensing \(p.name)…"; lastDispensed = p
            case .makeChange(let c) where c > 0: message = "Take your change: \(c.asDollars)"
            case .makeChange:                break
            case .refund(let r):             message = "Refunded \(r.asDollars)"
            }
        }
    }
}

// MARK: - View

struct ContentView: View {
    @State private var model = VendingMachineModel()

    private let coins: [Coin] = Coin.allCases

    var body: some View {
        VStack(spacing: 24) {
            display

            productGrid

            coinRow

            Button(role: .destructive) {
                model.send(.cancel)
            } label: {
                Label("Cancel / Refund", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .animation(.snappy, value: model.state)
    }

    private var display: some View {
        VStack(spacing: 6) {
            Text(model.state.description)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text(model.message)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentTransition(.numericText())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.85), in: .rect(cornerRadius: 16))
        .foregroundStyle(.green)
    }

    private var productGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
            ForEach(model.inventory) { product in
                Button {
                    model.select(product)
                } label: {
                    VStack(spacing: 4) {
                        Text(product.name).font(.headline)
                        Text(product.price.asDollars).font(.subheadline)
                        if model.stock[product.id] == .outOfStock {
                            Text("SOLD OUT").font(.caption2.bold()).foregroundStyle(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 72)
                }
                .buttonStyle(.bordered)
                .disabled(model.stock[product.id] == .outOfStock)
            }
        }
    }

    private var coinRow: some View {
        HStack(spacing: 8) {
            ForEach(coins, id: \.self) { coin in
                Button(coin.description) {
                    model.send(.insertCoin(coin))
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
        }
    }
}

#Preview {
    ContentView()
}
