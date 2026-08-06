# Xcode 27 — Demo Setup & Runbook

Everything you need to actually run the "table → app" demo on stage. Pair this with
the prompt-by-prompt choreography in [`Xcode27-Script.md`](Xcode27-Script.md).

> **Status:** the app in [`../VendingDemo/`](../VendingDemo/) and the
> stage-backup [`Reference/`](Reference/) files were **both built with Xcode 27
> (27A5228h) for the iOS Simulator — `BUILD SUCCEEDED`.** So the failsafe is known-good;
> only the live agent portion depends on the demo gods.
>
> **Note:** `../VendingDemo/` now holds the **finished** app (the AFTER state — state
> machine, view model, driving UI, 5% convenience fee). To demo from the empty
> starter again, restore it as described in [`README.md`](README.md#re-running-the-demo-from-the-before-state).

---

## 1. Get the project open (pick one)

### Option A — use the provided project (fastest) ✅ verified
```bash
open "Demo/VendingDemo/VendingDemo.xcodeproj"
```
- Target `VendingDemo`, scheme `VendingDemo`, iOS 17+, bundle id `com.tacow.VendingDemo`.
- It builds and runs as-is — but on `main` it is the **AFTER** state (the finished
  vending app). Roll it back to the placeholder start screen first if you want the
  **BEFORE** state: see
  [`README.md`](README.md#re-running-the-demo-from-the-before-state).
- Pick a simulator (e.g. iPhone 16) and hit **⌘R** once before the talk to warm it up.

### Option B — create fresh in ~30 seconds (failsafe you fully control)
`File ▸ New ▸ Project… ▸ iOS ▸ App`. Product name `VendingDemo`, Interface **SwiftUI**,
Language **Swift**. Delete the boilerplate body of `ContentView`. Done — this is
equivalent to the starter.

Either way, the agent will add `VendingMachine.swift` and rewrite `ContentView.swift`.

---

## 2. Configure the coding assistant

1. **Sign in / add a model provider.** Xcode 27 ▸ Settings ▸ **Intelligence** (a.k.a.
   the Coding Assistant / Models pane). Add a provider — Anthropic, OpenAI, or Google —
   and sign in or paste an API key. *Do this before the talk; the auth flow is not
   something you want live.*
2. **Pick your model** in the assistant's model selector. Prefer a strong reasoning
   model for the completeness/disjointness step (Beat 2 of the script).
3. **Open the assistant panel** (the coding-assistant transcript now lives in the
   editor area — give it its own tab or split so the audience can read it).
4. *(Optional, nice aside)* export Apple's own SwiftUI agent skills so you can show
   "Apple ships a formal spec for the agent too":
   ```bash
   xcrun agent skills export
   ```

> ⚠️ Exact menu names/paths in your build may differ from these notes — **click through
> the whole flow once beforehand** and correct anything that moved.

---

## 3. Verify the three agent capabilities the demo needs

Confirm each of these works in *your* build before you rely on it on stage:

| Capability | Quick check | Used in |
|-----------|-------------|---------|
| **Multi-file edits** | Ask: *"add a file Ping.swift with a stub func."* Confirm it creates the file. | Beats 3–4 |
| **Plan as an editable Markdown artifact** | Give it a small feature and confirm a **plan artifact** appears that you can edit before it acts. | Beat 2 (this is the thesis moment) |
| **Run in the simulator** | Ask it to build & run, or just ⌘R yourself. | Beat 4 |

If the plan-artifact behavior isn't in your build, you can still tell the story: keep
the reviewed Parnas table open in a Markdown tab beside the assistant and treat *that*
as the plan you approve before generating.

---

## 4. Run the demo

Follow [`Xcode27-Script.md`](Xcode27-Script.md) beat by beat. In short:

1. Paste the brief → ask for a **Parnas table**, no Swift yet.
2. Ask it to **verify completeness & disjointness**; fix the table together.
3. Generate **`VendingMachine.swift`** — one `switch` case per row, no `default`.
4. Generate the **SwiftUI UI**; run it in the simulator.
5. **Change a rule** (5% convenience fee) in the table → regenerate → app updates.

---

## 5. Fallback (rehearse this once)

If the agent stalls, the network drops, or output goes sideways — paste the verified
reference files and keep the story moving:

```bash
# the Reference pair replaces BOTH the model and the UI — and their type names
# differ from the shipped app, so VendingViewModel.swift must go with them
rm Demo/VendingDemo/VendingDemo/VendingViewModel.swift
cp Demo/VendingDemo/docs/Reference/VendingMachine.swift Demo/VendingDemo/VendingDemo/
cp Demo/VendingDemo/docs/Reference/ContentView.swift    Demo/VendingDemo/VendingDemo/
```
Because the folder is a **synchronized group**, the new files are picked up
automatically — no "add to target" step. Build & run.

Simpler alternative now that the finished app is checked in: just `git checkout main --
Demo/VendingDemo/VendingDemo/` and run *that*. It's the 14-row table with the
convenience fee, i.e. the end state of every beat.

The talk's point is the **table**, not whether the live generation is flawless. The
fallback lets you land every beat regardless.

---

## Pre-flight checklist

- [ ] Xcode 27 open on `VendingDemo`; **⌘R** succeeds on your chosen simulator.
- [ ] Assistant signed in; model selected; panel docked where the room can read it.
- [ ] Walked the real menus for the three capabilities in §3.
- [ ] `Reference/` files rehearsed as a paste-in fallback.
- [ ] Network tested; phone hotspot ready.
- [ ] Font size / appearance bumped for projection (Settings ▸ Themes).
- [ ] `Xcode27-Script.md` open on a second screen / phone for the prompts.
