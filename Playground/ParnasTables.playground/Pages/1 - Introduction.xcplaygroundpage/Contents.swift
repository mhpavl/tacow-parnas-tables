//: # Improving Software Quality Through Formal Specifications
//: ## Using Tabular Notation (Parnas Tables) and Exhaustive Pattern Matching
//:
//: Welcome! This playground demonstrates how formal methods can eliminate entire classes of bugs through compile-time verification.
//:
//: ---
//:
//: ## What Are Parnas Tables?
//:
//: Parnas tables (named after a pioneer of software engineering David Parnas, or software-intensive engineering if you will) are a **tabular notation** for specifying complex logic. They represent decision logic as tables where:
//: * **Rows** represent different scenarios or rules
//: * **Columns** represent inputs and outputs
//: * **Cells** contain specific values or "don't care" wildcards (*)
//:
//: ## Why Use Formal Methods?
//:
//: Traditional if-else statements suffer from:
//: * ❌ **Incompleteness** - missing cases that cause runtime errors
//: * ❌ **Overlapping logic** - multiple conditions matching the same input
//: * ❌ **Hard to validate** - domain experts can't easily review code
//: * ❌ **Fragile refactoring** - changes break in subtle ways
//:
//: Parnas tables + Swift's exhaustive pattern matching give us:
//: * ✅ **Completeness** - every case must be handled
//: * ✅ **Disjointness** - no overlapping rules (when designed correctly)
//: * ✅ **Reviewability** - non-programmers can validate the logic
//: * ✅ **Compile-time verification** - Swift's compiler enforces correctness
//:
//: ## The Key Concepts
//:
//: ### 1. Completeness
//: Every possible input combination has a defined output. Swift's exhaustive switch statements enforce this at compile time.
//:
//: ### 2. Disjointness
//: No input should match multiple rules, preventing non-deterministic behavior. This must be ensured through careful table design.
//:
//: ### 3. One-to-One Mapping
//: Each row in your Parnas table maps directly to a case in your Swift switch statement.
//:
//: ---
//:
//: ## The Process
//:
//: 1. **Design:** Draw your logic as a Parnas table on "paper" or whiteboard
//: 2. **Verify:** Check that your table is complete and disjoint
//: 3. **Review:** Have domain experts validate the table (not code!)
//: 4. **Implement:** Map each table row to a Swift switch case
//: 5. **Compile:** Let Swift verify completeness automatically
//: 6. **Maintain:** When requirements change, update the table first, then code
//:
//: ---
//:
//: ## What You'll Learn
//:
//: This playground contains three real-world examples:
//:
//: ### Example 1: Access Control System
//: A multi-dimensional access control system with roles, resource types, actions, and ownership. Shows how complex authorization logic becomes clear and verifiable.
//:
//: ### Example 2: HVAC Temperature Control
//: A two-dimensional decision space (temperature × humidity) that demonstrates how incomplete tables lead to bugs, and how to design complete, disjoint specifications.
//:
//: ### Example 3: Order Processing State Machine
//: A state machine with events, guard conditions, and side effects. Shows how tabular notation naturally represents complex state transitions.
//:
//: ---
//:
//: ## Try It Yourself!
//:
//: As you go through each example:
//: * Comment out cases to see Swift's "Switch must be exhaustive" error
//: * Add new enum cases and watch the compiler show what needs updating
//: * Modify the tables and see how the code changes to match
//:
//: ---
//:
//: **Ready?** Let's dive into Example 1! →
//:
//: [Next: Access Control System](@next)
