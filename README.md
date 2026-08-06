# Parnas Tables in Swift

Presentations and practical walkthroughs demonstrating how to apply Parnas Tables to Swift development, presented at tacow (Toronto Area Cocoa and WebObjects meetup) in two parts:

- **Part I — Parnas Tables To Swift** (November 12, 2025): the notation, and how Swift's exhaustive `switch` turns a table into compile-time verification.
- **Part II — Parnas Tables, Part Deux: Xcode 27 agents design a formal spec and build an app** (July 28, 2026): co-design a table with an AI assistant, verify it, then let Xcode 27's coding agent generate the working SwiftUI app from it.

## Overview

This repository contains educational materials on using Parnas Tables, a formal specification technique developed by David Parnas, in Swift. Parnas Tables provide a structured way to document software behavior, making complex decision logic clearer and more maintainable.

Part II extends the thesis into agentic development: if the table is the reviewable artifact, then **you review the table, not the code** — and the agent plus the compiler keep the code faithful to it.

## 🚀 Level Up Your Software Quality

Interested in applying Parnas Tables and other formal methods to improve your software quality? I help companies build more maintainable, verifiable, and robust codebases through proven software engineering techniques.

**Available for consulting and training.** Contact me at [mhp@flixel.com](mailto:mhp@flixel.com)

## Contents

### Presentations

**Part I — Parnas Tables To Swift** (November 2025):

- **[PDF Format](Slides/TACOW%20-%20Parnas%20Tables%20To%20Swift.pdf)** - Portable document for easy viewing and sharing
- **[HTML Format](Slides/TACOW%20-%20Parnas%20Tables%20To%20Swift/index.html)** - Interactive web-based presentation (download and open in a browser)

**Part II — Parnas Tables, Part Deux** (July 2026):

- **[PDF Format](Slides/tacow%20-%20Parnas%20tables%20part%202%20-%20Xcode%20agent%20gen.pdf)** - 19 slides covering the motivation (correcting AI slop), a recap of Part I, the new idea, and the live Xcode 27 demo

### Interactive Playground

- **[Swift Playground](Playground/ParnasTables.playground)** - Hands-on walkthrough with executable Swift code

Six pages, each buildable and runnable:

1. **Introduction** — what tabular notation buys you
2. **Example 1: Access Control** — a decision table
3. **Example 2: HVAC Control** — a two-dimensional decision space
4. **Example 3: Order State Machine** — a Mealy machine from a table
5. **Example 4: Vending Machine** — the machine used in the Part II demo (State × Event × Guard)
6. **Summary** — completeness + disjointness = correct code

To use the playground:
1. Clone this repository
2. Open `Playground/ParnasTables.playground` in Xcode
3. Follow along with the examples and experiments

### Demo: Table → State Machine → App

- **[Demo/VendingDemo](Demo/VendingDemo)** — the SwiftUI app from the Part II live demo, generated from the reviewed vending-machine table (`VendingMachine.swift` is a one-case-per-row translation of it), plus a `docs/` folder with the spec, the runbook, and the beat-by-beat demo script.
- **[Demo/VendingDemo/docs](Demo/VendingDemo/docs)** — start here if you want to re-run the demo yourself: the [segment overview](Demo/VendingDemo/docs/README.md), the [Parnas table spec](Demo/VendingDemo/docs/VendingMachine-Spec.md), the [Xcode 27 setup runbook](Demo/VendingDemo/docs/Xcode27-Setup.md), and the [live-demo script](Demo/VendingDemo/docs/Xcode27-Script.md).

## Getting Started

1. **Read the presentations** to understand the theory behind Parnas tables and the agentic workflow built on top of it
2. **Open the playground** in Xcode to see practical Swift implementations
3. **Open `Demo/VendingDemo`** to see a table become a running app
4. **Experiment** with the code examples to solidify your understanding

## What are Parnas Tables?

Parnas tables are a tabular specification method that helps document:
- Complex conditional logic
- State-based behavior
- Decision-making processes

By using tables instead of nested if-statements or complex boolean expressions, you can create more maintainable and verifiable code.

## Requirements

- macOS
- Xcode — the playground targets Swift 6; the demo project was built with **Xcode 27 (27A5228h)** and deploys to iOS 17+
- PDF reader or modern web browser (for the presentations)
- Optional, to reproduce the Part II demo live: an Xcode 27 coding-assistant model provider (Anthropic, OpenAI, or Google) signed in

## License

Copyright ©️ 2025–2026 Mark H Pavlidis. All rights reserved.

## Acknowledgments

Part I delivered at tacow (Toronto Area Cocoa and WebObjects meetup) on November 12, 2025, at <redacted> in 120 Bremner Blvd, Toronto. Part II delivered at tacow on July 28, 2026.

Based on the work of David Parnas and principles of software engineering formalism.
