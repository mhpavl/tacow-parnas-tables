
//: [Previous: Introduction](@previous)
//:
//: # Example 1: Access Control System
//:
//: ## The Problem
//: Traditional access control uses nested if-else statements that are:
//: * Hard to verify for completeness
//: * Easy to introduce bugs in
//: * Difficult for domain experts to validate
//:
//: ## The Solution: Tabular Notation
//:
//: ```
//: ┌───────────┬───────────────┬────────┬────────┬────────┐
//: │ User Role │ Resource Type │ Action │ Owner? │ Result │
//: ├───────────┼───────────────┼────────┼────────┼────────┤
//: │ Admin     │ *             │ *      │ *      │ Allow  │
//: │ User      │ Public        │ Read   │ *      │ Allow  │
//: │ User      │ Shared        │ Read   │ *      │ Allow  │
//: │ User      │ *             │ Read   │ Yes    │ Allow  │
//: │ User      │ *             │ Write  │ Yes    │ Allow  │
//: │ User      │ *             │ Delete │ Yes    │ Allow  │
//: │ Guest     │ Public        │ Read   │ *      │ Allow  │
//: │ (all other combinations)  │        │        │ Deny   │
//: └───────────┴───────────────┴────────┴────────┴────────┘
//: ```
//:
//: **Key insight:** Each row becomes a `case` in the switch statement.
//:
//: ### The Preamble
//: Setting up the types of our inputs and some pretty results output
import Foundation

print("=" + String(repeating: "=", count: 70))
print("EXAMPLE 1: ACCESS CONTROL SYSTEM")
print("=" + String(repeating: "=", count: 70) + "\n")

enum UserRole {
    case admin
    case user
    case guest
}

enum ResourceType {
    case `public`
    case shared
    case `private`
}

enum Action {
    case read
    case write
    case delete
}

enum AccessResult {
    case allow
    case deny
    
    var symbol: String {
        switch self {
        case .allow: return "✓"
        case .deny: return "✗"
        }
    }
}

//: ## The Implementation
//: Notice how the table maps 1:1 to code:
//: * Any (Don't Care) cases `*` become underscores `_` in Swift
//: * Specific values become exact matches
//: * Multiple rows with same result can be combined
//: > **Try this:** Comment out some of the deny cases and watch the compiler complain!
//: >
//: > **Try this:** Add an `update` case to the set of `Action`s and watch the compiler complain!
//:

func checkAccess(
    role: UserRole,
    resource: ResourceType,
    action: Action,
    isOwner: Bool
) -> AccessResult {
    switch (role, resource, action, isOwner) {
    // Admin can do anything
    case (.admin, _, _, _):
        return .allow
    
    // User access to public resources (read only)
    case (.user, .public, .read, _):
        return .allow
    
    // User access to shared resources (read only)
    case (.user, .shared, .read, _):
        return .allow
    
    // User access to owned resources (full control)
    case (.user, _, .read, true),
         (.user, _, .write, true),
         (.user, _, .delete, true):
        return .allow
    
    // Guest access (read public only)
    case (.guest, .public, .read, _):
        return .allow
    
    // All other cases denied
    case (.user, .public, .write, _),
         (.user, .public, .delete, _),
         (.user, .shared, .write, _),
         (.user, .shared, .delete, _),
         (.user, .private, .read, false),
         (.user, .private, .write, false),
         (.user, .private, .delete, false),
         (.guest, .public, .write, _),
         (.guest, .public, .delete, _),
         (.guest, .shared, _, _),
         (.guest, .private, _, _):
        return .deny
    }
}

//: ## Test Results

let testCases: [(UserRole, ResourceType, Action, Bool, String)] = [
    (.admin, .public, .delete, false, "Admin deletes public"),
    (.admin, .private, .write, false, "Admin writes private (not owner)"),
    (.user, .public, .read, false, "User reads public"),
    (.user, .public, .write, false, "User writes public"),
    (.user, .shared, .read, false, "User reads shared"),
    (.user, .private, .read, true, "User reads own private"),
    (.user, .private, .write, true, "User writes own private"),
    (.user, .private, .delete, true, "User deletes own private"),
    (.user, .private, .read, false, "User reads other's private"),
    (.guest, .public, .read, false, "Guest reads public"),
    (.guest, .public, .write, false, "Guest writes public"),
    (.guest, .shared, .read, false, "Guest reads shared"),
]

for (role, resource, action, isOwner, description) in testCases {
    let result = checkAccess(role: role, resource: resource, action: action, isOwner: isOwner)
    print("\(result.symbol) \(description)")
}

print("\n")

//: ## Key Takeaways
//:
//: * **Four-dimensional input space:** Role × Resource × Action × Ownership = 3 × 3 × 3 × 2 = 54 possible combinations
//: * Table reduces that complexity to 8 rows
//: * `switch` reduces it 18 `case` statements
//: * **Compiler-verified completeness:** Every combination is explicitly handled
//: * **Clear business rules:** Security team can review the table, not code
//: * **Safe refactoring:** Add a new role or action? Compiler shows every place to update
//:
//: ---
//:
//: [Next: HVAC Control](@next)
