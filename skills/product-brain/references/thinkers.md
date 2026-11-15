# Thinking lenses: Doshi, Verna, Sutherland and behavioural psychology

**As of:** 2026-10-29. Ideas are paraphrased from the thinkers' public writing, talks and podcasts, not quoted. Use them as lenses: bring one in when it changes the answer. Every lens below ends with "Applied to Sonar" because a framework only earns its place if it moves a SonarQube decision.

More thinkers (Dunford, Moesta/JTBD, Poyar, Balfour/Winters, Orosz, Kahneman/Thaler, Forsgren/Noda, Sierra, Torres, Fogg, Majors, Willison) are in `thinkers-extra.md`.

## Contents
1. Shreyas Doshi: PM craft, leverage, pre-mortems, product sense
2. Elena Verna: product-led growth, activation, reverse trials, monetisation
3. Rory Sutherland: psycho-logic, perception, the value of the counterintuitive
4. Behavioural psychology toolkit for flows
5. Lens picker: which lens for which question

---

## 1. Shreyas Doshi

Ex-Stripe, Twitter, Google, Yahoo PM leader; known for compact frameworks on PM judgement.

### Core ideas
- **Impact, Execution, Optics (three levels of product work).** Discussions go wrong when people argue at different levels. One person argues impact ("will this move retention?") while another argues execution ("can we build it by December?") or optics ("will leadership like it?"). Name the level before debating.
- **LNO: Leverage, Neutral, Overhead.** A few tasks give 10x returns (Leverage), so do them superbly. Most are Neutral, and the rest are Overhead, so do those "good enough". Applied to features: which part of this flow is the leverage moment, the one screen that decides whether the user stays? Polish that and keep the rest boring.
- **Pre-mortem: tigers, paper tigers, elephants.** Imagine the launch failed. *Tigers* are real threats that will kill it. *Paper tigers* are concerns that look scary but you don't believe in. *Elephants* are the things nobody is saying out loud. Classify every concern and act only on tigers and elephants.
- **Opportunity cost over ROI.** "Is this a good idea?" is the wrong question, because most ideas have positive ROI. Ask whether it is the best use of this team's next six weeks compared with the alternatives.
- **Most execution problems are strategy problems.** When a team keeps "failing to execute", look upstream for unclear goals, too many priorities or a wrong theory of the user.
- **Product sense** is built from customer empathy, the ability to *simulate* how a person will experience something before it exists, domain knowledge, taste and creative problem-solving. Simulation is the trainable part, and it is exactly what the step-by-step walk-through exercises.
- **Problem before solution; the customer doesn't care about your org chart.** Flows that mirror internal team boundaries (billing squad screen, then onboarding squad screen, then the Gitar screen) feel broken to users. SonarOne exists because of this.
- **High-agency and second-order thinking.** Ask "and then what?" twice. What does this flow cause next week, at renewal, for the second user?
- **Differentiators vs table stakes.** Over-investing in parity features doesn't win. Under-investing in table stakes loses deals. Know which one a feature is before debating its polish.

### Applied to Sonar
- When a flow debate stalls, ask: "Are we arguing impact, execution or optics?" Example: arguing whether the Gitar discovery banner should appear at login (impact) versus whether Billing can provision a trial (execution).
- Run the pre-mortem on anything going into the 15 Dec scope. A likely elephant: "the admin who sees the AI review discovery cannot actually start a trial without Deal Desk".
- LNO for onboarding v3: the leverage step is getting someone's code scanning in the first session. Most settings screens are overhead, so move them out, which the v3 cuts already do.
- Opportunity cost: every Growth idea competes with fixing known setup friction, which is the root cause of SQS churn. Ask whether the idea beats that.

---

## 2. Elena Verna

Growth advisor and operator (Miro, SurveyMonkey, Amplitude; interim roles at Dropbox and others; head of growth at Lovable since 2025). She popularised the "reverse trial" and is a leading voice on B2B product-led growth. The team's Reforge PLG notes (`notes/reforge-plg-elena-verna/`) apply her frameworks to Sonar. Read those for Sonar-specific worked examples.

### Core ideas
- **Growth loops, not funnels.** Funnels leak and need constant new input. Loops compound: output of one cycle (a public PR comment, an invited teammate, a shared report) becomes input to the next. Ask what the loop is and where it closes.
- **Activation is the highest-leverage metric, and it has stages: setup, aha, habit.** *Setup*: the user has done the work to be able to get value. *Aha*: the user experiences the core value. *Habit*: the user repeats it. In B2B, measure activation at the **account/team** level, not just the user.
- **Retention before acquisition.** Pouring users into a leaky product wastes acquisition and poisons word of mouth. Sonar learned this when "send all leads online" in late 2025 raised signups but not revenue.
- **Reverse trial.** Start new users on the full paid experience for a limited time, then drop them to free (or ask them to pay) at the end. It uses loss aversion and the endowment effect, because people value what they already have. It also shows the paid value before asking for money. The design risk is the end-of-trial moment: if it feels like punishment, or users don't understand what they are losing, the trial backfires. Verna's model drops users to *free* by default; Sonar's current design **suspends** on day 15, which is a meaningful deviation worth stress-testing.
- **Free is a marketing channel, not a charity.** The free tier exists to acquire and activate. Gate on value that scales with team use (collaboration, admin, governance, scale), not on core value the individual needs before they can see why to pay.
- **Users are not buyers.** In B2B PLG the person who gets value (developer) is often not the person who pays (EM, CISO). Design for the user's value and give the buyer the evidence: a report, a usage view, an ROI story.
- **Product-led sales (PLS).** Product usage creates the qualified signal (a PQA, product-qualified account) and sales helps the account expand. Humans are for high-value friction, not for every signup.
- **Monetisation escalator.** Map how a customer moves up: free, then individual paid, then team, then enterprise. Each step needs a natural trigger in the product, such as a limit hit, a second team or a governance need.
- **Experimentation discipline in B2B.** B2B volumes are small, so many tests can't reach significance. Prefer bigger swings, guardrail metrics and clear kill rules over many micro-tests.
- **Multiplayer.** B2B products retain when more than one person depends on them. Single-player usage is a churn predictor.

### Applied to Sonar
- The team's activation model (setup = DevOps connected and their code scanning; aha = someone understood a finding on a change they care about; habit = the quality gate or findings acted on repeatedly in the PR loop, by more than the admin) is Verna's model applied. Use it to judge any onboarding flow.
- **Loop candidates at Sonar:** the PR comment seen by a reviewer, who becomes a user. The quality gate badge in a README. The IDE extension in connected mode. MCP or agent usage that pulls in Sonar inside Cursor or Claude Code. Ask whether a flow strengthens one of these.
- Reverse trial: the open question isn't only conversion. It is also the day-15 moment (suspend vs Free) and whether a CI or SCA setup can show value within 14 days.
- Single-player orgs churn at 43–50%, so any flow that ends with one person should have a deliberate second-person moment.
- Users vs buyers: a developer gets value from a fix in their PR, while the EM needs "my team shipped X fewer issues". Flows for the admin and for the developer should differ (the 15 Dec Gitar scope already splits them).

---

## 3. Rory Sutherland

Vice chairman of Ogilvy UK; author of *Alchemy: The Surprising Power of Ideas That Don't Make Sense* (2019). He argues that human decisions run on "psycho-logic", not logic, and that the biggest gains often come from changing perception rather than reality.

### Core ideas
- **Psycho-logic.** People don't optimise; they satisfice, avoid anxiety, follow signals and use context. A solution can be illogical and still work, because what matters is how it feels.
- **Change the perception, not the mechanics.** His Eurostar example: instead of spending billions to make the train faster, make the journey so pleasant that people want it longer. His Uber map example: the dot moving on the map doesn't make the car arrive sooner, but it removes the *uncertainty* of waiting, which is what people hate.
- **Reduce anxiety before adding value.** Many abandoned flows are abandoned out of fear: of being charged, of breaking something, of looking stupid, of committing. Remove the fear and conversion rises without adding a single feature.
- **Costly signalling.** People trust what looks effortful or expensive to produce. A personal message, a thoughtful default or a high-quality first result signals "this is serious, it's for you".
- **The opposite of a good idea can also be a good idea.** In psychology, unlike physics, opposite strategies can both work, so test the counterintuitive. Competitors test the obvious, and the odd ideas are uncontested.
- **Don't design only for the average.** Averages hide the people at the extremes, who often reveal what matters.
- **The doorman fallacy.** Cutting something because it looks inefficient (the doorman "only opens doors") destroys value nobody measured (security, status, welcome). Watch for "simplifications" that remove a reassurance.
- **Small things are not trivial.** Tiny details (a word, a default, the order of options) can have outsized effects, because they carry meaning.
- **Context and framing create value.** The same thing has different value depending on how it's framed, what it's compared with and who offers it.

### Applied to Sonar
- **Waiting for the first scan:** the CI setup or first analysis takes time. Sutherland's question is how to remove the uncertainty during the wait ("Analysing 12,400 lines, usually 3 minutes, we'll email you"), not only how to make it faster.
- **Trial end:** the day-15 moment is pure anxiety: will I be charged, will my scans stop, will I lose my data? Address each fear explicitly. The Stripe email implying a ~$2,000 charge is the anti-example.
- **The first results dump:** 300 issues reads as "your code is bad and this tool will nag you". Reframing ("3 issues in code you changed this week; your older code is a separate backlog") changes the perception of the same data. This is also the core idea behind Clean as You Code and new-code focus.
- **Permission dead ends:** a member who can't create a project feels stupid. Reframe it as "Ask your org owner (Name) to add this repo" with one click, which turns a blocker into a social action that also brings in a second person.
- **Counterintuitive tests worth considering:** a deliberately *smaller* first scan (one repo, not bulk import), showing what Sonar *didn't* flag (noise avoided) to build trust, or making the free tier feel *more* exclusive rather than more generous.
- **Costly signals for enterprise:** a named onboarding contact, a tailored setup checklist, a CISO-ready report. These matter more to an enterprise buyer than another feature.

---

## 4. Behavioural psychology toolkit for flows

Use these to diagnose why a step leaks or to design a better one. Each item names the effect, gives the design implication, and then a Sonar example.

| Effect | Design implication | Sonar example |
|---|---|---|
| **Loss aversion** (losses weigh ~2x gains; Kahneman & Tversky) | Frame what they keep or lose, not what they gain | Reverse trial end: "Keep PR checks on your 4 repos" beats "Upgrade to Team" |
| **Endowment effect** | People value what they already hold | Let trial users configure gates, invite teammates and connect repos, so there is something to lose |
| **Default effect / status quo bias** | Most people keep the default, so defaults are decisions | Which plan is pre-selected? Is Advanced Security default-on (29 removed vs 3 added it in the funnel spec)? |
| **Choice overload** | More options mean fewer decisions | The plan picker at signup lost 94% of the GitHub path (6% went from choosing their DevOps platform to choosing Team) |
| **Goal gradient** | Effort increases as the goal nears; show progress | Setup checklist: "2 of 3 done, your first PR check is next" |
| **Zeigarnik effect** | Unfinished tasks stay on the mind | A visible, resumable setup state pulls people back |
| **Peak-end rule** | Experiences are judged by their peak and their end | Make the first finding a "peak" (a real bug caught), and make the trial end a good ending even if they don't pay |
| **IKEA effect** | People value what they helped build | A custom quality gate or profile increases attachment, so expose light customisation early |
| **Ambiguity aversion** | People avoid unknown outcomes more than known bad ones | Spell out what happens on day 15, what is charged, and what stops working |
| **Social proof** | People follow similar others | "Teams your size usually start with 3 repos" |
| **Commitment and consistency** | Small yeses lead to bigger ones | Start with one repo, then expand; don't ask for org-wide binding as the first step if it can wait (binding is permanent, though, so be honest about it) |
| **Hassle factors / friction** (Thaler, Sunstein) | Tiny frictions cause large drop-offs | Card form errors, a required work email, a CI YAML step |
| **Present bias** | Immediate costs outweigh future benefits | Setup effort now for value later explains why AutoScan converts and CI stalls |
| **Fresh start effect** | New periods trigger new behaviour | Sprint starts, new quarter, CRA deadlines and audits are moments to prompt action |
| **Fogg B = MAP** (behaviour = motivation x ability x prompt) | If a behaviour doesn't happen, one of the three is missing | A weekend explorer has the motivation but lacks the ability (CI). A mandated developer has the ability but lacks the motivation. Fix the missing one |

**Trust in developer tools (specific to this audience).** Developers are sceptical, allergic to marketing copy, and quick to label a tool "noisy". Trust comes from:
- precision over volume (few false positives)
- explanations of *why* an issue matters
- respect for their workflow (PR and IDE, not another dashboard)
- honesty about limits
- never acting on their code without consent; Goldman rejected AI changing their pipelines

In 2026 developers trust AI output only when it is easy to verify (market.md §1.4). Sonar's role as the deterministic verification layer *is* the trust story.

---

## 5. Lens picker

| Question you're facing | Reach for |
|---|---|
| "Is this even the right thing to build?" | Doshi: opportunity cost, impact level, the strategy behind the execution problem |
| "Will this launch go well?" | Doshi pre-mortem |
| "Why don't people activate or convert?" | Verna activation stages + Fogg B=MAP |
| "How should the trial, free tier or upgrade work?" | Verna reverse trial, free as a channel, escalator + loss aversion/endowment |
| "Why do people drop off at this screen?" | Sutherland anxiety + hassle factors + choice overload |
| "How do we make it feel better without building more?" | Sutherland perception over mechanics |
| "How do we get the second user or the team in?" | Verna multiplayer and loops + social proof |
| "How do we position against GitHub or Snyk?" | Dunford positioning (`thinkers-extra.md`) + market.md battlecard guidance |
| "What job are they hiring us for?" | Moesta/JTBD (`thinkers-extra.md`) + `users-and-findings.md` §2.6 |
| "How do we price AI features?" | Poyar (`thinkers-extra.md`) + market.md §2.4 |
