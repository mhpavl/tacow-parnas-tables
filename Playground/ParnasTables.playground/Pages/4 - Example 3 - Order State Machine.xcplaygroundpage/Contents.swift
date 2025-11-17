//: [Previous: HVAC Control](@previous)
//:
//: # Example 3: Order Processing State Machine
//:
//: ## State Machines are Natural for Tables
//: This is a **Mealy Machine** where outputs depend on both current state and input.
//: Each column represents a key element:
//: * Current State
//: * Event (input)
//: * Guard Conditions
//: * New State
//: * Outputs (actions initiated by the state transiton)
//:
//: ```
//: ┌────────────────┬─────────────────┬───────────┬─────────────┬───────────────────┐
//: │ Current State  │ Event           │ Condition │ New State   │ Outputs           │
//: ├────────────────┼─────────────────┼───────────┼─────────────┼───────────────────┤
//: │ Draft          │ Submit          │ -         │ PendingPay  │ validate, email   │
//: │ PendingPayment │ PaySuccess      │ available │ Processing  │ reserveInventory  │
//: │ PendingPayment │ PaySuccess      │ unavail   │ Backordered │ notifyCustomer    │
//: │ PendingPayment │ PayFailed       │ -         │ Cancelled   │ refund            │
//: │ Processing     │ Ship            │ -         │ Shipped     │ updateTracking    │
//: │ Backordered    │ InvAvailable    │ -         │ Processing  │ reserve, notify   │
//: │ Shipped        │ Deliver         │ -         │ Completed   │ sendReceipt       │
//: │ *(not final)   │ Cancel          │ -         │ Cancelled   │ cancel, release   │
//: └────────────────┴─────────────────┴───────────┴─────────────┴───────────────────┘
//: where final states are {Completed, Cancelled}
//: ```
//:

import Foundation

print("=" + String(repeating: "=", count: 70))
print("EXAMPLE 3: ORDER PROCESSING STATE MACHINE")
print("=" + String(repeating: "=", count: 70) + "\n")

enum OrderState: CustomStringConvertible {
    case draft
    case pendingPayment
    case processing
    case backordered
    case shipped
    case completed
    case cancelled
    
    var description: String {
        switch self {
        case .draft: return "Draft"
        case .pendingPayment: return "Pending Payment"
        case .processing: return "Processing"
        case .backordered: return "Backordered"
        case .shipped: return "Shipped"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum PaymentStatus {
    case pending
    case success
    case failed
}

enum InventoryStatus {
    case available
    case unavailable
}

enum OrderEvent {
    case submit
    case paymentProcessed(PaymentStatus)
    case inventoryAvailable
    case ship
    case deliver
    case cancel
}

enum Output: CustomStringConvertible {
    case validateOrder
    case sendEmail
    case reserveInventory
    case notifyCustomer
    case refundInitiated
    case cancelOrder
    case releaseInventory
    case updateTracking
    case sendReceipt
    
    var description: String {
        switch self {
        case .validateOrder: return "validateOrder()"
        case .sendEmail: return "sendEmail()"
        case .reserveInventory: return "reserveInventory()"
        case .notifyCustomer: return "notifyCustomer()"
        case .refundInitiated: return "refundInitiated()"
        case .cancelOrder: return "cancelOrder()"
        case .releaseInventory: return "releaseInventory()"
        case .updateTracking: return "updateTracking()"
        case .sendReceipt: return "sendReceipt()"
        }
    }
}

struct TransitionResult {
    let newState: OrderState
    let outputs: [Output]
}

func processOrderEvent(
    currentState: OrderState,
    event: OrderEvent,
    inventoryStatus: InventoryStatus
) -> TransitionResult {
    switch (currentState, event, inventoryStatus) {
    
    // Draft → Submit
    case (.draft, .submit, _):
        return TransitionResult(
            newState: .pendingPayment,
            outputs: [.validateOrder, .sendEmail]
        )
    
    // PendingPayment → Payment Success
    case (.pendingPayment, .paymentProcessed(.success), .available):
        return TransitionResult(
            newState: .processing,
            outputs: [.reserveInventory]
        )
    
    case (.pendingPayment, .paymentProcessed(.success), .unavailable):
        return TransitionResult(
            newState: .backordered,
            outputs: [.notifyCustomer]
        )
    
    // PendingPayment → Payment Failed
    case (.pendingPayment, .paymentProcessed(.failed), _):
        return TransitionResult(
            newState: .cancelled,
            outputs: [.refundInitiated]
        )
    
    // PendingPayment → Payment Pending
    case (.pendingPayment, .paymentProcessed(.pending), _):
        return TransitionResult(
            newState: .pendingPayment,
            outputs: []
        )
    
    // Backordered → Inventory Available
    case (.backordered, .inventoryAvailable, _):
        return TransitionResult(
            newState: .processing,
            outputs: [.reserveInventory, .notifyCustomer]
        )
    
    // Processing → Ship
    case (.processing, .ship, _):
        return TransitionResult(
            newState: .shipped,
            outputs: [.updateTracking]
        )
    
    // Shipped → Deliver
    case (.shipped, .deliver, _):
        return TransitionResult(
            newState: .completed,
            outputs: [.sendReceipt]
        )
    
    // Cancel from non-final states
    case (.draft, .cancel, _),
         (.pendingPayment, .cancel, _),
         (.processing, .cancel, _),
         (.backordered, .cancel, _),
         (.shipped, .cancel, _):
        return TransitionResult(
            newState: .cancelled,
            outputs: [.cancelOrder, .releaseInventory]
        )
    
    // All invalid transitions - no state change
    case (.draft, .paymentProcessed, _),
         (.draft, .ship, _),
         (.draft, .deliver, _),
         (.draft, .inventoryAvailable, _),
         (.pendingPayment, .submit, _),
         (.pendingPayment, .ship, _),
         (.pendingPayment, .deliver, _),
         (.pendingPayment, .inventoryAvailable, _),
         (.processing, .submit, _),
         (.processing, .paymentProcessed, _),
         (.processing, .deliver, _),
         (.processing, .inventoryAvailable, _),
         (.backordered, .submit, _),
         (.backordered, .paymentProcessed, _),
         (.backordered, .ship, _),
         (.backordered, .deliver, _),
         (.shipped, .submit, _),
         (.shipped, .paymentProcessed, _),
         (.shipped, .ship, _),
         (.shipped, .inventoryAvailable, _),
//         (.shipped, .cancel, _), // uncomment to observe compiler catching disjointness violation
         (.completed, _, _),
         (.cancelled, _, _):
        return TransitionResult(
            newState: currentState,
            outputs: []
        )
    }
}

//: ## Simulating an Order Lifecycle

print("Order Lifecycle Simulation:\n")

var currentState = OrderState.draft
print("Initial State: \(currentState)\n")

let events: [(OrderEvent, InventoryStatus, String)] = [
    (.submit, .available, "Customer submits order"),
    (.paymentProcessed(.success), .available, "Payment succeeds, inventory available"),
    (.ship, .available, "Order ships"),
    (.deliver, .available, "Order delivered"),
]

for (event, inventory, description) in events {
    let result = processOrderEvent(
        currentState: currentState,
        event: event,
        inventoryStatus: inventory
    )
    
    print("Event: \(description)")
    print("  \(currentState) → \(result.newState)")
    if !result.outputs.isEmpty {
        print("  Outputs: \(result.outputs.map { $0.description }.joined(separator: ", "))")
    }
    print()
    
    currentState = result.newState
}

//: ## Key Takeaways
//:
//: * **This is a Mealy Machine:** Outputs depend on both current state and input
//: * **State machines naturally fit tabular notation**
//: * **Three-dimensional input:** Current State × Event × Guard Conditions
//: * **Two types of output:** New State + Outputs (actions to perform)
//: * **Invalid transitions are explicit:** Rather than crashing, they're handled gracefully
//: * **Associated values in events:** `paymentProcessed(PaymentStatus)` adds depth
//: * **Guard conditions split transitions:** Same state + event can lead to different outcomes
//:
//: ## Real-World Benefits
//:
//: This approach helps you:
//: * **Document state machines clearly** for product managers and QA
//: * **Prevent impossible states** through exhaustive matching
//: * **Track outputs explicitly** rather than hiding them in methods
//: * **Test transitions systematically** by walking through each table row
//: * **Refactor safely** when business rules change
//:
//: ---
//:
//: [Next: Summary](@next)
