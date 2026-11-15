# Extra thinkers and sources for Sonar Growth brainstorming

**As of: 2026-10-29.** Companion to `market.md`. Assumes Shreyas Doshi, Elena Verna and Rory Sutherland are already loaded elsewhere; this file does not repeat them.

Selection rule: a thinker earns a place only if at least two of their ideas change a concrete Sonar Growth decision (activation, first-year churn, pricing, distribution via agents, developer trust). 12 picks: 6 for the dev-tools market, 6 for understanding developer users. Dropped: Nir Eyal (habit loops overlap with Fogg and fit consumer apps better than dev tools), Des Traynor (useful, but his scope and "jobs" material is covered by Moesta and Dunford), Lenny Rachitsky (an aggregator; use his newsletter as a source, listed at the end).

## Contents

- [A. Dev-tools market, positioning, pricing, growth](#a-dev-tools-market-positioning-pricing-growth)
  1. April Dunford
  2. Bob Moesta / Clayton Christensen
  3. Kyle Poyar
  4. Brian Balfour and Casey Winters
  5. Gergely Orosz
  6. Kahneman / Thaler
- [B. Understanding developer users](#b-understanding-developer-users)
  7. Nicole Forsgren and Abi Noda
  8. Kathy Sierra
  9. Teresa Torres
  10. BJ Fogg
  11. Charity Majors
  12. Simon Willison
- [Quick-use matrix](#quick-use-matrix)
- [Sources to follow](#sources-to-follow)

---

## A. Dev-tools market, positioning, pricing, growth

### 1. April Dunford: positioning
Core works: *Obviously Awesome* (2019), *Sales Pitch* (2023). https://www.aprildunford.com

- **Competitive alternatives come first.** Position against what the customer would actually do without you. In 2026 that is "GitHub Code Quality is already in our GHE contract" or "Copilot code review is included", not Checkmarx. The pitch has to answer "why pay for a second tool when the platform does it": independent verification across agents and SCMs, deterministic depth, one gate for quality and security.
- **Pick the market frame that makes your strengths obvious.** Sonar can be framed as "code quality tool" (crowded, being commoditised by GitHub), "AppSec" (CISO buyer, Checkmarx/Snyk), or "verification layer for AI-written code" (new frame where architecture, quality gates and remediation are the strengths). The internal win themes ("AI enabler", complementary to Copilot) already show which frame wins deals. Test frames on landing pages and in the reverse-trial onboarding copy.
- **Sales pitch structure: insight first, then differentiated value.** Lead with the market insight ("40%+ of PRs now start with an agent; review is the bottleneck"), then show what Sonar does that alternatives cannot. Useful for in-product upgrade moments as much as for AEs.

### 2. Bob Moesta / Clayton Christensen: Jobs to be Done
Core works: Christensen, *Competing Against Luck* (2016); Moesta, *Demand-Side Sales 101* (2020); the "Forces of Progress" and switch interview. https://therewiredgroup.com

- **The four forces of a switch: push, pull, anxiety, habit.** For first-year churn, map why a team hired Sonar (push: AI code they cannot review; pull: quality gate on PRs) and what makes them fire it (habit: GitHub-native defaults; anxiety: noisy findings blocking merges). Setup friction is an anxiety force at hire time and a churn driver later; reducing it serves both activation and retention.
- **Switch interviews over feature requests.** Interview recent churners and recent converts about the timeline ("first thought", "passive looking", "deciding moment"). Ask what was happening the week they cancelled. This gets at causes that the 61.6% of losses with no recorded reason hide.
- **The job is bigger than the product.** "Ship AI-written code without getting paged" includes the agent, CI, review and on-call. Sonar wins by being the step in that job that makes the rest safe, which points ideas toward integration (MCP, agent hooks, PR decoration) rather than standalone dashboards.

### 3. Kyle Poyar: PLG pricing and monetisation
Core work: *Growth Unhinged* newsletter, annual State of B2B Monetization (2026 edition). https://www.growthunhinged.com

- **Hybrid pricing is the 2026 default.** Platform fee plus usage or credits (37% of companies, up from 25%; 29% use AI credits, 33% plan to). For Sonar: keep LOC or committer as the base, price AI review, remediation and Hunter analysis as credits or per PR. Watch that the unit tracks value the buyer already counts (PRs merged, issues fixed), not cost Sonar incurs.
- **Reverse trials and the "value moment" before the paywall.** Reverse trials work when the trial delivers the premium value early enough that losing it hurts. Design the 14-day SQC Team trial so the first PR decoration and first quality-gate block (or pass) happen in day 1-2; otherwise there is nothing to lose at day 14.
- **PQLs and product-led sales.** Usage signals (number of repos, contributors, PRs gated, Advanced Security findings) should route accounts to sales. Expansion in dev tools comes from admin needs (SSO, org policy, reporting), so those are the upgrade triggers worth instrumenting.
- **AI engines as a discovery channel.** His own data shows AI-engine referrals rising from ~5% to 15%+ during 2026. Comparison pages and docs need to answer "SonarQube vs GitHub Code Quality" clearly for LLMs.

### 4. Brian Balfour and Casey Winters: growth loops and distribution
Core works: Reforge growth series; Balfour, "Four Fits" essays (product-market, product-channel, channel-model, model-market); Winters, writing on loops and marketplaces. https://brianbalfour.com, https://www.reforge.com, https://caseyaccidental.com

- **Loops over funnels.** A Sonar loop: developer adds Sonar to a repo -> PR decoration shows findings to every reviewer -> reviewers on other teams see it and add it to their repos. The agent-era version: an agent config file or skill that calls Sonar via MCP gets copied across repos and teams. Ask of every idea: which loop does it speed up?
- **Product-channel fit.** Channels shift faster than products; you fit the product to the channel. 2026 channels: agent marketplaces and MCP registries, IDE extension stores, GitHub Marketplace, LLM answers. Each needs a different shape (MCP tool with crisp outputs, one-click IDE install, zero-config AutoScan).
- **Platform risk ("the platform giveth and taketh").** Balfour's warning about building on someone else's distribution applies directly: GitHub is both Sonar's largest channel and its top named competitor; Anthropic and Cursor are partners via MCP and now ship review. Diversify across platforms, own the direct relationship (account, data, history), and make Sonar's value persist outside any one host.
- **Model-market fit.** LOC-based pricing at SMB scale meets Aikido at ~$350/month flat. Check whether the pricing model fits the segment's willingness to pay before optimising the funnel.

### 5. Gergely Orosz: how engineering orgs actually work
Core work: *The Pragmatic Engineer* newsletter and podcast; *The Software Engineer's Guidebook* (2023). https://newsletter.pragmaticengineer.com

- **Tool adoption runs through staff engineers and platform teams, not procurement.** His reporting on how companies like Uber, Stripe and others choose tools shows internal champions and platform teams standardise first, then procurement follows. Growth should equip the platform engineer (Terraform/Helm config, org-wide defaults, migration guides), not only the individual developer.
- **AI tooling reality checks.** He tracks actual AI usage, costs and headcount effects inside companies, which is a corrective to vendor surveys (including Sonar's). Use his pieces to sanity-check claims before they go into decks.
- **Engineering-leader budget pressure.** His coverage of budget cuts and "do more with fewer engineers" explains the flat-renewal mandates seen in Sonar's loss data. Ideas should show cost avoided or headcount-equivalent saved.

### 6. Daniel Kahneman and Richard Thaler: behavioural economics
Core works: Kahneman, *Thinking, Fast and Slow* (2011); Thaler and Sunstein, *Nudge* (2008, final edition 2021).

- **Loss aversion and the endowment effect.** Reverse trials work because removing a feature hurts more than never having it. The effect needs ownership: name the user's own findings ("12 security issues in your repos that Team caught") when the trial ends, rather than listing plan features.
- **Defaults are decisions.** Most teams never change the default quality gate or rule profile. Ship opinionated defaults for AI-written code (e.g., a "Sonar way for AI code" gate) and pre-enable PR decoration; a default reaches far more users than any feature they have to find.
- **Choice architecture at checkout and downgrade.** The 14-day reverse-trial end screen (pay, Free, pause) is a choice architecture problem: order, anchoring (show Team value against the cost of one hour of senior review), and making "pause" a real alternative to churn.
- **Planning fallacy and present bias.** Buyers underestimate setup effort (planning fallacy) and put off configuration (present bias), which is why gates end up under-configured and renewals erode. Do the configuration for them at onboarding rather than relying on later intent.

---

## B. Understanding developer users

### 7. Nicole Forsgren and Abi Noda: developer productivity and DX
Core works: Forsgren, Humble, Kim, *Accelerate* (2018); SPACE framework (2021); "DevEx: What Actually Drives Productivity" (ACM Queue, 2023, with Noda, Storey, Greiler); DX Core 4 (2024-2025); Forsgren and Noda, *Frictionless* (2025). https://getdx.com, https://dora.dev

- **Three DevEx dimensions: feedback loops, cognitive load, flow state.** Every Sonar touchpoint should be judged on these. A 10-minute CI scan breaks the feedback loop; 200 legacy findings add cognitive load; a blocking gate on an unrelated file breaks flow. "Clean as You Code" (focus on new code) is a cognitive-load idea, and it should carry over to agent output.
- **Measure perception and system data together.** Self-reported trust plus telemetry (time to merge, rework rate, gate pass rate). Sonar can supply the system side of the AI-ROI question that 55% of leaders cannot answer (Qodo, Sep 2026).
- **AI as amplifier (DORA 2025/2026).** AI improves throughput and worsens instability where foundations are weak. Sonar's pitch to eng leaders: the quality gate is part of the foundation that makes AI ROI positive. The DORA J-curve gives a time frame for when to expect proof (about one quarter).

### 8. Kathy Sierra: make users badass
Core work: *Badass: Making Users Awesome* (2015). Earlier: Creating Passionate Users blog.

- **Users don't want your tool to be awesome; they want to be awesome.** The value is "the developer who never ships a security regression", not "SonarQube found 40 issues". Reframe in-product messages and emails around the user's improved skill and reputation (clean PRs, fewer review rounds).
- **Cognitive resources are finite; friction drains them.** Every unclear finding spends the user's attention. Fewer, higher-confidence findings with a fix (AI CodeFix, Gitar) beat more findings. Applies directly to false-positive-driven churn.
- **The "suck zone" and getting users past it fast.** New users churn in the gap between sign-up and competence. For SQS, that gap is setup; for SQC, it is the first analysis and understanding the gate. Design for "first win in minutes" (AutoScan already proves this).

### 9. Teresa Torres: continuous discovery
Core work: *Continuous Discovery Habits* (2021). https://www.producttalk.org

- **Opportunity solution tree.** Start from the outcome (e.g., reduce SQC Team first-year churn), map opportunities from customer stories, then compare several solutions per opportunity. It prevents jumping from one churn anecdote to one feature.
- **Weekly touchpoints with customers, done by the team.** Small, regular interviews (including with agent-heavy teams) beat a quarterly research project, especially while agent workflows change month to month.
- **Test assumptions, not ideas.** Break each idea into desirability, viability, feasibility and usability assumptions and test the riskiest first (e.g., "teams will let an agent call Sonar before every commit" is a usability and trust assumption worth testing before building).

### 10. BJ Fogg: behaviour design
Core works: Fogg Behavior Model (B = MAP: Motivation, Ability, Prompt); *Tiny Habits* (2019). https://behaviormodel.org

- **When a behaviour doesn't happen, check the prompt and ability before motivation.** Teams that don't configure quality gates are rarely unmotivated; the action is hard (ability) or never prompted at the right moment. Prompt at the PR, in the IDE, or in the agent session, where the user already is.
- **Make the target behaviour tiny.** "Connect one repo" beats "set up your organisation". "Fix this one issue" beats "reduce technical debt". Chain the small behaviours into activation milestones.
- **Prompts must land when motivation and ability are both present.** A failed gate on a PR is a high-motivation moment; that is when to offer AI CodeFix or the upgrade, not in a weekly email.

### 11. Charity Majors: production, ownership and AI
Core works: *Observability Engineering* (2022, co-author); essays at https://charity.wtf; Honeycomb blog.

- **Production is where code is verified; pre-merge checks are necessary but not sufficient.** Strong developers distrust tools that claim certainty. Sonar messaging should say what static analysis catches and what it does not, which builds trust with senior engineers.
- **Ownership and the senior engineer's role in the AI era.** She argues that as AI writes more code, judgement, review and system understanding become the scarce skills. Sonar can position itself as the tool that extends a senior reviewer's judgement across many more PRs, not as a replacement for it.
- **Sociotechnical systems.** Tools change team behaviour. A gate that blocks merges shifts responsibility; design rollout so teams opt in to stricter gates as trust builds, instead of imposing them on day one.

### 12. Simon Willison: practitioner view of AI coding
Core work: blog at https://simonwillison.net (daily notes on LLM tooling); writing on "vibe coding" vs responsible AI-assisted programming, prompt injection and the "lethal trifecta" (2025).

- **"Vibe coding" vs "vibe engineering".** He separates throwaway prototypes, where nobody reviews the code, from production work, where the developer stays accountable for every line. Sonar's market is the second; the growth question is how to catch the moment a vibe-coded prototype becomes production.
- **The lethal trifecta for agents: private data + untrusted content + external communication.** Agents with all three can be manipulated into exfiltrating data. Agent configs, MCP servers and tool permissions are a new attack surface that code-security tools barely cover yet; candidate territory for Sonar's agent-security story.
- **Tests and verification are what make AI code usable.** His practice, and that of many senior developers, is to let agents write code freely and rely on tests, linters and review to accept it. That habit is the behaviour Sonar should plug into (agent hooks, pre-commit, CI), and it makes the verification-layer frame credible to developers.

---

## Quick-use matrix

| Growth question | Reach for |
|---|---|
| Why do SQS/SQC teams churn in year one? | Moesta (forces), Sierra (suck zone), Fogg (ability/prompt), Torres (OST) |
| How do we position against GitHub Code Quality / Copilot review? | Dunford, Balfour (platform risk), Majors (honest scope) |
| How should AI review/remediation be priced? | Poyar, Kahneman/Thaler (anchoring), Balfour (model-market fit) |
| How do we design the reverse trial and its end screen? | Poyar, Kahneman/Thaler (loss aversion, defaults), Fogg |
| How do we become the tool agents call? | Balfour/Winters (product-channel fit, loops), Willison, Forsgren/Noda (feedback loops) |
| How do we prove ROI to eng leaders? | Forsgren/Noda (DX, DORA), Orosz (budget reality) |
| How do we earn developer trust? | Majors, Willison, Sierra |

## Sources to follow

- Lenny's Newsletter and podcast (https://www.lennysnewsletter.com): growth and PLG case studies; good for benchmarks on trials and activation.
- Growth Unhinged (Kyle Poyar): pricing and PLG data, annual monetisation report.
- The Pragmatic Engineer (Gergely Orosz): engineering-org reality, AI tooling adoption.
- DX research (getdx.com) and dora.dev: developer productivity data and frameworks.
- simonwillison.net: daily practitioner notes on AI coding tools and agent security.
- charity.wtf: engineering leadership, observability, AI and senior engineers.
- Product Talk (Teresa Torres): discovery practice.
- Reforge essays (Balfour, Winters): loops, channels, retention.
