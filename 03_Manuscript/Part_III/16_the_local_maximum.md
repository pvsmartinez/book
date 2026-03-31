## Chapter 16: The Local Maximum

Systems do not optimize for the best outcome. They optimize for the most stable one. And those two things are rarely the same.

---

Take the Hawks and Doves scenario. A population competing for food. Two strategies: fight for every resource (Hawk), or display and retreat if challenged (Dove).

Let's give it numbers. Food is worth **+50 points**. A serious injury costs **-100 points**. Doves who meet each other share peacefully: **+25 each**.

**Meets HawkMeets DovePlaying Hawk**Fight: win or lose. Average: **-25**Victory, no contest: **+50Playing Dove**Retreat, no injury: **0**Share: **+25**

Hawk vs. Hawk: fight, win or lose, average **-25**. Hawk vs. Dove: take the resource unopposed, **+50**. Dove vs. Hawk: retreat uninjured, **0**. Dove vs. Dove: share peacefully, **+25** each.

Is there one strategy that always wins? Against pure Doves, Hawk wins (+50 beats +25). Against pure Hawks, Dove wins (0 beats -25). The best move depends entirely on what everyone else is doing.

No single dominant strategy. When the population is mostly Doves, Hawks walk in and take +50 while everyone else averages +25. So Hawks spread. As they multiply, they meet each other constantly, averaging -25. Doves, who score 0 against Hawks but +25 against other Doves, start doing better in relative terms. The two strategies find a balance.

This balance is called a **Nash Equilibrium**: the point where no individual player has an incentive to switch strategies, given what everyone else is doing.

You can actually calculate where that balance lands. Let *p* be the fraction of Hawks in the population. A Hawk's average score is: *p × (−25) + (1−p) × (+50)*. A Dove's average score is: *p × (0) + (1−p) × (+25)*. At equilibrium, both strategies must pay equally; one would take over. Set them equal and solve: −25p + 50(1−p) = 25(1−p). This gives *p = 5/8*, or about **58% Hawks, 42% Doves**.

Notice what that number is not. If everyone were a Dove, every interaction scores +25 for both players. But that world cannot hold: the moment Doves dominate, being a Hawk becomes the most profitable move. The equilibrium is not the best outcome for the group. It is simply the point where no individual has a reason to defect.

Mathematicians call this a **local maximum**. Higher than everything immediately around it, but not the highest place in the landscape. Every individual step looks rational. The collective destination was never chosen.

Now change one variable: move the population from a forest to a desert. Food is scarce. The same meal is now worth **+500 points**. Injury is still -100.

**Meets HawkMeets DovePlaying Hawk**Fight: average **(+500 − 100) / 2 = +200**Victory: **+500Playing Dove**Retreat: **0**Share: **+250**

Run the same calculation. Let *p* be the fraction of Hawks. A Hawk's average score: *p × (+200) + (1−p) × (+500)*. A Dove's average score: *p × (0) + (1−p) × (+250)*. Set them equal and solve: 200p + 500 − 500p = 250 − 250p. This gives −50p = −250, or p = 5. That is not a valid probability. There is no equilibrium. Hawk is the dominant strategy in every scenario, regardless of what anyone else does.

The population does not stabilize at 58% Hawks. It collapses to 100%.

The animals did not decide to become violent. One number shifted. The system followed the math.

---

Imagine two suspects are arrested and separated. Each faces the same choice:

- If **both stay silent**: 1 year each.
- If **both betray**: 5 years each.
- If **one betrays and the other stays silent**, the betrayer goes free, and the silent one gets 10 years.

**Partner stays silentPartner betraysYou stay silent**1 year10 years**You betray**Go free5 years

The math is unambiguous. If your partner stays silent, betray: free beats 1 year. If your partner betrays, betray: 5 years beats 10. Betrayal is the dominant strategy regardless. Both prisoners reason the same way. Both betray. Both get 5 years.

The better outcome was right there: both silent, 1 year each. Total cost: 2 years. Total cost at the Nash Equilibrium: 10 years — five times worse. And mathematically unavoidable, because anyone who unilaterally chose silence would get 10 years while the other walked free.

This is the **Prisoner's Dilemma**: not a failure of intelligence or goodwill, but a structure where the individually rational move produces the collectively worst result. Arms races, overfished oceans, price wars. Every country would prefer hospitals over weapons. Every company would prefer a world without a race to the bottom. The logic is always the same: the individually rational move makes collective sense impossible.

The system does not care about intentions. It selects for what is individually stable. The local maximum is not a bug. It is the destination the math was always pointing toward.

If the problem lies in the payoff matrix, improving the outcome does not require changing human nature. It requires changing the numbers. Which means changing the game.