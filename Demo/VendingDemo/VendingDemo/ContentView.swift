//
//  ContentView.swift
//  VendingDemo
//
//  Single-screen UI that drives the state machine. The view is a thin shell:
//  every button calls `model.send(_:)` with an Event and nothing else. All
//  state changes happen inside `transition(...)`, reached only through `send`.
//

import SwiftUI

struct ContentView: View {
    @State private var model = VendingViewModel()

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        VStack(spacing: 20) {
            display
            productGrid
            coinRow
            cancelButton
        }
        .padding()
        .disabled(model.isDispensing)   // rows 11–13: input locked while vending
        .animation(.default, value: model.message)
    }

    // MARK: Display — current state + Output-derived message

    private var display: some View {
        VStack(spacing: 8) {
            Text(stateLabel)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)

            Text(model.message)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 60)

            Text("Balance: \(VendingViewModel.money(model.balance))")
                .font(.headline)
                .foregroundStyle(.tint)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }

    private var stateLabel: String {
        switch model.state {
        case .idle:                    "STATE: IDLE"
        case .collecting(let b):       "STATE: COLLECTING (\(VendingViewModel.money(b)))"
        case .dispensing(let p):       "STATE: DISPENSING (\(p.name))"
        }
    }

    // MARK: Product grid

    private var productGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(model.inventory) { slot in
                Button {
                    model.send(.selectProduct(slot.product))
                } label: {
                    VStack(spacing: 4) {
                        Text(slot.product.name)
                            .font(.headline)

                        if slot.isSoldOut {
                            Text("SOLD OUT")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        } else {
                            Text(VendingViewModel.money(slot.price))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            // Fee-inclusive amount the machine actually requires.
                            Text("+5% → \(VendingViewModel.money(requiredTotal(forPrice: slot.price)))")
                                .font(.caption2)
                                .foregroundStyle(.tint)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        if slot.isSoldOut {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.red.opacity(0.4))
                        }
                    }
                }
                .buttonStyle(.plain)
                .opacity(slot.isSoldOut ? 0.5 : 1)
            }
        }
    }

    // MARK: Coin row

    private var coinRow: some View {
        HStack(spacing: 10) {
            ForEach(model.coins, id: \.self) { coin in
                Button(coinLabel(coin)) {
                    model.send(.insertCoin(coin))
                }
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(.tint.opacity(0.15), in: Capsule())
            }
        }
    }

    private func coinLabel(_ cents: Int) -> String {
        cents < 100 ? "\(cents)¢" : "$\(cents / 100)"
    }

    // MARK: Cancel / Refund

    private var cancelButton: some View {
        Button(role: .destructive) {
            model.send(.cancel)
        } label: {
            Text("Cancel / Refund")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

#Preview {
    ContentView()
}
