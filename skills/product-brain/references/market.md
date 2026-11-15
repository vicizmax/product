# Market reference: code quality, code security and AI dev tooling

**As of: 2026-10-29.** Covers events through GitHub Universe (28 Oct 2026). Forecast window: Nov 2026 to Apr 2027.
**Classification: Internal / Confidential.** Sections marked [internal] come from Sonar battlecards, win/loss and Slack competitive intel via Glean. Do not paste into external tools or share outside Sonar.

Conventions: every non-obvious fact has a source and date. "(secondary)" = trade press or aggregator, not the primary source. "(unverified)" = could not confirm, or sources conflict. Internal docs are linked by Google Drive / Confluence URL.

## Contents

1. [The AI-coding shift](#1-the-ai-coding-shift)
2. [Competitive landscape](#2-competitive-landscape)
3. [Buyer and user shifts, budgets, compliance](#3-buyer-and-user-shifts-budgets-compliance)
4. [PLG and dev-tools growth patterns that work in 2026](#4-plg-and-dev-tools-growth-patterns-that-work-in-2026)
5. [Forecast: Nov 2026 to Apr 2027](#5-forecast-nov-2026-to-apr-2027)
6. [How to refresh this file](#6-how-to-refresh-this-file)

Thinkers and sources: see `thinkers-extra.md` in this folder.

---

## TL;DR

- **Code volume tripled; review capacity did not.** GitHub merged PRs went from 538M to **1.3B** in a year; **over 40% of PRs** now start with an agent draft (17% in March 2026). Verification is the named bottleneck in every 2026 survey.
- **Trust is conditional on verifiability.** Only **6.6%** of developers trust AI for important decisions; **48%** trust it when output is easy to verify (Stack Overflow, Oct 2026). Sonar's own survey: **96%** do not fully trust AI code, **48%** always verify.
- **GitHub is the main threat and it just moved again.** Code Quality GA (20 Jul 2026, $10/active committer); at Universe (28 Oct 2026) all Copilot features, including code review, are included in GitHub Enterprise with pay-per-AI-credit. GitHub/GHAS is the top named competitor on Sonar losses (36 of named losses, Jun-Sep 2026) [internal].
- **The coding-agent vendors are moving into review and security.** Anthropic Code Review GA (15 Oct 2026); Claude Code Security preview (Feb 2026); Cursor owns Graphite (Dec 2025); Copilot code review Max and AI Scans (Oct 2026). Sonar's defensible angle is independence plus deterministic depth, not model accuracy.
- **Pricing is shifting from seats to usage/outcomes for AI features.** Hybrid pricing 37% of SaaS cos (up from 25%); AI credits 29% with 33% planning (Poyar 2026). Gitar Enterprise is per-PR; Copilot code review consumes AI credits ($0.25-$5 per Balanced review).
- **Compliance clock:** CRA reporting live since **11 Sep 2026**; full CRA **11 Dec 2027**; AI Act high-risk delayed to **2 Dec 2027**; CISA 2026 SBOM minimum elements (29 Jul 2026).

---

## 1. The AI-coding shift

### 1.1 Usage and volume (hard data)

| Metric | Value | Source, date |
|---|---|---|
| Merged PRs on GitHub, 12 months to Sep 30 | 402M (2024) -> 538M (2025) -> **1.3B (2026)**, ~3.5M/day | [GitHub Octoverse 2026](https://github.blog/news-insights/octoverse/octoverse-commits-pushes-reach-new-highs-in-2026-as-developers-build-with-agents/), Oct 2026 |
| Commits on GitHub | 12.9B (2025) -> **34.3B (2026)**; monthly commits 6x Sep 2025 by Sep 2026, inflection after June 2026 | Octoverse 2026 |
| Share of PRs started by an agent | **17% (Mar 2026) -> 40%+ (Sep 2026)**; 110M agent-started PRs in Sep 2026 alone (6x March) | Octoverse 2026 (floor; only detectable agents) |
| Agent PR merge rate within 2 weeks | 83% (Feb) -> **90% (Sep)** vs ~86% for non-agent PRs | Octoverse 2026 |
| Agent PRs touching multiple files | 87% vs 79% non-agent | Octoverse 2026 |
| Repos with an agent config file | 8x the commits of new repos without one | Octoverse 2026 |
| Copilot MAU using agentic features | 55% (35% a year earlier); Copilot cloud agent +230% YoY | Octoverse 2026 |
| Model plurality | 61% of Copilot users use >1 model; 47 distinct models in Sep; no model >25% of requests | Octoverse 2026 |
| GitHub Actions jobs | 45.4B/yr (3x prior year); 30M+ Dependabot PRs merged (2x) | Octoverse 2026 |
| GitHub developers | 225M+ | Octoverse 2026 |

### 1.2 Share of code that is AI-generated (survey data, self-reported)

| Claim | Source, date | Note |
|---|---|---|
| **42%** of committed code is AI-generated; expected **65% by 2027** | [Sonar State of Code survey](https://www.sonarsource.com/blog/state-of-code-developer-survey-report-the-current-reality-of-ai-coding/), Jan 2026, n~1,100 | Self-reported estimate |
| 48% of code AI-generated | [Augment Code, State of AI-Native Engineering 2026](https://www.augmentcode.com/resources/state-of-ai-native-engineering-2026), n=219 leaders | Vendor survey |
| 42% of devs write half or more of their code with AI (12% a year earlier) | BairesDev Dev Barometer Q3 2026 via [codercops](https://blog.codercops.com/blog/ai-generated-code-42-percent-developers-2026) | (secondary) |
| Google: 75% of new code AI-generated and engineer-approved, Apr 2026 | via [valueaddvc](https://valueaddvc.com/blog/vibe-coding-explained-how-ai-is-changing-software-development-in-2026) | (unverified) |
| "60% of new code" Gartner figure | [thefalcon.dev fact check](https://www.thefalcon.dev/writing/ai-generated-code-statistics-2026-fact-check) | No traceable primary source; do not cite |

Working assumption for brainstorming: **40-50% of committed code is AI-generated or AI-assisted in late 2026**, and the share of agent-authored PRs is rising faster than the share of AI lines.

### 1.3 Coding-agent vendors (state as of Oct 2026)

| Vendor | Status | Source |
|---|---|---|
| **GitHub Copilot** | ~50M users cited on Microsoft Jul 2026 earnings (secondary). Universe 28 Oct 2026: Copilot app, Copilot Fusion (multi-model routing) GA, Copilot projects (multi-repo agents), automations that learn from outcomes, **code review Max** tier, and **all Copilot features included in GitHub Enterprise; customers pay for AI credits used** (sales-led now, self-serve "coming soon"). | [GitHub blog](https://github.blog/news-insights/company-news/github-universe-2026-evolving-every-layer-of-the-stack/), 28 Oct 2026; users: [newmarketpitch](https://newmarketpitch.com/blogs/news/ai-code-assistant-cursor-claude-code-copilot) (secondary) |
| **Claude Code (Anthropic)** | Last official figure: run-rate >$2.5B (Feb 2026). Third-party estimates far higher (unverified). Code Review (multi-agent PR review) research preview 9 Mar 2026, **GA 15 Oct 2026** for Team/Enterprise, GitHub only, "light security analysis". Claude Code Security preview Feb 2026; security-guidance plugin May 2026. | [The New Stack](https://thenewstack.io/anthropic-launches-a-multi-agent-code-review-tool-for-claude-code/), [Unite.ai](https://www.unite.ai/anthropic-makes-code-review-for-claude-code-generally-available/), [Help Net Security](https://www.helpnetsecurity.com/2026/05/27/anthropic-claude-code-security-guidance-plugin/) (secondary) |
| **Cursor (Anysphere)** | Acquired by **SpaceX for ~$60B, closed 14 Aug 2026**; now in SpaceXAI. ARR reported $2.6B-$4B by Jun 2026 (conflicting). **OpenAI to cut model access 12 Nov 2026** (~5% of Cursor traffic). Owns **Graphite** (AI review / stacked PRs, announced Dec 2025). | [Yahoo Finance](https://finance.yahoo.com/technology/ai/articles/spacex-closes-60bn-acquisition-ai-085713131.html), [CNBC](https://www.cnbc.com/2026/08/29/openai-cursor-spacex-model-access.html), 29 Aug 2026 |
| **OpenAI Codex** | 5M+ weekly active users (OpenAI, 2 Jun 2026); later figures mix in other products. | [gradually.ai](https://www.gradually.ai/en/codex-statistics/) (secondary) |
| **Cognition (Devin; Windsurf renamed Devin Desktop Jun 2026)** | ~$1B run-rate, $48B valuation (Sep 2026, unverified). Devin Security 2.0 published Oct 2026. | [ajayk.sh](https://www.ajayk.sh/blog/coding-agents-market-2026-share-productivity/) (secondary); [Devin blog](https://devin.ai/blog/devin-security-2) |
| **Google** | Gemini CLI kept for paid enterprise; consumer/free moved to Antigravity CLI (18 Jun 2026). | [Context Studios](https://www.contextstudios.ai/guides/best-ai-coding-agents-2026) (secondary) |

Implication: the agent market is consolidating into 4-5 platforms with model plurality inside each. Platform politics (SpaceX vs OpenAI, Microsoft vs everyone) increase the value of a **vendor-neutral verification layer** that works the same across agents and SCMs.

### 1.4 Verification, review and trust

| Finding | Source, date |
|---|---|
| 96% of devs do not fully trust AI code; only 48% always verify before commit; 38% say reviewing AI code takes more effort than reviewing human code | [Sonar press release](https://www.sonarsource.com/company/press-releases/sonar-data-reveals-critical-verification-gap-in-ai-coding/), Jan 2026 |
| Devs and eng leaders both name **reviewing/validating AI code** as the #1 delivery constraint. 90% of leaders confident reporting AI impact to the board; only 45% can trace AI activity to code changes | [Qodo State of AI Code Quality 2026](https://www.qodo.ai/blog/state-of-ai-code-quality-report-2026/), 23 Sep 2026, n=500 devs + 300 leaders (vendor) |
| 48.0% trust AI output "when easy to verify"; 6.6% trust it for important decisions; 78.7% say source attribution matters | [Stack Overflow Developer Survey 2026](https://survey.stackoverflow.co/2026/ai/data), published 6 Oct 2026, ~30.9k responses |
| AI raises both throughput and instability; AI is an "amplifier" of existing systems. 2026 ROI report: J-curve, example 15% productivity dip for ~3 months; extra code volume without a verification layer is paid for later | [DORA 2025](https://dora.dev/insights/balancing-ai-tensions/); [InfoQ on DORA ROI report](https://www.infoq.com/news/2026/05/dora-roi-ai-assisted-dev-report/), May 2026 |
| METR RCT follow-up: speed-up estimates not significant (returning devs -18% time, CI -38% to +9%); study broke because devs refused to work without AI | [METR](https://metr.org/blog/2026-02-24-uplift-update/), 24 Feb 2026 |
| Devs accept ~40% of AI code without revision | IDC, cited in [Sonar AR enablement deck](https://docs.google.com/presentation/d/17BfbVb--w7ps0_YQn2uX7jH4sOkl7g9JPwjtHdii4Hs) [internal] |
| 43% of AI code changes need manual debugging in production after passing QA | Lightrun 2026 via [DEV](https://dev.to/code-board/the-review-bottleneck-why-more-ai-code-means-slower-teams-in-2026-1e5n) (unverified) |

### 1.5 Vibe coding and security debt

- 45% of AI-generated samples introduce OWASP Top 10 flaws, no clear improvement across 2025 to early 2026 (Veracode testing of 100+ LLMs, via [CSA research note](https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-codegen-vulnerability-debt-20260406-csa/), Apr 2026, secondary).
- 74 AI-linked CVEs confirmed through Mar 2026 (Georgia Tech Vibe Security Radar), per [CSA](https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-generated-code-vulnerability-surge-2026/). Tool breakdown (27 attributed to Claude Code) unverified.
- Incidents: Firebase misconfig in an AI-built platform exposing 406M records (Jan 2026); AI-built social app leaking 1.5M API tokens via exposed Supabase key without RLS (both via [CSA / SecurityWeek](https://www.securityweek.com/vibe-coded-apps-riddled-with-exploitable-security-flaws/), unverified specifics).
- Dominant failure types: authorization and access control, hardcoded secrets, misconfigured backends. These are logic and config flaws, which pattern-only SAST under-detects. Relevant to Sonar Hunter Agent (business-logic and broken access control, GA on SQC 27 Aug 2026) [internal].
- Supply chain: Socket flagged trojanized keyv/cacheable npm releases (4 Aug 2026) that passed npm provenance; 140+ Mastra packages compromised (Jun 2026) ([Socket](https://socket.dev/supply-chain-attacks/keyv-and-cacheable-compromise)). Agents install dependencies autonomously, which raises SCA and malicious-package demand.
- Caution: [Museum of Vibe Coding](https://museumofvibecoding.org/vibe-coding-security-the-complete-research-record-unbiased-research-2026/) notes most-cited vibe-coding stats lack methodology. Use as directional.

### 1.6 What this does to demand for code quality and security

1. **The unit of work moved from "line typed" to "PR reviewed".** Value accrues to whoever owns the merge decision. Quality gates are the existing Sonar asset at that point.
2. **Verification moves earlier, into the agent loop.** Vendors now ship write-time checks via MCP, hooks and skills: Sonar Vortex (30 Jun 2026), Semgrep Guardian (23 Jun 2026, 3M+ scans/week), Snyk Evo, Checkmarx Developer Assist (GA Jul 2026), Codacy AI Guardrails, Anthropic security plugin.
3. **Deterministic + LLM hybrid is now table stakes.** Semgrep (rules + LLM for IDORs), CodeRabbit (integrated Infer), Gitar on SonarQube ("deterministic + AI reasoning layers") [internal]. Pure-LLM reviewers are criticised for variable depth; pure-rules tools for missing logic flaws.
4. **Remediation is the new battleground, not detection.** CodeRabbit Autofix + Fix CI, Qodo remediation agent (preview), Copilot Autofix, Gitar "iterate until CI passes", SQRA GA (30 Jun 2026). Internal battlecard guidance: shift from "who finds more" to "who commits the fix" [internal].
5. **Governance and evidence demand grows.** Leaders need traceability from AI activity to outcomes (Qodo: 45% have it). This is a reporting and portfolio-view job, and a renewal argument.
6. **Cost of review becomes a line item.** AI review priced per review or credit (Copilot $0.25-$5 per Balanced review; Greptile $1/extra review) makes "cost per verified PR" a comparable metric. Deterministic analysis is cheap per PR; that is a pricing lever.

---

## 2. Competitive landscape

### 2.1 Sonar's own 2026 moves (context for comparisons) [internal]

| Date | Move | Source |
|---|---|---|
| 21 May 2026 | Acquired **Gitar** (AI code review that fixes and iterates until CI passes) | [press release](https://www.sonarsource.com/company/press-releases/sonar-acquires-gitar/) |
| 24 Jun 2026 | Advanced Security available to monthly self-serve SQC Team | [2026 QBR: Storefront](https://docs.google.com/document/d/1Sb-1te1ZcMuy1hSumtOMtMbB5ZTcJjrlLi3NvN5RryY) |
| 30 Jun 2026 | **Sonar Vortex** (context + real-time verification inside agent loop); **SQRA** (Remediation Agent) GA; Agentic Essentials for annual Team/Enterprise | [blog](https://www.sonarsource.com/blog/introducing-sonar-vortex/) |
| Jul 2026 | Gitar pricing: Core $20, Pro $40/user/mo; Enterprise **per PR**, unlimited iterations (~$4.80/PR example) | [Gitar page](https://www.sonarsource.com/products/gitar/); [Vortex launchbay](https://docs.google.com/presentation/d/15dvBm_3dQ4OL8fdKL7gGlTe8QK6dy3dRYCBRWo1yDZ4) |
| 27 Aug 2026 | **Hunter Agent** GA on SQC (agentic detection of logic flaws, broken access control) | [Security Prime deck](https://docs.google.com/presentation/d/1ybEnfUYSn_-rHtvkDu-6__GbgkB-mDc78Dywm4uTbwc) |
| 1 Oct 2026 | SQC Team **reverse trial** A/B (50/50, 14 days on Team, no card) | [Confluence](https://xtranet-sonarsource.atlassian.net/wiki/spaces/Storefront/pages/5565513780) |
| 2026.3 | MCP server hostable on SonarQube Server (MCP GA since 7 Oct 2025) | [docs](https://docs.sonarsource.com/sonarqube-server/agentic-capabilities) |
| Oct 2026 | Pricing page shows Advanced SAST/SCA as "needs additional subscription"; competitors noticed | [Slack competitive digest](https://sonarsource.enterprise.slack.com/archives/C0AF29EUR52/p1793194137594519) |
| Analyst | Gartner MQ **Leader, Technical Debt Management Tools** (first MQ in category; highest Ability to Execute). GigaOm AST Leader/Fast Mover. Sonar declined Forrester Agentic Development Security Landscape Q2 2026 (35 vendors) | [AR deck](https://docs.google.com/presentation/d/17BfbVb--w7ps0_YQn2uX7jH4sOkl7g9JPwjtHdii4Hs); [Forrester decline](https://docs.google.com/document/d/1YPTyXMV-1dUjwMXPhPGo8QXHxwbyJOVRK20QAWA2F0M) |

### 2.2 Win/loss signal (22 Jun - 22 Sep 2026) [internal]

Source: [SonarQube Win/Loss Analysis 22-9-2026](https://docs.google.com/document/d/104XTKQ-wfZGFcSie-zL7uZA_aEi4pmh5rlBPpSoGoss). 3,103 wins / 1,101 losses (new logo + expansion). **61.6% of losses have no recorded reason**, so competitor counts are directional.

| Top win themes | Top loss themes |
|---|---|
| TCO-driven cloud / self-hosted migration | Budget freezes, flat-renewal mandates |
| AI-era quality-signal positioning ("AI enabler") | Approval-process paralysis |
| Complementary to GitHub/Copilot, not competing | Product/AI gaps, especially agentic code review; lack of learned team conventions |
| Value framing beats discounting | Poorly configured / underused quality gates eroding renewal value |
| Multi-threaded champions | Consolidation into GitHub, GitLab, Azure DevOps |

Named competitors on losses: **GitHub/GHAS/Microsoft 36**, Checkmarx 8, Snyk 7, GitLab 3, Wiz 3. Architecture was discussed positively in 113 won-deal calls across 62 accounts; AI CodeFix in 19 calls / 9 accounts. Example loss: Telstra $288.5K (Wiz preferred for security; agentic features not on Server). Aikido losses cite bundle breadth, price, Vanta compliance story, and trial speed ([Aikido lost deals](https://docs.google.com/document/d/1o2Uy-K0RofcJDudTxEE-xu0hr2FXBNgyFPXbdJgFfTw)).

Growth read-through: two of five loss themes (underused quality gates, agentic gaps on Server) are activation/adoption problems, consistent with the team's established finding that setup friction drives SQS churn.

### 2.3 Competitor table

Threat level = threat to Sonar revenue in the next 12 months (High / Medium / Low), judged from loss data, overlap and momentum.

| Who | What | Pricing / motion | Threat | Recent moves (2025-2026) |
|---|---|---|---|---|
| **GitHub (Microsoft): GHAS, Code Quality, Copilot code review, Copilot Autofix, CodeQL** | Native SAST (CodeQL), secrets, Dependabot; **Code Quality** (quality gates via rulesets, coverage thresholds, org dashboards); Copilot review (Lite/Balanced/Max) | Code Quality **$10/active committer/mo** + metered AI + Actions minutes; Copilot Business $19 / Enterprise $39; AI credits since 1 Jun 2026; **Oct 2026: all Copilot features included in GitHub Enterprise, pay for credits**. Bundle + platform sale | **High** | Code Quality GA [20 Jul 2026](https://github.blog/changelog/2026-07-20-github-code-quality-is-now-generally-available/); Universe [28 Oct 2026](https://github.blog/news-insights/company-news/github-universe-2026-evolving-every-layer-of-the-stack/): review Max, automations, Copilot app; AI Scans with reachability (per [remio](https://www.remio.ai/post/github-universe-2026-puts-copilot-in-charge-of-more-than-code), unverified); server-to-server auth (27 Oct). Top named loss competitor [internal] |
| **Anthropic (Claude Code Review, Claude Code Security)** | Multi-agent PR review; codebase security scan + patches | Team/Enterprise plans + review credits; bundled with the agent | **Medium-High** (rising) | Review GA 15 Oct 2026 (GitHub-only, not ZDR/HIPAA); Security preview Feb 2026. Also a Sonar partner/channel via MCP |
| **Cursor + Graphite** | Agent IDE; Graphite = stacked PRs + AI review (Diamond) | Seat + usage; PLG | **Medium** | SpaceX acquisition closed 14 Aug 2026; losing OpenAI models 12 Nov 2026 |
| **Snyk** (Snyk Code, Open Source, Container, IaC, DAST; Evo) | Developer security platform; Evo = AI-SPM, agentic dev security, offensive security | Free; Team **$25/mo**; Evo enterprise-only; sales-led enterprise | **Medium** | Evo AI-SPM (Mar), Agentic Dev Security (Jun), Continuous Offensive Security (Aug 2026); CEO Peter McKay left Feb 2026; ~203 laid off (~20%) per filing; revenue $309M FY2025 (+11%), loss $189M ([Tech.eu](https://tech.eu/2026/10/01/snyk-laid-off-over-200-employees-revenues-top-300m), 1 Oct 2026). Weakened; a sale or restructuring is plausible |
| **Semgrep** | Rules + LLM SAST, SCA, secrets; **Guardian** (write-time, MCP/hooks/skills; Cursor, Claude Code, Codex, Replit) | Free/OSS core; Team/Enterprise; Guardian separate plan, 30-day trial from 13 Oct 2026; dev-first PLG + enterprise | **Medium** | $100M Series D (Feb 2025); Guardian launch [23 Jun 2026](https://semgrep.dev/blog/2026/introducing-semgrep-guardian-real-time-security-for-ai-written-code/), 3M+ scans/week. Internal: direct Vortex analogue, reliability gaps ([report](https://docs.google.com/document/d/1CifIiV5nM-yfvlJuBfZUgh-6F3njoXFHvhiese_WMhk)) [internal] |
| **Checkmarx** | Checkmarx One ASPM: SAST, SCA, DAST, IaC, API, secrets; Developer Assist (pre-commit fix loop) | Custom enterprise quotes; CISO-led sales | **Medium** (enterprise AppSec renewals) | Acquired Tromzo (agentic triage/remediation, Dec 2025); Developer Assist GA Jul 2026. Claims ~60% of Fortune 100 [internal] |
| **Veracode** | SAST, DAST, SCA, manual pentest; Pipeline Scan | $50K-$300K+/yr programs (third-party estimate); compliance-led | **Low-Medium** | Agentic AI features 2025-2026 (unverified specifics). Win angle: incremental Sonar Advanced Security pilot before renewal [internal] |
| **Black Duck** (Coverity, Black Duck SCA, Polaris, Assist, **Signal**) | Enterprise SCA + SAST; agentic AppSec | Enterprise sales | **Low-Medium** | Signal GA 23 Mar 2026 (ContextAI model) ([konvu](https://konvu.com/compare/checkmarx-vs-black-duck), secondary). Atlassian $303.8K Sonar win vs Synopsys/Coverity/Black Duck/Polaris [internal] |
| **Aikido** | All-in-one: SAST, SCA, secrets, IaC, containers, DAST, pentest, compliance (Vanta/Drata) | Basic ~**$350/mo for 10 users / 100 repos**; fast self-serve trial; SMB/mid-market PLG | **High in SMB/EU mid-market** | $60M Series B at $1B (14 Jan 2026, [GlobeNewswire](https://www.globenewswire.com/news-release/2026/01/14/3218567/0/en/aikido-security-raises-60-million-series-b-at-1-billion-valuation-to-lead-software-security.html)); acquired Root.io (Jun/Jul 2026, in-place OSS patching); external network pentesting (Oct 2026); FedRAMP push |
| **CodeRabbit** | AI PR review; Autofix with build verification; Fix CI; Infer static analysis; learned conventions; Delta Deep Scans (Oct 2026) | Essentials $24 / Team $48 / Advanced $72 per user/mo annual; PLG | **Medium-High** (vs Gitar, and as the "AI review" budget line) | $143M Series C at $1.5B (Aug 2026, [TNW](https://thenextweb.com/news/coderabbit-raised-143m-to-read-the-code-ai-wrote)) |
| **Qodo** | PR review, cross-repo review, Rules Miner, remediation agent (preview); on-prem | Credits: $0.012/credit, e.g. $240 for ~144 reviews; dropped permanent free tier for 14-day trial (secondary) | **Medium** | Qodo 2.4 (Jun 2026); PR-Agent back to Apache 2.0 (Apr 2026); State of AI Code Quality report (Sep 2026) |
| **Greptile** | Codebase-graph AI review | $30/seat incl. 50 reviews, $1/extra (from Apr 2026) [internal] | **Low-Medium** | Funding figures conflict (unverified) |
| **Codacy** | Quality + security, AI Guardrails in IDE (free tier) | Seat-based, unlimited LOC, Team ~$18-21/dev/mo; markets against LOC pricing | **Low-Medium** | No SAML/SCIM per Aug 2026 Sonar research [internal] |
| **DeepSource** | Static analysis + Autofix AI + AI review | Team $24/user/mo (Feb 2026 restructure; secondary) | **Low** | Pricing restructure Feb 2026 |
| **Qodana (JetBrains)** | IntelliJ inspections in CI | Free Community; Ultimate from ~$6/contributor/mo | **Low** (but cheap fallback for JetBrains shops) | Limited AI story (sources conflict) |
| **Endor Labs** | Reachability-based SCA; AI SAST agent | Enterprise sales | **Low-Medium** | $93M Series B (Apr 2025); AI SAST (2026); joined Wiz Integration Network 15 May 2026 ([Endor](https://www.endorlabs.com/learn/from-code-to-cloud-endor-labs-joins-the-wiz-integration-network)) |
| **Socket** | Malicious-package / supply-chain detection | Free + paid; dev-first | **Low** (adjacent; partner candidate) | $60M Series C at $1B, 20 May 2026 ([Socket](https://socket.dev/blog/series-c)) |
| **Wiz Code (Google)** | SAST, SCA, secrets, IaC tied to CNAPP | Bundled in Wiz platform; CISO/cloud-security sale | **Medium** in cloud-security-led enterprises | Google closed Wiz acquisition 11 Mar 2026 ([Wikipedia](https://en.wikipedia.org/wiki/Wiz,_Inc.)); Telstra loss [internal] |
| **Cycode / Apiiro** | ASPM, code-to-runtime risk | Enterprise sales | **Low** | Cycode last round Nov 2021, headcount down (opinion source, unverified); Apiiro ranked ahead in ASPM breadth (May 2026, secondary) |
| **GitLab (Duo, Ultimate security)** | Platform-native SAST/secrets + Duo review | Platform bundle | **Medium** (platform consolidation) | Hiring PMs for Secret Detection, Vulnerability Research (Oct 2026) [internal Slack] |

### 2.4 Pricing units in play (compare like with like)

LOC (Sonar core), active committer (GitHub Code Quality, GHAS), seat (Codacy, CodeRabbit, DeepSource, Snyk), per PR (Gitar Enterprise), per review / credit (Copilot, Greptile overage, Qodo), flat bundle by users + repos (Aikido). Internal GHAS model: 1M LOC Sonar EE $21K vs GHAS-only $23.5K; 5M LOC $34K vs $117.6K (older modeled example) [internal, [GHAS battlecard](https://docs.google.com/presentation/d/1s0tl1PZZfbrMBFyxHI2Vg-V3UYkORxHI8L9-8vg1n78)]. Codacy explicitly attacks LOC pricing as "penalising growth"; with AI tripling code volume, **LOC-based pricing becomes a sharper objection** in 2027 renewals.

### 2.5 Positioning guidance from battlecards [internal]

- Do not claim model-accuracy superiority over Copilot or a detection-depth win over Checkmarx/Veracode; no independent public benchmark supports it.
- Defensible: independence across SCMs and agents, deterministic + AI layers, one gate for quality and security, architecture, build-green remediation loop, governance.
- Outdated claims to drop: "GitHub has no quality gates", "CodeRabbit/Qodo only comment".

---

## 3. Buyer and user shifts, budgets, compliance

### 3.1 Who buys and why (late 2026)

| Shift | Evidence | Implication for Sonar |
|---|---|---|
| **AI budget crowds out tool budget** | Budget freezes and flat-renewal mandates are the #1 loss theme [internal]; enterprises spend 17x more on AI tools than on securing AI (Gartner-based, [softwarestrategiesblog](https://softwarestrategiesblog.com/2026/03/24/information-security-spending-2026/), secondary) | Frame Sonar as the cost of making AI spend safe ("AI enabler"), funded from the AI line, not the legacy tooling line |
| **Platform consolidation** | GitHub/GitLab/ADO consolidation is a top loss theme; Gartner prediction that by 2028 50% of enterprises will use 3 or fewer security platforms (unverified) | Must be the neutral layer across platforms, or be a native app inside each |
| **Security spend still grows, AI security fastest** | Gartner 2026 infosec spend $244B (+11.6% cc, Feb 2026); 2Q26 update $248.9B (+12.7%), securing AI the only accelerating segment (secondary) | Advanced Security + Hunter + agent guardrails can ride "securing AI-written code" budgets |
| **Eng leader vs CISO** | Sonar wins on eng workflow; losses to Wiz/Checkmarx when security team owns the decision (Telstra) [internal] | Two motions: eng-led (quality gate, AI review, DX) and CISO-led (evidence, compliance, consolidation). Growth owns the first; must hand clean signals to the second |
| **Measuring AI ROI** | 90% of leaders report AI impact to board, 45% have traceability (Qodo, Sep 2026); DORA ROI J-curve (2026) | Portfolio-level "AI code health" reporting is a buyer job, and a retention lever |
| **DX frameworks mainstream** | DORA, SPACE, DX Core 4 used to judge tools; developers refuse to work without AI (METR, Feb 2026) | Any friction Sonar adds to the agent loop is measured against flow; latency and false positives are churn drivers |
| **Agent-run delivery** | Copilot automations, server-to-server auth, multi-repo agent projects (Oct 2026) | The "user" increasingly is an agent. Machine-readable results, MCP tools, and policy-as-code matter as much as UI |

### 3.2 Compliance drivers and dates

| Regime | Status (as of Oct 2026) | Next dates | Relevance |
|---|---|---|---|
| **EU Cyber Resilience Act** (Reg. 2024/2847) | Manufacturer reporting of actively exploited vulns and severe incidents **mandatory since 11 Sep 2026** (24h early warning, 72h notification, 14-day final report). ENISA Single Reporting Platform live, web-form only, API unscheduled | **11 Dec 2027**: full application (secure-by-design requirements, vuln handling, SBOM in technical documentation, conformity assessment); OSS steward reporting from 11 Dec 2027 | Evidence of secure development + SBOM + vuln handling for any product sold in EU. [EC](https://digital-strategy.ec.europa.eu/en/policies/cra-reporting); [Crowell](https://www.crowell.com/en/insights/client-alerts/its-live-the-cyber-resilience-act-reporting-is-mandatory-as-of-today-11-september-2026) |
| **NIS2** | National laws in force in **24 of 27** states (16 Oct 2026 tracker); France, Ireland, Spain outstanding; Commission referred IE, ES, FR, NL to CJEU 8 Jul 2026 | Supervisory audits ramping 2027 | Supply-chain security and secure development duties for essential/important entities. [nisd2.eu tracker](https://nisd2.eu/en/wiki/timelines-and-status/nis2-eu-tracker) (secondary) |
| **EU DORA** (financial sector, Reg. 2022/2554) | Applies since 17 Jan 2025; ICT risk management, third-party register, testing | Ongoing supervisory reviews; TLPT cycles | EU banks/insurers need documented secure SDLC and vendor evidence |
| **EU AI Act** | GPAI obligations since 2 Aug 2025. **Digital Omnibus** (Reg. 2026/1744, in force 27 Jul 2026, verify on EUR-Lex): Annex III high-risk moved to **2 Dec 2027**, Annex I to **2 Aug 2028**. Art. 50 transparency unchanged; 50(2) marking grace to 2 Dec 2026 for legacy systems | 2 Dec 2026, 2 Dec 2027 | Indirect for Sonar; companies building AI systems need code governance evidence. [Orrick](https://www.orrick.com/en/Insights/2026/07/EU-AI-Act-Update-Digital-Omnibus-Finalizes-8-Compliance-Changes), [Gibson Dunn](https://www.gibsondunn.com/eu-ai-act-omnibus-agreement-postponed-high-risk-deadlines-and-other-key-changes/) |
| **US federal** | CISA **2026 SBOM Minimum Elements** released 29 Jul 2026 (replaces NTIA 2021; adds 10 fields incl. component hash, SBOM signature; covers SaaS and AI software) ([CISA](https://www.cisa.gov/news-events/news/cisa-and-partners-unveil-updated-software-bill-materials-resource-improves-transparency-security-and)). OMB M-26-05 (Jan 2026) reportedly rescinded mandatory secure-software attestation memos M-22-18/M-23-16 for an agency-led risk approach (unverified) | Agency procurement adoption 2027 | US mandates softened to guidance; SBOM still a procurement artifact |
| **PCI DSS 4.0.1** | Future-dated requirements (incl. secure software development, 6.2.x) mandatory since 31 Mar 2025 | Ongoing | Payment-sector secure coding evidence |
| **UK Software Security Code of Practice** | Voluntary code published May 2025 (from memory, verify) | n/a | UK public-sector procurement signal |

Read-through: in the forecast window the EU, not the US, is the regulatory demand driver. CRA reporting is live but the heavy secure-development obligations land Dec 2027, so **2027 budgets (being set Nov 2026 to Feb 2027) are when CRA-readiness projects get funded.**

---

## 4. PLG and dev-tools growth patterns that work in 2026

| Pattern | 2026 evidence | Sonar angle |
|---|---|---|
| **Reverse trials** | Standard in PLG; Sonar SQC Team reverse trial live from 1 Oct 2026 (14 days, no card, 50/50). Internal control baseline: 2.7 paid orgs per 100 within 21 days (team memory note) | Loss aversion only works if users reach value inside the trial; pair with activation (first analysis, first PR decoration) |
| **Hybrid pricing: platform fee + usage/credits** | Hybrid 25% -> **37%** of companies in 12 months; AI credits 29% today, 33% plan within 6-12 months, ~1 in 2 above $50M ARR; outcome-based ~10%, flat YoY; investors favour hybrid (35%) ([Growth Unhinged 2026](https://www.growthunhinged.com/p/the-state-of-b2b-monetization-in-2026)) | LOC base + per-PR or credit for AI review/remediation. GitHub's "pay for credits you use" normalises this for buyers |
| **Outcome pricing for agents** | Gitar per-PR with unlimited iterations; Copilot per-review credits | "Per verified PR" is easy to compare with human review cost |
| **Free tier as distribution, trial as conversion** | Codacy free IDE guardrails; Qodana free community; Semgrep OSS; Socket free. Counter-signal: Qodo dropped permanent free tier for 14-day trial (secondary) | SonarQube for IDE and Community Build remain the top of funnel; the question is the handoff to Cloud |
| **Time-to-value as a win reason** | Aikido won Energy21 on "speed of trials and immediate implementation" [internal]; AutoScan converts better than CI/CD on GitHub Cloud (team finding) | Zero-config first result in minutes beats feature depth in SMB |
| **Agent / MCP distribution** | MCP under Linux Foundation Agentic AI Foundation (Dec 2025); official registry ~9,650 servers (24 May 2026); Enterprise-Managed Authorization stable; 41% of enterprises with MCP in production (Stacklok via secondary); 30-82% of public MCP servers have exploitable flaws (secondary) ([Wikipedia](https://en.wikipedia.org/wiki/Model_Context_Protocol); [ChatForest](https://chatforest.com/guides/mcp-ecosystem-2026-state-of-the-standard/)) | Being the default verification tool an agent calls is a new acquisition channel. Semgrep Guardian lists Cursor and Claude Code as official partners. Track MCP-originated signups as a first-class channel |
| **Agent config files as onboarding surface** | Repos with agent config files have 8x commits (Octoverse 2026) | Ship a one-line AGENTS.md / skill / hook that wires Sonar into the agent loop; this is the new "add a badge" |
| **AI engines as discovery** | Poyar's newsletter: arrivals via AI engines 5% -> 15%+ during 2026 (single-publisher data) | Docs and comparison pages must be legible to LLMs; "SonarQube vs X" answers in ChatGPT/Claude shape shortlists |
| **Bottom-up to enterprise** | Copilot, Cursor, CodeRabbit all land via devs, expand via admin features (SSO, governance) | Org-level views, SSO/SCIM and policy are the expansion trigger; Codacy's lack of SAML/SCIM is a known gap [internal] |
| **Usage-learned personalisation** | Loss theme: competitors "learn team conventions" [internal]; Copilot automations learn from outcomes | Learned rules/feedback loops reduce false-positive churn and increase switching cost |

---

## 5. Forecast: Nov 2026 to Apr 2027

Each prediction: claim (falsifiable by 30 Apr 2027), confidence, signal behind it, what Sonar should watch.

| # | Prediction | Conf. | Signal | Watch |
|---|---|---|---|---|
| 1 | **GitHub makes Code Quality or core GHAS features available inside GitHub Enterprise without a separate per-committer SKU, or with free usage allowances**, for at least some customers. | 45% | 28 Oct 2026 move to include all Copilot features in GHE with credits; Code Quality priced separately at $10/committer since Jul 2026 | GitHub changelog/pricing page; deals citing "already included in GHE"; GHAS share of named losses |
| 2 | **At least one of Anthropic, OpenAI, Cursor or Google ships or acquires a deterministic static-analysis / SAST capability** (acquisition, or native rules engine beyond LLM review). | 40% | Cursor bought Graphite; Anthropic Code Review GA but "light security"; Copilot AI Scans; agent vendors want to own verification | M&A news; agent release notes; partner conversations about Sonar MCP placement |
| 3 | **Agent-started PRs exceed 50% of PRs on GitHub** in any GitHub-published figure. | 55% | 17% (Mar) -> 40%+ (Sep 2026), 6x volume in 6 months | GitHub blog/earnings; Sonar's own ratio of agent vs human PRs analysed |
| 4 | **Snyk announces a sale, take-private, merger, or another layoff round.** | 40% | CEO exit Feb 2026, ~20% RIF, ARR growth ~7% (Sacra, est.), losses $189M | Press, Companies House filings; Snyk customers entering renewals (displacement window) |
| 5 | **Another AppSec/AI-review deal of $500M+ is announced** (any acquirer). | 50% | Wiz/Google closed, SpaceX/Cursor, Aikido/Root, Checkmarx/Tromzo; CodeRabbit, Socket, Aikido at $1B+ | Deal news; consolidation reshaping who is on shortlists |
| 6 | **CodeRabbit or another top-3 AI reviewer adds a usage/credit or per-PR component** to its list pricing. | 60% | Copilot credits, Greptile per-review overage, Qodo credits, Gitar per-PR; agent PR volume tripling makes seats a poor proxy | Competitor pricing pages (internal pricing-matrix snapshots) |
| 7 | **LOC-based pricing becomes a top-5 recorded objection** in SQ renewals/expansions (H1 2027 win/loss). | 50% | Commits 3x YoY; Codacy and Aikido attack LOC; GitHub per committer | Salesforce loss reasons, ASA keyword "lines of code"/"LOC limit"; LOC overage tickets; downgrade reasons |
| 8 | **CRA appears as a named requirement in a rising share of EU enterprise opportunities** (QoQ increase in Q1 2027 vs Q4 2026). | 65% | Reporting live 11 Sep 2026; full obligations Dec 2027; 2027 budget cycle | ASA/Salesforce keyword "Cyber Resilience Act", "CRA", "SBOM"; SCA attach rate in EU |
| 9 | **A publicly disclosed breach or major outage at a known company is attributed to AI-agent-written code**, prompting a named "AI code governance" policy response. | 55% | 74 AI-linked CVEs by Mar 2026; vibe-coded app exposures; agent PRs merging faster than human PRs | Security press, CVE attributions; inbound mentioning incidents; spike in "governance" searches on sonarsource.com |
| 10 | **OpenAI-Cursor model cutoff (12 Nov 2026) happens or is extended, and agent-vendor lock-in becomes a buyer concern**; Sonar "independence" appears more often as a win reason. | 50% | CNBC 29 Aug 2026; Copilot Fusion multi-model routing; 61% of Copilot users multi-model | Win-reason coding for "vendor-neutral"/"works with any agent"; Cursor model news |

---

## 6. How to refresh this file

Re-check monthly (first week). Update the "As of" date, replace numbers, and move superseded items out.

1. **GitHub changelog + blog** (https://github.blog/changelog/): Code Quality, GHAS, Copilot review pricing, AI credits. Search "GitHub Code Quality pricing" and "Copilot code review" by month.
2. **Internal competitive digest** (Slack channel in the Glean link above, weekly) and Glean query: "competitor insights summary [month]". Also `ai-pr-pricing-matrix` snapshots in sonar-internal-apps.
3. **Latest win/loss analysis** (Glean: "SonarQube_Win_Loss_Analysis"): named competitors, loss themes, share of losses with no reason.
4. **Anthropic, OpenAI, Cursor, Google release notes**: search "Claude Code release notes", "Codex changelog", "Cursor changelog", "[vendor] code review security [month year]".
5. **AppSec funding/M&A**: WebSearch "application security acquisition [month year]", "AI code review funding [month year]"; SecurityWeek funding roundup.
6. **Competitor pricing pages**: CodeRabbit, Qodo, Greptile, Aikido, Snyk, Codacy, Semgrep. Note unit changes (seat -> credit -> PR).
7. **Surveys**: Stack Overflow (annual, Oct), DORA (dora.dev), Octoverse (annual, Oct), Qodo/Sonar State of Code, METR updates. Search "developer survey AI trust [year]".
8. **EU regulation**: EC CRA page (digital-strategy.ec.europa.eu/en/policies/cra-reporting), ENISA SRP news, NIS2 tracker (nisd2.eu), AI Act Omnibus on EUR-Lex.
9. **US policy**: CISA news (cisa.gov/news-events), OMB memos; search "secure software attestation [year]".
10. **Growth/pricing benchmarks**: Growth Unhinged (Kyle Poyar), Lenny's Newsletter, OpenView/High Alpha SaaS benchmarks; search "AI credits pricing [month year]".

Each refresh: score each forecast in section 5 (hit / miss / pending) and add one line on what the miss teaches.

---

## Technical reference: internal documents cited

- Win/loss Jun-Sep 2026: https://docs.google.com/document/d/104XTKQ-wfZGFcSie-zL7uZA_aEi4pmh5rlBPpSoGoss
- Aikido lost deals: https://docs.google.com/document/d/1o2Uy-K0RofcJDudTxEE-xu0hr2FXBNgyFPXbdJgFfTw
- GitHub Code Quality brief: https://docs.google.com/document/d/16dX9WhNvhbWakYkMihejycM42ks9hB9EER_Fwu_7KFA
- Gitar vs CodeRabbit: https://docs.google.com/presentation/d/1BWCoyI2CecbQf6_hWP4xnAiIZk9VNLxU
- Gitar vs Qodo: https://docs.google.com/presentation/d/1PIL2k3_Q0OJ_m2ugQtTRmjigLbuidJRWnw37Y7yc2D8
- Gitar vs Copilot: https://docs.google.com/presentation/d/16gA7vXo57gfjxHqs1hQEw7TqkvdLSfHxMsm6xsqkZSE
- Snyk battlecard: https://docs.google.com/document/d/1lxClQY30IGmz7pqrUrl0xxl1eNrxVNJXuv40vxR_OfY ; Snyk Evo report: https://docs.google.com/document/d/1YSbliiEWDY4jY7vdQQXWZJKIc5ryZbAySM4Uz9BKbIw
- Semgrep battlecard: https://docs.google.com/presentation/d/1OX-hoECVJmyfYovX96NH8mm5NVLdwzEiOXqjUoG0FiQ
- Checkmarx battlecard: https://docs.google.com/document/d/1tRWuw_aYSQtA_INR_LaQquJdT9xo_nfY6-e0fOG838s ; Veracode: https://docs.google.com/document/d/1JZeGyVtP3EnIDM9zmzkDBerEVxb9aaOMsdleRP9SycU ; Black Duck: https://docs.google.com/presentation/d/1IDGHFomQY1NUGG-jR0Qg1AfGyXizE2q_jb35lvwtvMU
- Agentic Code Review QBR 2026: https://docs.google.com/document/d/1zWC7leIMdSg5IaBi3SRY7cbua-cUxnpOIsPu6DD5IOE
- Competitor research, Advanced Security add-ons: https://docs.google.com/document/d/17hLoCJ86s9cxTs1SFVV8ZEqhXePmc2nLVUz-pYfx3jc
