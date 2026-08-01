# From Parnas Table → State Machine → App (with Xcode 27)

A follow-on segment to the November 2025 tacow talk *"Parnas Tables in Swift."*
The original talk ended at **Example 3: an Order Processing State Machine** — showing
that state machines fall naturally out of tabular notation. This segment turns that
idea into a live, end-to-end story:

> **Co-design a formal spec with an AI assistant → verify it → let Xcode 27's
> agent generate a working SwiftUI app from it.**

The punchline ties directly back to the thesis of the original talk:
**you review the *table*, not the code.** And in Xcode 27 that's now literally how
the tool works — the agent's plan is an editable Markdown artifact you approve
*before* it writes a line of Swift.

---

## The narrative arc

| Beat | Original talk | This segment |
|------|---------------|--------------|
| 1 | Parnas tables specify complex logic | Same — recap in 60 seconds |
| 2 | Swift's exhaustive `switch` enforces completeness | Same — recap |
| 3 | State machines fit tables naturally (Order example) | **Pick a fresh, demo-sized machine** |
| 4 | *(end)* | **Co-build the table with the AI assistant** |
| 5 | *(end)* | **Xcode 27 agent turns the reviewed table into an app** |
| 6 | *(end)* | Change a rule in the table → regenerate → app updates |

The emotional beat we're selling: *the formal spec is not overhead you do
**instead** of shipping — it's the fastest path **to** shipping, because it's the
artifact the agent (and your domain expert) both review.*

---

## Why a vending machine?

We deliberately switch away from the 7-state order machine. On stage you want
something that:

- **Builds fast** — 3 states, 4 events. The whole app is one screen.
- **Has guard conditions** — "enough credit?" and "in stock?" are exactly the
  *3-dimensional input* (State × Event × Guard) that makes Parnas tables earn
  their keep. A traffic light or turnstile is too flat to show this.
- **Maps to an obvious UI** — a display, coin buttons, product buttons, a cancel
  button. The audience can predict the app before it's generated, which makes the
  agent's output feel *verifiable* rather than magic.

The full spec is in [`VendingMachine-Spec.md`](VendingMachine-Spec.md).
Swap it for any small machine (media player, ticket/kanban flow) — the segment
structure is identical.

---

## What Xcode 27 brings (verified June–July 2026)

These are the capabilities the demo leans on. **Re-verify against your actual
Xcode 27 build before the talk** — versions move.

- **Agentic coding.** The assistant plans features, edits across multiple files,
  runs tests, and drives the simulator — it takes multi-step actions, not just
  autocomplete.
- **Planning is first-class.** The agent's plan appears as an **editable Markdown
  artifact** next to the conversation. You review and adjust it *before* the agent
  acts. → *This is where the Parnas table lives.*
- **Artifacts & diffs are visible.** The editor shows what the agent changed and
  any artifacts it produced, so "verify the change" is a real on-stage moment.
- **Model choice.** Anthropic, Google, and OpenAI models are selectable in the
  assistant.
- **Apple's own agent skills** ship in the toolchain — a *SwiftUI Specialist* skill
  and a *What's New in SwiftUI* skill — plain Markdown the assistant reaches for.
  Export them with `xcrun agent skills export` (nice aside: skills *are* a kind of
  formal spec for the agent, echoing the table).
- **Single-file previews.** Opening a lone Swift file gives a workspace with
  playground results and UI previews in the canvas — no `.xcodeproj` required, handy
  for the recap.

Sources:
- [What's new in Xcode 27 — WWDC26 (Apple Developer)](https://developer.apple.com/videos/play/wwdc2026/258/)
- [Apple's AI agents in Xcode 27 make vibe coding easier (AppleInsider)](https://appleinsider.com/articles/26/06/17/apples-ai-agents-in-xcode-27-make-vibe-coding-easier)
- [Xcode 27 Ships Apple's Own Agent Skills (DEV)](https://dev.to/arshtechpro/wwdc-2026-xcode-27-ships-with-apples-own-agent-skills-what-they-are-and-how-to-use-them-3g2)
- [SwiftUI Best Practices from Xcode 27's Agent Skill (SwiftLee)](https://www.avanderlee.com/ai-development/swiftui-best-practices-xcode-27-agent-skill/)

---

## Files in this folder

| File | Purpose |
|------|---------|
| [`TACOW - Parnas Tables Part II (Xcode 27).pptx`](TACOW%20-%20Parnas%20Tables%20Part%20II%20%28Xcode%2027%29.pptx) | The **slides** for this segment (14 slides, presenter notes on every slide). Built as `.pptx` — **open in Keynote** and restyle to match your existing deck. |
| [`VendingMachine-Spec.md`](VendingMachine-Spec.md) | The plain-English brief + the Parnas table + completeness/disjointness check. The thing you co-build with the assistant. |
| [`Xcode27-Setup.md`](Xcode27-Setup.md) | **Demo runbook** — how to open the project, configure the Xcode 27 assistant, verify its agent capabilities, run the demo, and fall back. Includes a pre-flight checklist. |
| [`Xcode27-Script.md`](Xcode27-Script.md) | Beat-by-beat live-demo script: the exact prompts to give the agent, what to say, and the fallback if the network/agent misbehaves. |
| [`VendingDemo/`](VendingDemo/) | A minimal SwiftUI **starter Xcode project** (the "before" state the agent builds into). Verified `BUILD SUCCEEDED` on Xcode 27 for the simulator. |
| [`Reference/VendingMachine.swift`](Reference/VendingMachine.swift) | The model the agent *should* produce — exhaustive `switch`, one row per table line. Your stage-safe backup / answer key. |
| [`Reference/ContentView.swift`](Reference/ContentView.swift) | The SwiftUI screen that drives the machine. Backup / answer key. Builds cleanly when swapped into `VendingDemo/`. |

**Stage insurance:** the `Reference/` files are a working implementation. If the
live agent stalls, paste these in and keep the story moving — the point of the talk
is the *table*, not whether the demo gods are kind.
