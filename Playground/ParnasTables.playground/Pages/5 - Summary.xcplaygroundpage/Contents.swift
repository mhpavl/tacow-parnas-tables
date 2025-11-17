//: [Previous: Order Processing](@previous)
//:
//: # Summary: Completeness + Disjointness = Correct Code
//:
//: ## What We've Learned
//:
//: Formal methods using Parnas tables and Swift's exhaustive pattern matching give us **compile-time guarantees** about correctness that traditional if-else statements cannot provide.
//:
//: ---
//:
//: ## The Two Pillars
//:
//: ### 1. Completeness ✓
//: **Every possible input has a defined output.**
//:
//: * **At design time:** Your TABLE covers all cases
//: * **At compile time:** Your SWITCH handles all cases
//: * **Swift's compiler ENFORCES this for you!**
//:
//: When you add a new enum case, the compiler immediately shows every switch that needs updating. No more runtime surprises from unhandled cases.
//:
//: ### 2. Disjointness ✓
//: **No input should match multiple rules.**
//:
//: * **Swift's compiler WARNS about overlapping type patterns**
//: * Use explicit ranges like `[0, 20)` and `[20, 25)` to avoid boundary overlaps
//: * **Important:** Swift doesn't catch overlapping numeric ranges - YOU must design disjoint tables!
//:
//: Disjoint specifications prevent non-deterministic behavior where the order of cases determines the outcome.
//:
//: ---
//:
//: ## The Process (Recap)
//:
//: 1. **Design:** Draw your logic as a Parnas table on paper/whiteboard
//: 2. **Verify:** Check that your table is complete and disjoint
//: 3. **Review:** Have domain experts validate the TABLE (not code!)
//: 4. **Implement:** Map each table row to a Swift switch case
//: 5. **Compile:** Let Swift verify completeness automatically
//: 6. **Maintain:** Update table first when requirements change, then code
//:
//: ---
//:
//: ## The Benefits
//:
//: ✓ **Compile-time verification** - Bugs caught before running
//: ✓ **Living documentation** - Tables readable by non-programmers
//: ✓ **Refactoring safety** - Compiler guides all changes
//: ✓ **Fewer tests needed** - Compiler proves completeness
//: ✓ **Clear communication** - Domain experts validate logic
//: ✓ **No runtime surprises** - All cases explicitly handled
//: ✓ **Maintainability** - Logic centralized and clear
//:
//: ---
//:
//: ## When to Use This Approach
//:
//: Parnas tables + exhaustive matching excel when you have:
//:
//: * **Complex decision logic** with multiple input dimensions
//: * **State machines** with events and transitions
//: * **Access control** with roles, permissions, and contexts
//: * **Business rules** that domain experts need to validate
//: * **Safety-critical systems** where correctness is paramount
//: * **Long-lived code** that will be maintained by multiple people
//:
//: ---
//:
//: ## Quick Reference
//:
//: ### Swift Pattern Matching Syntax
//:
//: ```swift
//: // Exact match
//: case (.user, .publicResource, .read, true)
//:
//: // Don't care (wildcard)
//: case (.admin, _, _, _)
//:
//: // Multiple patterns with same result
//: case (.user, _, .read, true),
//:      (.user, _, .write, true)
//:
//: // Numeric ranges
//: case (..<0, _)              // less than 0
//: case (0..<20, _)            // 0 to 19.999... (half-open)
//: case (20...25, _)           // 20 to 25 (closed)
//: case (25..., _)             // 25 and above
//: case (_, ...60)             // up to and including 60
//:
//: // Associated values
//: case (.pendingPayment, .paymentProcessed(.success), .available)
//: ```
//:
//: ### Table Design Checklist
//:
//: - [ ] List all input dimensions (columns)
//: - [ ] List all possible values for each dimension
//: - [ ] Fill in output for each combination (rows)
//: - [ ] Check for completeness (all combinations covered)
//: - [ ] Check for disjointness (no overlapping ranges)
//: - [ ] Define boundaries explicitly (use [a, b) notation)
//: - [ ] Have domain expert review table
//: - [ ] Map each row to a switch case
//: - [ ] Verify compiler accepts the switch
//: - [ ] Add tests covering key scenarios
//:
//: ---
//:
//: ## Experiments to Try
//:
//: Go back through the examples and:
//:
//: 1. **Comment out a case** - See the compiler error
//: 2. **Add a new enum value** - Watch the compiler show all places to update
//: 3. **Reorder cases** - Notice the result doesn't change (disjointness!)
//: 4. **Create overlapping ranges** - See if the compiler catches it
//: 5. **Draw your own table** - Find a complex decision in your codebase and formalize it
//:
//: ---
//:
//: ## Further Reading
//:
//: * **David Parnas** - "Tabular Representation of Relations" (1992)
//: * **The Swift Programming Language** - Pattern Matching chapter
//: * **Formal Methods** - "Software Specification Methods" by Gerard O'Regan
//: * **Type-Driven Development** - Making invalid states unrepresentable
//:
//: ---
//:
//: ## Apply This to Your Code!
//:
//: Look for these patterns in your codebase:
//:
//: ```swift
//: // ❌ Hard to maintain
//: if role == "admin" {
//:     if action == "delete" {
//:         return true
//:     }
//: } else if role == "user" {
//:     if isOwner && (action == "read" || action == "write") {
//:         return true
//:     }
//: }
//: // ... many more nested conditions ...
//: return false
//: ```
//:
//: ```swift
//: // ✅ Clear, verifiable, maintainable
//: switch (role, resource, action, isOwner) {
//: case (.admin, _, _, _):
//:     return .allow
//: case (.user, _, .read, true),
//:      (.user, _, .write, true):
//:     return .allow
//: // ... all cases explicitly handled
//: }
//: ```
//:
//: ---
//:
//: ## Thank You! 🚀
//:
//: You've learned how formal methods can make your Swift code:
//: * More correct
//: * More maintainable
//: * More reviewable
//: * More refactorable
//:
//: All by leveraging the type system and compiler!
//:
//: **Now go forth and eliminate bugs at compile time!**
//:
//: ---
//:
//: [Back to Introduction](@previous)

import Foundation

print("=" + String(repeating: "=", count: 70))
print("SUMMARY")
print("=" + String(repeating: "=", count: 70))
print()
print("Completeness + Disjointness = Correct Code")
print()
print("Three examples covered:")
print("  ✓ Access Control System (4D input space)")
print("  ✓ HVAC Temperature Control (continuous ranges)")
print("  ✓ Order Processing State Machine (events + guards)")
print()
print("Key insight: Design with tables → Implement with exhaustive switches")
print("Benefit: Compiler verifies correctness automatically")
print()
print(String(repeating: "=", count: 70))
