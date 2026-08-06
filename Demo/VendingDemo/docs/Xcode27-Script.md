# Live-Demo Script — Co-building the Table & Generating the App in Xcode 27

Beat-by-beat script for the Xcode 27 portion. Left column = what you *do/say*;
the fenced blocks = the **exact prompt** to paste into the coding assistant.
Timings assume ~12 minutes. Fallbacks in every risky beat.

> **Setup before you walk on stage**
> - New SwiftUI app project open, empty `ContentView`. Simulator pre-booted.
> - Assistant model set (Anthropic/OpenAI/Google — your call) and signed in.
> - `Demo/VendingDemo/docs/Reference/*.swift` open in another tab (hidden) as the answer key.
> - Network tested. Have a phone hotspot as backup.
> - Optional: run `xcrun agent skills export` beforehand so you can show the
>   *SwiftUI Specialist* skill as "Apple's own formal spec for the agent."

---

## Beat 0 — Recap the thesis (60s, no typing)

Say: *"In November we said: specify complex logic as a Parnas table, and let
Swift's exhaustive switch prove it's complete. Today: we don't write the table
alone, and we don't write the app by hand. We co-design the table with the agent,
review **the table**, and let Xcode build the app. You review the spec, not the
code — and Xcode 27 now works exactly that way."*

Point out the Xcode 27 hook: **the agent's plan is an editable Markdown artifact you
approve before it writes code.** That artifact is where our table is going to live.

---

## Beat 1 — Give the agent the brief, ask for a table (2 min)

Open the coding assistant. Paste:

```
I'm building a vending machine as a state machine, and I want to specify it as a
Parnas table before writing any code.

Behavior: The machine is idle until coins are inserted. As coins go in it collects
a running balance. The customer can select a product: if it's in stock and the
balance covers the price, dispense it and return change; if the balance is short,
say so and keep the money; if it's sold out, say so. At any time the customer can
cancel for a full refund. After dispensing, return to idle.

Produce a Parnas table (a Mealy machine) with columns: Current State, Event, Guard
Condition, New State, Outputs. Use "don't care" (—) where a column doesn't apply.
Do NOT write Swift yet — just the table.
```

Say while it works: *"Notice what I asked for — not code. A table a non-programmer
could read."*

**Fallback:** if the table drifts, the reviewed version is in
[`VendingMachine-Spec.md`](VendingMachine-Spec.md) §2. Read it out and move on.

---

## Beat 2 — Make it EARN completeness & disjointness (2–3 min) ⭐

This is the intellectual core. Don't skip. Paste:

```
Now verify this table like a formal spec:

1. Completeness: build a State × Event matrix. Every cell must be covered. For any
   (state, event) pair with no meaningful transition, make the "ignore it / no-op"
   decision explicit rather than leaving it blank.
2. Disjointness: the (Collecting, selectProduct) rows overlap on state+event — show
   that their guards partition the space with no gap and no overlap.

List anything missing or ambiguous, then give me the corrected table.
```

Say: *"This is the part a flowchart can't do. Three rows share the same state and
event — they're only safe if their guards are exhaustive and mutually exclusive.
The agent is proving that for us, out loud, in the artifact we're reviewing."*

Land the callback: *"In Xcode 27 this reviewed table **is** the plan artifact —
you're approving the spec before a line of Swift exists."*

**Fallback:** the completeness matrix is in [`VendingMachine-Spec.md`](VendingMachine-Spec.md) §3.

---

## Beat 3 — Turn the reviewed table into the model (2 min)

Paste:

```
Generate a Swift 6 model from this exact table. Requirements:
- enums for State (with associated values for balance and the dispensing product),
  Event, a StockStatus guard, and Output.
- A single pure function `transition(from:on:stock:) -> TransitionResult` whose
  switch has ONE case per table row, in table order, each labelled with its row #.
- Rely on Swift's exhaustive switch for completeness — no `default` case.
- Keep the explicitly-ignored (state,event) pairs as their own labelled cases.
Put it in VendingMachine.swift.
```

Show the generated `switch`. Say: *"One row, one case. If I delete a case…"* —
delete one, let it fail to compile — *"…Swift refuses to build. The compiler is now
enforcing the table."* Undo.

**Fallback:** [`Reference/VendingMachine.swift`](Reference/VendingMachine.swift).

---

## Beat 4 — Generate the app around the model (2–3 min)

Paste:

```
Build a single-screen SwiftUI app that drives this machine. Rules:
- The view sends events only; the sole state mutation goes through transition(...).
- Show current state + a display message derived from the Outputs.
- Coin buttons (5¢/10¢/25¢/$1/$2), a product grid with prices and a sold-out state,
  and a Cancel/Refund button.
- Use @Observable for the view model. Dispensing auto-completes after ~1s.
Then run it in the simulator.
```

Let the agent write files, then **drive the simulator on stage**: insert coins →
watch balance; pick the sold-out item → "Sold out"; pick an affordable item →
dispense + change; cancel mid-collection → refund.

**Fallback:** [`Reference/ContentView.swift`](Reference/ContentView.swift) + the model.

---

## Beat 5 — The money moment: change a RULE, not the code (2 min)

This proves the whole thesis. Paste:

```
New requirement: the machine should also charge a 5% "convenience fee" — a product
is only dispensable if balance >= price * 1.05, and change is computed against that
total. Update the Parnas table FIRST (show me the changed rows for
(Collecting, selectProduct)), then update transition(...) to match, then rebuild.
```

> Those are rows 5–6 of the 9-row table in [`VendingMachine-Spec.md`](VendingMachine-Spec.md) §2,
> and rows 6–7 of the expanded 14-row table the shipped app implements. Both land in
> the same place: a single `requiredTotal(forPrice:)` that the affordability guard and
> the change calculation share, so they can't disagree.

Say: *"I changed the **spec**. The table row moved; the code followed; the compiler
kept us honest; the app just works. That's the payoff — the table is the source of
truth, and the agent + compiler keep the code faithful to it."*

**Fallback:** if it wobbles, revert; describe the change verbally against the table.
The *point* survives even if the live edit doesn't.

---

## Beat 6 — Close (30s)

*"We never hand-wrote the state logic and we never hand-wrote the app. We wrote —
and reviewed — a table. Parnas gave us the notation; Swift's exhaustive switch gave
us the proof; Xcode 27's agent turned the reviewed spec into a running app. Formal
methods didn't slow us down. They were the fast path."*

---

## Risk table

| Risk | Mitigation |
|------|------------|
| Network / agent down | `Reference/` files are a complete working app — paste and continue. |
| Agent produces a `default` case (hides incompleteness) | Call it out on stage as the exact anti-pattern; re-prompt "no default; one case per row." Good teaching moment. |
| Simulator slow to boot | Pre-boot before the talk; keep it open. |
| Generated UI ugly/oversized | Doesn't matter — say so; the logic is the point. |
| Xcode 27 feature named here has moved | Re-verify against your build; the script only depends on "agent can edit files + run the sim." |
| Ran long | Beats 2 and 5 are the essential ones. Beat 4's UI can be the `Reference` file pre-loaded. |
