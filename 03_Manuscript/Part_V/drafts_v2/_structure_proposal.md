# Part V: Proposed Restructure (v2)

**Date:** 2026-02-14  
**Status:** Draft for review

---

## Current Structure (8 files)

| # | File | Title | Verdict |
|---|------|-------|---------|
| 28 | 28_the_shift.md | The Shift | **Keep as-is** |
| 29 | 29_the_hydra.md | The Hydra | **Keep as-is** |
| 30 | 30_mapping_the_machine.md | Mapping the Machine | **Replace** (merged into new 30) |
| 31 | 31_the_game_designer_toolkit.md | The Designer's Toolkit | **Replace** (merged into new 30) |
| 32 | 32_debugging_the_world.md | Debugging the World | **Replace** (rewritten as new 32) |
| 33 | 33_patching_the_code.md | Patching the Code | **Keep** (minor additions later) |
| 34 | 34_the_gardener.md | The Gardener | **Keep** (add real-world example later) |
| 34b | 34b_the_architects_workshop.md | The Architect's Workshop (Interlude) | **Promote to regular chapter** |

---

## Proposed New Structure (7 chapters, no interludes)

| # | New File | Title | Source | What Changed |
|---|----------|-------|--------|-------------|
| 28 | 28_the_shift.md | The Shift | Current 28 | Unchanged |
| 29 | 29_the_hydra.md | The Hydra | Current 29 | Unchanged |
| 30 | **30_the_designers_toolkit.md** | The Designer's Toolkit | **NEW v2** (merged 30 + 31) | Opens with "Design for Diversity, Not Dominance." RPS dynamics as the spine (game balance → Yellowstone wolves → democracy's separation of powers → Venice). Luck Dial, Faucets/Sinks (with Whale Economy + credential inflation callbacks), Incentive Framing (WoW Rested XP), Leverage tiers. Meadows = one attribution paragraph. See `drafts_v2/30_the_designers_toolkit.md` |
| 31 | **31_debugging_the_world.md** | Debugging the World | **NEW v2** (rewritten 32) | Reframed as "reverse-engineering the Value Function." Three-step protocol maps to Rules × Track × Competitors. Game design "reading the Meta" framing. Callbacks: Salesman, Exam Trap, YouTube algorithm, Red Queen, Whale Economy, Venice. Full worked example: Mobile Gaming Trap. See `drafts_v2/32_debugging_the_world.md` |
| 32 | 32_patching_the_code.md | Patching the Code | Current 33 | Keep. Later: add Lock-in Breaker (switching cost math) and possibly ETF feedback loop case study. |
| 33 | 33_the_gardener.md | The Gardener | Current 34 | Keep. Later: add one sharp real-world "gardener in action" example to give it weight. |
| 34 | **34_the_architects_workshop.md** | The Architect's Workshop | Current 34b | **Promoted from Interlude to regular chapter.** No content change needed — it already reads like a full chapter. Just remove the "Interlude:" prefix from the title and renumber. |

---

## Key Changes Explained

### 1. Merge: Mapping the Machine + The Designer's Toolkit → new Ch 30
**Problem:** Ch 30 was a Donella Meadows tutorial in someone else's vocabulary. Ch 31 was a listicle of game design tricks.  
**Solution:** One chapter that presents the tools *in Pattern language*: Faucets/Sinks, Incentive Framing, the Luck Dial (new), Rock-Paper-Scissors dynamics (new), Core Loop, Balance Patching, and Leverage Points (reframed as where the Filter is sensitive).  
**What was kept:** The elephant parable (opens the chapter). The WoW Rested XP example. Meadows gets attribution in one paragraph.  
**What was added:** Luck as a Design Lever (from seed). RPS dynamics as a tool for checks and balances (democracy/Pokémon/ecosystem examples). Explicit mapping of every tool back to Pattern vocabulary.  
**What was cut:** The full bathtub tutorial. The Work-Life Trap system map (readers already know reinforcing/balancing loops from Part IV). The Mermaid diagram.

### 2. Rewrite: Debugging the World → new Ch 31
**Problem:** Old Ch 32 was redundant with Ch 28 (Designer's Framework) and Ch 29 (Tylenol/Antibiotics). It re-taught "the symptom is a lie" and restated the diagnostic questions.  
**Solution:** Reframe as "reverse-engineering the Value Function." In Part III, you learned to READ the VF. Now you work BACKWARDS: see the outputs, trace them to which variable (Rules, Track, or Competitors) is dominant, then check if the bug is compounding.  
**What was kept:** Soviet Nail Factory (best example in the chapter). "The system is never crazy." The doctor/morphine analogy (trimmed to one paragraph).  
**What was added:** The three-step protocol tied explicitly to VF variables. The toxic meeting as a full worked example using the protocol. Explicit callbacks to Part III chapters.  
**What was cut:** The full "Symptom is a Lie" re-teach (now a one-line callback). The generic diagnosis questions (replaced by the VF-specific protocol).

### 3. Promote: The Architect's Workshop → regular Ch 34
**Problem:** All interludes are being removed from the book. But 34b is one of the strongest chapters in Part V — the three levels of agency (Personal Patch, Local Debugger, Design Proposal) and the cascade example (road narrowing → fewer accidents → lower insurance → higher property values).  
**Solution:** Simply promote to a regular chapter. Rename from "Interlude: The Architect's Workshop" to "Chapter 34: The Architect's Workshop." The content already reads as a full chapter; no structural changes needed.  
**Possible title alternatives:** "The Local Architect," "Start Where You Are," "The Ten Square Meters."  
**Note:** The closing line ("Now, it's time to move to Part VI") already works as a Part V closer.

---

## Net Effect
- Part V goes from **8 files** to **7 chapters** (no interludes)
- Loses ~3,000 words of redundancy (Meadows tutorial, re-taught concepts)
- Gains ~2,000 words of new material (Luck Dial, RPS dynamics, VF reverse-engineering protocol)
- Every chapter now uses Pattern vocabulary consistently
- Architect's Workshop gets the visibility it deserves as a full chapter

---

## Still To Do (Later Passes)
- [ ] Add the **Lock-in Breaker** (switching cost vs recurring tax) to Patching the Code
- [ ] Add the **ETF Feedback Loop** case study to Patching the Code (emergent failure from simple rule)
- [ ] Add one **real-world gardener example** to The Gardener (not metaphorical tomatoes)
- [ ] Review chapter numbering against full book (Part VI chapters will shift)
- [ ] Update `02_Structure/master_outline.md` and `concepts_per_chapter.md` once structure is confirmed
