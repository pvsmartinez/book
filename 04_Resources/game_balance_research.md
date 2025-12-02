# Research: Game Balance & System Design Case Studies

**Purpose:** Collect real-world examples from game design to illustrate the "System Designer Mindset" in the Solutions chapter.

---

## ⭐ BEST EXAMPLES FOR THE BOOK

### 🏆 FRANCHISE REDEMPTION: Final Fantasy XIV (A Realm Reborn)
**The Ultimate "System Redesign" Story**

**The Failure (1.0 - 2010):**
- Original FFXIV launched September 2010 to devastating reviews (Metacritic: 49/100)
- GameTrailers: "Released before it was finished... a broken, incomplete mess"
- PC Gamer: "A shallow, slow, grind-heavy MMO crippled by a horrible interface"
- Square Enix CEO Yoichi Wada: The launch had "greatly damaged" the Final Fantasy brand
- Company slashed yearly net profit forecast by **90%**

**What Went Wrong (Root Causes):**
1. **Obsession with graphics over gameplay** - A flowerpot had as many polygons as a player character
2. **No knowledge of modern MMOs** - Team was instructed to make something "different from FFXI" but never played WoW
3. **Belief they could patch problems post-launch** - No overall plan for fixes
4. **Broken engine** - Crystal Tools was optimized for single-player games, not MMOs

**The System Redesign:**
- December 2010: Original producer/director removed. Naoki Yoshida brought in
- Yoshida's first diagnosis: The game couldn't be fixed - it had to be **rebuilt from scratch**
- Key innovation: **"Letters from the Producer"** - radical transparency with players to restore trust
- Made ~400 fundamental design decisions upfront to eliminate approval bottlenecks
- Yoshida told his team: "Go play World of Warcraft for a year [for inspiration]"

**The Result (A Realm Reborn - 2013):**
- Metacritic: 83/100 (PC), 86/100 (PS4)
- Polygon: 9/10 - "The first Final Fantasy game in years to capture the energy and joy that made me fall in love with the series"
- Square Enix credited FFXIV:ARR for returning the company to profitability in 2014
- By 2021: 24+ million registered players

**Key Quote (Yoshida at GDC 2014):**
>"Sales were secondary to restoring player trust."

**🔑 Book Lesson:** You can't nerf your way out of a fundamentally broken system. Sometimes you have to rebuild from scratch - but do it transparently, with the users.

---

### 💸 ECONOMY FAILURE: Diablo III Real-Money Auction House
**When the Value Function Destroys the Game**

**The System:**
- Diablo III (2012) launched with Real-Money Auction House (RMAH)
- Players could buy/sell in-game items for real currency
- Blizzard took a cut of every transaction

**The Problem:**
- The RMAH became the optimal strategy - why grind for loot when you can buy it?
- Game's core loop (kill monsters → get cool loot) was broken
- Players no longer felt rewarded for playing
- Violated Korean anti-gambling laws, leading to restrictions

**Developer Admission:**
- March 2013: Jay Wilson (game director) admitted the auction house "**really hurt**" the game

**The System Redesign:**
- Both auction houses (gold and real-money) **shut down March 2014**
- Loot system completely reworked ("Loot 2.0")
- Smart loot: Items now drop appropriate to your class
- Removed trade entirely - items now "bind on account"

**🔑 Book Lesson:** When you introduce a system that rewards players for *not playing*, you've poisoned your own value function. Sometimes the fix is complete removal.

---

### 🏙️ MARKET VACUUM: SimCity (2013) → Cities: Skylines
**How One Company's Failure Created a Competitor's Opportunity**

**SimCity 2013 - The Failure:**
- Always-online DRM requirement
- Launch day: Servers overwhelmed, many players couldn't play at all
- Polygon dropped review score from 9.5 to **4.0** post-launch
- Generated a White House petition for refunds
- Lead to Maxis Emeryville studio **shutdown in 2015**

**Cities: Skylines - The System Designer's Response:**
- Paradox Interactive greenlit development "**after what happened to SimCity**"
- Built by 13-person studio (Colossal Order)
- Key design decisions:
  - **No always-online** - single-player focus
  - **Built-in modding support** - explicit design goal
  - Let community extend the game instead of fighting them

**The Result:**
- 250,000 copies sold in first 24 hours
- 12+ million copies by June 2022
- Critics: "Superseded SimCity as the leading game of the genre"

**🔑 Book Lesson:** When a market leader redesigns their system poorly, they create a vacuum. Someone else will fill it - usually by doing the opposite of what went wrong.

---

### 📱 MOBILE SUCCESS: Candy Crush Saga
**The 97.7% Free Model**

**The System:**
- **97.7% of players play for free** - only 2.3% pay anything
- Started with only 65 levels, expanded via "saga" episodes
- Lives system creates natural play sessions (can't binge forever)
- Boosters available for purchase but never required

**Why It Works:**
- The game is genuinely playable (and beatable) for free
- Paying accelerates but doesn't replace gameplay
- New content (levels) delivered continuously - the "game as service" done right
- Social pressure is subtle (see friends' progress) not aggressive

**Contrast with Predatory Mobile Games:**
- No "pay to win" - paying doesn't give you advantages over other players
- No artificial walls - you can progress without paying, just slower
- No gacha/loot boxes - purchases are transparent

**🔑 Book Lesson:** Freemium works when paying enhances the experience rather than removing artificial frustrations. Candy Crush respects the 97.7% who never pay.

---

### 📱 LIVE SERVICE: Clash Royale
**Continuous Iteration in Mobile Gaming**

**The System:**
- Hybrid of CCG (collectible card game) + MOBA + Tower Defense
- Real-time competitive multiplayer on mobile
- Regular balance patches to adjust card strength

**Evolution Through Iteration:**
- 2016: Launch with core 1v1 mode
- Added: 2v2 mode, Clan Wars, Clan Wars 2, special events
- July 2025: Added "Merge Tactics" mode - completely new gameplay style
- Constant balance updates based on win rate data

**Key Insight:**
- Game doesn't try to get the design "right" upfront
- Treats itself as a living system that evolves with player behavior
- New modes attract different player types without removing old ones

**🔑 Book Lesson:** Live service done right means continuous iteration based on data, not feature bloat. Add modes, don't just add complexity.

---

## Categories of Examples (Additional Research)

### 1. Failed Nerfs (Treating Symptoms, Not Causes)
*   **Pattern:** Devs repeatedly reduce a character's stats, but the meta doesn't change.
*   **Examples to Find:**
    *   *League of Legends:* Champions that were nerfed many patches in a row but stayed dominant (e.g., early Kassadin, Ryze reworks).
    *   *Overwatch:* Mercy's rework saga (multiple nerfs to resurrect ability).
    *   *Fighting Games:* Characters that dominated tournaments despite constant tweaks.

### 2. Successful Reworks (Changing the System)
*   **Pattern:** Devs change a core mechanic or add a counter-system, and the problem resolves itself.
*   **Examples to Find:**
    *   *Fortnite:* Building nerfs vs. the addition of "no-build" mode.
    *   *World of Warcraft:* How they handled the "Corrupted Blood" plague (accidental, but a case study in system failure).
    *   *Dota 2:* Icefrog's philosophy of buffing counters instead of nerfing.

### 3. Toxicity & Social Systems
*   **Pattern:** Punishing toxic players (bans) vs. incentivizing positive behavior.
*   **Examples to Find:**
    *   *League of Legends:* The Honor System (did it work?).
    *   *Overwatch:* Endorsement system.
    *   *Counter-Strike:* Trust Factor / Prime matchmaking.

---

## Key Patterns Emerging

### Pattern 1: "You Can't Nerf Your Way Out"
When the fundamental system is broken, incremental fixes don't work. Examples:
- FFXIV 1.0 → Complete rebuild
- D3 RMAH → Complete removal
- SimCity DRM → Competitor exploited the vacuum

### Pattern 2: "Redesign the Rules, Not the Players"
Instead of punishing undesired behavior, change the incentives. Examples:
- D3: Remove RMAH, add smart loot (make grinding rewarding again)
- Cities Skylines: Add modding support (let players extend, not exploit)
- Clash Royale: Add new modes (redirect players instead of restricting them)

### Pattern 3: "Transparency Builds Trust"
When you screw up, radical honesty + visible action works better than silence. Examples:
- Yoshida's "Letters from the Producer"
- Jay Wilson admitting RMAH "really hurt" the game

### Pattern 4: "The 97.7% Rule"
In F2P, the vast majority will never pay. The game must be good for them too. Examples:
- Candy Crush's non-predatory model
- Contrast: Games that wall content behind paywalls fail

---

## Quotes for the Book

**Yoshida (FFXIV):**
>"I needed to restore trust in the player base while bringing the game up to a playable quality."

**Yoshida (on what the original team should have done):**
>"Go play World of Warcraft for a year [for inspiration]."

**Jay Wilson (D3):**
>"The existence of the auction houses really hurt the game."

**Square Enix CEO Wada (on FFXIV 1.0):**
>"The Final Fantasy brand has been greatly damaged."

**Polygon on Cities: Skylines vs SimCity:**
>"[Cities: Skylines] superseded SimCity as the leading game of the genre."

**Paradox on why they greenlit Cities: Skylines:**
>"After what happened to SimCity..."
