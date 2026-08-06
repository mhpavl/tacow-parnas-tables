# From Parnas Table → State Machine → App (with Xcode 27)

The demo segment from **Part II — "Parnas Tables, Part Deux"** (tacow, July 28, 2026),
a follow-on to the November 2025 talk *"Parnas Tables in Swift."*
The original talk ended at **Example 3: an Order Processing State Machine** — showing
that state machines fall naturally out of tabular notation. This segment turns that
idea into a live, end-to-end story:

> **Co-design a formal spec with an AI assistant → verify it → let Xcode 27's
> agent generate a working SwiftUI app from it.**

The punchline ties directly back to the thesis of the original talk:
**you review the *table*, not the code.** And in Xcode 27 that's now literally how
the tool works — the agent's plan is an editable Markdown artifact you approve
*before* it writes a line of Swift.

The app that came out of it is checked in one level up, in
[`../VendingDemo/`](../VendingDemo/) — see [Where the code lives](#where-the-code-lives).

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

The same machine is also an executable page in the Part I playground:
[`Playground/ParnasTables.playground` → *5 - Example 4 - Vending Machine*](../../../Playground/ParnasTables.playground).

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

## Where the code lives

The repo now holds the **result** of the demo, not just the starting point. Layout:

```
Demo/VendingDemo/
├─ VendingDemo.xcodeproj
├─ VendingDemo/                 ← the app, as the agent left it (the AFTER state)
│  ├─ VendingMachine.swift      ← 14-row table → one switch case per row, + 5% fee
│  ├─ VendingViewModel.swift    ← owns inventory; `send(_:)` is the only mutation path
│  ├─ ContentView.swift         ← the driving UI (display, products, coins, cancel)
│  └─ VendingDemoApp.swift
└─ docs/                        ← you are here
   ├─ README.md
   ├─ VendingMachine-Spec.md
   ├─ Xcode27-Setup.md
   ├─ Xcode27-Script.md
   └─ Reference/                ← the hand-written answer key (see caveat below)
```

Verified `BUILD SUCCEEDED` on **Xcode 27 (27A5228h)** for the iOS Simulator
(iPhone 16), deployment target iOS 17.

**The slides for this segment are a PDF, one level up in the repo:**
[`Slides/tacow - Parnas tables part 2 - Xcode agent gen.pdf`](../../../Slides/tacow%20-%20Parnas%20tables%20part%202%20-%20Xcode%20agent%20gen.pdf)
(19 slides). The earlier `.pptx` draft has been dropped.

### Documents in this folder

| File | Purpose |
|------|---------|
| [`VendingMachine-Spec.md`](VendingMachine-Spec.md) | The plain-English brief + the Parnas table + completeness/disjointness check. The thing you co-build with the assistant. |
| [`Xcode27-Setup.md`](Xcode27-Setup.md) | **Demo runbook** — how to open the project, configure the Xcode 27 assistant, verify its agent capabilities, run the demo, and fall back. Includes a pre-flight checklist. |
| [`Xcode27-Script.md`](Xcode27-Script.md) | Beat-by-beat live-demo script: the exact prompts to give the agent, what to say, and the fallback if the network/agent misbehaves. |
| [`Reference/VendingMachine.swift`](Reference/VendingMachine.swift) | A hand-written model written *before* the demo, against the 9-row table: exhaustive `switch`, one row per table line. Answer key / discussion piece. |
| [`Reference/ContentView.swift`](Reference/ContentView.swift) | A hand-written SwiftUI screen (with its own `VendingMachineModel`) that drives that model. |

### Re-running the demo from the "before" state

`Demo/VendingDemo/VendingDemo/` is now the finished app, so if you want the empty
starter the agent builds *into*, restore it from the commit that introduced it:

```bash
git show 298e4f6:Demo/VendingDemo/VendingDemo/ContentView.swift > /tmp/starter-ContentView.swift
# then, on a scratch branch:
git checkout 298e4f6 -- Demo/VendingDemo/VendingDemo/ContentView.swift
rm Demo/VendingDemo/VendingDemo/VendingMachine.swift Demo/VendingDemo/VendingDemo/VendingViewModel.swift
```

That leaves a placeholder "Vending Machine" screen that builds and runs — the
**BEFORE** state described in [`Xcode27-Setup.md`](Xcode27-Setup.md).

### Caveat on `Reference/` as a paste-in fallback

The `Reference/` files predate the demo and use **different type names and a
different shape** than the shipped app (`VendingState`/`VendingEvent` vs `State`/`Event`,
`Coin` enum, `[Output]` instead of a single `Output`, no convenience fee, and no
separate view model). They are a complete working implementation *on their own*, but
they will **not** compile alongside `VendingViewModel.swift` — copying them in means
removing that file too:

```bash
rm Demo/VendingDemo/VendingDemo/VendingViewModel.swift
cp Demo/VendingDemo/docs/Reference/VendingMachine.swift Demo/VendingDemo/VendingDemo/
cp Demo/VendingDemo/docs/Reference/ContentView.swift    Demo/VendingDemo/VendingDemo/
```

The folder is a **synchronized group**, so the files are picked up automatically —
no "add to target" step.

**Stage insurance:** either fallback works — the `Reference/` pair, or simply the
shipped app on `main`. If the live agent stalls, keep the story moving; the point of
the talk is the *table*, not whether the demo gods are kind.
