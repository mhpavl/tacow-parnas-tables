# Presenter Notes — Parnas Tables Part II (Xcode 27)

**Rehearsal script for _TACOW · Parnas Tables Part II — Tables → State Machines → Apps_.**

Read straight through to practice out loud, or have your phone read it aloud
("Listen to Page" / screen reader) while travelling. Each slide gives you a quick
**On screen** cue (what the audience is looking at) followed by **Say** — the words
to deliver. Live-demo prompts are folded in where you paste them, and collected in
full in the [Demo Prompts appendix](#appendix--the-five-live-demo-prompts).

- **Deck:** `Demo/TACOW - Parnas Tables Part II (Xcode 27).pptx` (16 slides)
- **Rough runtime:** ~20–25 min, with the live Xcode 27 build (~12 min) landing over slides 10–13
- **The whole talk in one line:** co-design a formal spec with an AI agent, review the *table*, and let Xcode 27 build the app from it — formal methods as the fast path, not overhead.

---

## Slide 1 — Title: Parnas Tables · Part II

**On screen:** Tables → State Machines → Apps. Co-designing a formal spec with an AI agent — and letting Xcode 27 build the app from it.

**Say:**
Welcome back. In November we introduced Parnas Tables in Swift. This is Part II.
The whole talk in one line: we co-design a formal spec with an AI agent, we review
the *table*, and we let Xcode 27's agent turn it into a running app. Formal methods
as the *fast* path, not overhead.

---

## Slide 2 — Motivation: Correcting AI slop

**On screen:** "What if the agent's output were correct by construction?" — fast but confidently wrong; reviewing code doesn't scale, a table does.

**Say:**
Everyone's shipping AI-generated code and quietly hoping it's right. Generation got
cheap; trust didn't. That's the motivation for this whole talk. My claim: stop
reviewing the *output* and start reviewing the *spec*. Generation is fast but
confidently wrong — plausible code, subtle bugs. You cannot out-review a firehose of
diffs, but anyone can check a table. And if the table is complete and disjoint and the
switch is exhaustive, the *compiler* — not vibes — certifies the agent got it right.
We're not making the agent write more; we're making it impossible for it to be
silently wrong.

---

## Slide 3 — Where we left off: the thesis from November

**On screen:** Three beats — (1) Specify as a table, (2) Let the compiler prove it, (3) Review the table, not the code.

**Say:**
Sixty-second recap. The November thesis in three beats: one, specify complex logic as
a Parnas table; two, map each row to a switch case and let Swift's exhaustive matching
prove completeness; three, so the thing you review is the *table*, not the code. We
ended on an order-processing state machine — because state machines fall out of tables
naturally. That's our jumping-off point today.

---

## Slide 4 — The new idea

**On screen:** Don't write the table alone. Don't write the app by hand. The table stays the source of truth.

**Say:**
Here's the twist for Part II. Last time *we* wrote the table and *we* wrote the code.
Today we do neither by hand. We co-design the table with the AI assistant, we verify
it together, and we let Xcode 27's agent generate the app. The table is still the
source of truth — the agent plus the compiler keep the code honest to it.

---

## Slide 5 — Our demo machine: a vending machine

**On screen:** 3 states, 4 events. Builds fast · real guards ("enough credit?", "in stock?") · obvious UI.

**Say:**
We deliberately swap away from the seven-state order machine to something we can build
live. A vending machine is the sweet spot. Three reasons: it builds fast — one screen;
it has *real* guard conditions, "enough credit" and "in stock," which is exactly the
three-dimensional State-by-Event-by-Guard input tables were made for; and it maps to
an obvious UI, so when the agent generates it the audience can check the output against
what they already expected. Swap in any small machine — media player, ticket flow — the
structure is identical.

---

## Slide 6 — Step 1: what the domain expert gives you

**On screen:** The brief, in plain English — idle until coins go in; collect a balance; on select, dispense + change / say "short" / say "sold out"; cancel for full refund; after dispensing, return to idle.

**Say:**
On stage this is the first prompt: I paste this paragraph to the assistant and say
"produce a Parnas table — do *not* write Swift yet." Point out to the audience: this is
genuinely all a domain expert needs to say. Everyone in the room understood a vending
machine. The engineering is turning informal English into a complete, disjoint
specification.

> **▶ Paste Prompt 1** (brief → table) — see appendix.

---

## Slide 7 — Step 2: the reviewed spec

**On screen:** The Parnas table (a Mealy machine) — 9 rows, columns: #, State, Event, Guard, New State, Outputs. Rows 5·6·7 share State + Event, split only by guards.

**Say:**
Here is the artifact we co-built. It's a Mealy machine — outputs depend on state *and*
input. Walk the columns: current state, event, guard, new state, outputs. Nine rows.
Draw their eyes to the highlighted rows five, six and seven: same state, same event,
three different outcomes, separated only by the guard. Green — can buy; amber — not
enough money; red — sold out. That guard split is the whole reason we reach for a table.

_Table for reference:_

| # | State | Event | Guard | New State | Outputs |
|---|-------|-------|-------|-----------|---------|
| 1 | Idle | insertCoin(c) | — | Collecting(c) | showBalance |
| 2 | Idle | selectProduct | — | Idle | insufficientFunds |
| 3 | Idle | cancel | — | Idle | — |
| 4 | Collecting(b) | insertCoin(c) | — | Collecting(b+c) | showBalance |
| 5 | Collecting(b) | selectProduct(p) | inStock ∧ b ≥ price | Dispensing | dispense, makeChange |
| 6 | Collecting(b) | selectProduct(p) | inStock ∧ b < price | Collecting(b) | insufficientFunds |
| 7 | Collecting(b) | selectProduct(p) | ¬inStock | Collecting(b) | outOfStock |
| 8 | Collecting(b) | cancel | — | Idle | refund(b) |
| 9 | Dispensing | dispenseComplete | — | Idle | — |

---

## Slide 8 — Step 2a: verify completeness

**On screen:** State × Event matrix — every cell is a decision. Blanks are "ignore"/"no-op" stated out loud; exhaustive switch forces them.

**Say:**
Slow down here — this is the intellectual core. I ask the agent: "is this complete and
disjoint? What's missing?" Completeness means every State-by-Event cell is covered.
Build the matrix. The empty cells — ignore coins while dispensing, dispenseComplete is
a no-op elsewhere — are *decisions* we make explicit, not things we forgot. And because
we'll use an exhaustive switch with no default, the compiler forces us to name every
one. "We forgot a case" becomes impossible.

> **▶ Paste Prompt 2** (verify completeness & disjointness) — see appendix. *This is the essential beat — don't skip it.*

---

## Slide 9 — Step 2b: verify disjointness

**On screen:** Rows 5·6·7 all match (Collecting, selectProduct) — safe only because their guards are mutually exclusive and exhaustive. No gap, no overlap.

**Say:**
Second verification: disjointness. Those three rows overlap on state and event — so
they're only correct if the guards partition the space with no gap and no overlap.
In-stock-and-can-afford, in-stock-but-short, and out-of-stock cover every possibility
exactly once. This is the property a flowchart literally cannot prove, because it
buries the split in nested ifs. The table lets you point at the partition. Callback:
this reviewed table is exactly what becomes the plan artifact in Xcode 27.

---

## Slide 10 — Xcode 27 · agentic coding

**On screen:** The plan is an editable Markdown artifact you approve before any code. Agents take actions · plan = Markdown you edit · diffs are visible · your model + Apple's SwiftUI skills.

**Say:**
Now the tool. Xcode 27's headline is agentic coding — the assistant plans features,
edits across files, runs tests, and drives the simulator. The feature that makes *our*
thesis land: planning is first-class. The agent's plan shows up as an *editable
Markdown artifact* you approve before it writes a line of code. That is our reviewed
Parnas table. You pick the model — Anthropic, OpenAI, Google — and Apple even ships its
own SwiftUI agent skills.

> _Note to self: verify the Xcode 27 feature names against your actual build before the talk._

---

## Slide 11 — The live demo: five prompts, one running app

**On screen:** (1) Brief → table, (2) Verify together, (3) Generate the model, (4) Generate the app, (5) Run it. Stage insurance: a working reference impl is in the repo.

**Say:**
This is the choreography — five prompts. One: paste the brief, get the table. Two, the
highlighted step: verify completeness and disjointness together. Three: generate the
model, one case per row. Four: generate the SwiftUI app around it. Five: run it and
drive the simulator — insert coins, hit the sold-out item, buy something, cancel for a
refund. If any step misbehaves, I have a working reference implementation in the repo
to paste. The point of the talk is the table, not the demo gods.

---

## Slide 12 — Why it holds together

**On screen:** `transition(from:on:stock:)` — one row → one case → the compiler enforces it. No default case · delete a case → won't build · change the table → change one case.

**Say:**
The load-bearing idea. The generated switch has one case per table row and *no*
default. Live demo move: delete a case and watch Xcode refuse to build — the compiler
is now enforcing the table. And when the spec changes, exactly one case changes. Code
and reviewable artifact stay in lockstep. This is why "the agent generated it" is
trustworthy rather than scary: the compiler is checking the agent's work against the
table.

> **▶ Paste Prompt 3** (generate the model) and **Prompt 4** (generate the app) — see appendix.

---

## Slide 13 — The payoff: change a rule, not the code

**On screen:** New requirement — add a 5% convenience fee. Edit the table → rows 5 & 6 guards move → agent updates `transition()` → compiler keeps us honest → app just works.

**Say:**
This is the moment that proves the whole thesis. I give the agent a new requirement — a
five percent convenience fee — and I tell it: update the *table* first, show me the
changed rows, *then* update the code. Watch the chain: I edit the spec, the guard on
rows five and six moves, the agent updates the transition function to match, the
compiler guarantees the switch is still exhaustive, and the app just works. I changed a
rule, not the code. That's the payoff — the table is the source of truth and the fast
path.

> **▶ Paste Prompt 5** (change a rule) — see appendix.

---

## Slide 14 — Takeaways: what to steal for your own work

**On screen:** (1) Spec first, in a table, (2) Make the agent verify, (3) Let the compiler enforce it, (4) Change the rule, not the code.

**Say:**
Four things to take home. One: specify first, in a table — reviewable by
non-programmers, precise enough to generate from. Two: make the agent verify
completeness and disjointness — that's where it adds the most value, not just typing
code. Three: let the compiler enforce it with an exhaustive, default-free switch. Four:
when requirements change, change the rule, not the code. That's the entire method in
four lines.

---

## Slide 15 — The bigger picture: why this is the fast path

**On screen:** Four cards — (1) Loop "engineering" is so last week · (2) Fewer tokens, not more (planet + 💰) · (3) Flixel Flipside, built in 2 weeks · (4) Xcode 27 supercharges it.

**Say:**
One more beat before we close — the bigger picture. First: loop "engineering" is
already last week. The win isn't making the agent grind harder in a retry loop; it's a
reviewed spec that's correct by construction. Second: this *minimizes* token use instead
of maximizing it — a tight table constrains the agent, so less back-and-forth and less
waste. Better for the planet and the budget. Third, proof it's real: we built Flixel
Flipside with exactly these methods in two weeks. Fourth: Xcode 27's agentic coding
supercharges all of it — the reviewed spec becomes a first-class, editable plan. That's
the payoff: spec-first isn't just cleaner, it's cheaper, faster, and already shipping.

---

## Slide 16 — Close

**On screen:** Tables in. Verified specs out. Apps that match, by construction. Consulting & training · mhp@flixel.com.

**Say:**
To close: tables in, verified specs out, and apps that match by construction. If your
team wants to apply Parnas tables and formal methods for real, I do consulting and
training — mhp@flixel.com. Thanks, tacow. Questions?

---

## Appendix — the five live-demo prompts

Exact text to paste into the coding assistant, in order. Full beat-by-beat staging,
timings, and fallbacks are in [`Xcode27-Script.md`](Xcode27-Script.md).

### Prompt 1 — Brief → table (Slide 6)
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

### Prompt 2 — Verify completeness & disjointness (Slide 8) ⭐
```
Now verify this table like a formal spec:

1. Completeness: build a State × Event matrix. Every cell must be covered. For any
   (state, event) pair with no meaningful transition, make the "ignore it / no-op"
   decision explicit rather than leaving it blank.
2. Disjointness: the (Collecting, selectProduct) rows overlap on state+event — show
   that their guards partition the space with no gap and no overlap.

List anything missing or ambiguous, then give me the corrected table.
```

### Prompt 3 — Generate the model (Slide 12)
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

### Prompt 4 — Generate the app (Slide 12)
```
Build a single-screen SwiftUI app that drives this machine. Rules:
- The view sends events only; the sole state mutation goes through transition(...).
- Show current state + a display message derived from the Outputs.
- Coin buttons (5¢/10¢/25¢/$1/$2), a product grid with prices and a sold-out state,
  and a Cancel/Refund button.
- Use @Observable for the view model. Dispensing auto-completes after ~1s.
Then run it in the simulator.
```

### Prompt 5 — Change a rule (Slide 13)
```
New requirement: the machine should also charge a 5% "convenience fee" — a product
is only dispensable if balance >= price * 1.05, and change is computed against that
total. Update the Parnas table FIRST (show me the changed rows 5 and 6), then update
transition(...) to match, then rebuild.
```

---

### Quick self-check before you walk on
- Beats **2** (verify) and **5** (change a rule) are the essential ones — if you run long, protect these.
- Simulator pre-booted; reference files (`Demo/Reference/*.swift`) open in a hidden tab as the answer key.
- Network tested, hotspot as backup.
