# SonarQube product reference (for flow design and brainstorming)

**Purpose:** let an AI reason about how SonarQube works today and what touches what, without guessing.
**As of:** 2026-10-29. **Classification:** Confidential (contains internal Glean-sourced facts, marked `[internal]`).
**Trust order:** official docs (docs.sonarsource.com) > sonarsource.com pricing/blog > internal (Glean: Jira, Confluence, Drive, Slack).
**Conventions:** `(unverified)` = could not confirm in a primary source this session. `[internal]` = from internal docs, not public. `(prior knowledge)` = long-standing behavior not re-fetched this session.

---

## Table of contents

1. TL;DR for flow designers
2. Product lineup (Oct 2026)
3. SonarQube Cloud plans: matrix, LOC, trials, reverse trial
4. SonarQube Server editions and Community Build
5. SonarQube for IDE, CLI, MCP Server, agent plugins
6. Advanced Security
7. AI and agentic products (AC/DC: Vortex, Gitar, Remediation Agent, Hunter Agent, AI CodeFix, AI Code Assurance)
8. Core concepts (org, enterprise, project, branch, PR, new code, quality gate/profile, issues, hotspots, coverage)
9. Analysis methods (Automatic Analysis vs CI) and scanners
10. DevOps platform integration (binding, import, bulk import, auto-import, monorepo, Project coverage page)
11. Permissions model: Cloud
12. Permissions model: Server
13. Cloud vs Server comparison
14. Identity: authentication, member sync, SSO/SCIM, tokens
15. Billing and licensing mechanics
16. How things interact (concrete chains)
17. Common user friction points
18. Recent changes 2025-2026 and what is coming
19. Open questions / unverified
20. Technical reference (source URLs)

---

## 1. TL;DR for flow designers

- **Cloud has 4 plans: Free, Team, Enterprise, OSS.** Free = 50k private LOC, 5 members, main-branch-only analysis, no custom gates/profiles/groups/templates. Team = 100k to 1.9M LOC, unlimited members, from **$34/month at 100k LOC** (monthly card) or annual coupon. Enterprise = sales-led, enterprise-level LOC pool, SSO/SCIM, portfolios.
- **Reverse trial is live as a 50/50 experiment since 2026-10-01** `[internal]`: new users creating new orgs get 14 days of Team + Advanced Security with no card and no plan picker; day 15 without card = **suspension, not auto-downgrade to Free**.
- **Advanced Security (SCA, advanced SAST, SBOM, licenses, malicious packages, container scanning beta) is a separate subscription.** Public pricing page lists it under Team "Includes" at $34; internal billing shows **$34 without / $56 with** at 100k LOC `[internal]`. Treat the pricing-page copy as inconsistent.
- **Sonar is now a multi-product "agent-centric" platform:** Gitar (AI PR review, acquired 2026-05-21), Sonar Vortex (guide + verify inside coding agents), Remediation Agent (GA 2026-06-30), Hunter Agent (GA Cloud Enterprise 2026-08-27), SonarQube CLI (GA June 2026), MCP Server (Cloud-hosted GA March 2026), agent plugins (Claude Code, Cursor, Codex, Antigravity, Copilot CLI).
- **Nothing works well until the org is bound to a DevOps org.** Binding unlocks repo import, Automatic Analysis, PR decoration auto-config, GitHub member sync, and the Remediation Agent. Manual (unbound) projects require CI analysis.
- **Permissions are union of user + group grants; templates are one-time at project creation.** Free plan cannot change any group permission or template. Org-level Execute Analysis overrides project permissions.

---

## 2. Product lineup (Oct 2026)

| Product | What it is | How sold | Notes |
|---|---|---|---|
| SonarQube Cloud (SQC) | SaaS code quality + security. EU (`sonarcloud.io`) and US (`sonarqube.us`) regions | Free / Team (self-serve) / Enterprise (sales) / OSS | Australia region EA planned Dec 2026, GA Jan 2027 `[internal]` |
| SonarQube Server (SQS) | Self-managed. Developer, Enterprise, Data Center editions | Per instance, per year, by LOC; sales or trial license | Latest LTA **2026.5** (2026-09-29). Two LTAs per year from now on `[internal]` |
| SonarQube Community Build | Free open-source self-managed | Free | Formerly "Community Edition" (prior knowledge) |
| SonarQube for IDE | Free IDE extension (formerly SonarLint) | Free | VS Code, IntelliJ/JetBrains, Visual Studio, Eclipse; also Cursor, Windsurf |
| SonarQube Advanced Security | SCA + advanced SAST add-on | Separate subscription on Team/Enterprise (Cloud), Enterprise/DC (Server) | Rename to "Supply Chain Security" planned early 2027 `[internal]` |
| Gitar | AI code review that writes fixes and iterates until CI passes | Separate product; $20/user/month billed annually (Core plan); Enterprise outcome-based per PR | Acquired 2026-05-21. SQC integration targeted Dec 2026 (TBC) `[internal]` |
| Sonar Vortex | Guide (context before agent writes) + Verify (CI-precision analysis as it writes) | Separate subscription; Cloud annual Team or Enterprise; Server 2026.5+ Enterprise/DC | Launched 2026-06-30 |
| SonarQube Remediation Agent | Agent that opens fix PRs for backlog and PR issues | Separate subscription; Cloud annual Team or Enterprise; Server 2026.5+ Enterprise/DC | GA 2026-06-30 |
| SonarQube Hunter Agent | AI agent that finds access-control, business-logic, auth flaws | Separate subscription; Cloud **Enterprise only**; Server 2026.5+ Enterprise/DC | GA Cloud 2026-08-27 |
| SonarQube CLI (`sonar`) | Terminal tool: secrets scan, local analysis, agent integration, repo import | Free tool; Vortex analysis needs subscription | GA June 2026. Distinct from SonarScanner CLI (`sonar-scanner`) |
| SonarQube MCP Server | MCP access to SonarQube for agents | Free, open source; Cloud-hosted variant on all plans | Cloud-hosted endpoint `api.sonarcloud.io/mcp` |
| SonarSweep | Listed in site footer | (unverified what it is) | Not researched |

Last verified 2026-10-29: sonarsource.com/plans-and-pricing, /plans-and-pricing/sonarqube, docs ACDC readme; Glean comms calendar `[internal]`.

---

## 3. SonarQube Cloud plans

### 3.1 Plan matrix (from docs comparison table)

| Feature | Free | Team | Enterprise | OSS |
|---|---|---|---|---|
| Public projects | Unlimited | Unlimited | Unlimited | Unlimited |
| Private LOC | **50k** | **100k to 1.9M** (choose tier) | Any; enterprise-wide pool | **None** (public only) |
| Org members | **5** | Unlimited | Unlimited | Unlimited |
| Branch analysis | Main branch only | Unlimited | Unlimited | Unlimited |
| PR analysis | Only PRs targeting main | Unlimited | Unlimited | Unlimited |
| Custom quality profiles / gates | No | Yes | Yes | Yes |
| Groups, permission templates | No (built-in only, fixed) | Yes | Yes | Yes |
| GitHub member sync | No (per plan doc + downgrade table) | Yes | Yes (disabled if SSO) | Yes |
| Scoped Organization Tokens | No | Yes | Yes | (unverified) |
| Webhooks | No | Yes | Yes | Yes |
| Jira Cloud integration | No | Yes | Yes | (unverified) |
| Slack integration | Yes | Yes | Yes | (unverified) |
| AI CodeFix | No | Yes | Yes | (unverified) |
| AI Code Assurance, Sonar way for agentic AI gate | Yes | Yes | Yes | (unverified) |
| Cloud-hosted MCP server, Agent apps for GitHub | Yes | Yes | Yes | (unverified) |
| Architecture analysis | No | Yes | Yes | (unverified) |
| Enterprise architecture (cross-project, open beta) | No | No | Yes | No |
| Advanced Security (SCA, adv. SAST) | No | Add-on | Add-on | Advanced SAST included |
| Vortex, Remediation Agent | No | Add-on, **annual Team only** | Add-on | No |
| Hunter Agent | No | No | Add-on | No |
| Enterprise hierarchy, portfolios, dashboards, compliance + PDF reports | No | No | Yes | No |
| GitHub code scanning alerts (security alerts in GitHub) | No | No | Yes | No |
| SSO (SAML, OIDC), SCIM, audit logs, IP allow list | No | No | Yes | No |
| Projects Management page, org-wide project config, QP admin delegation | No | No | Yes (OSS also has Projects Mgmt) | Projects Mgmt only |
| Enterprise languages (ABAP, Apex, COBOL, JCL, PL/I, RPG, Gosu, DataWeave) | No | No | Yes | No |
| Multi-DevOps onboarding into one enterprise | No | No | Yes (not Bitbucket via SSO) | No |
| Project coverage page, bulk import, GitHub auto-import | Yes | Yes | Yes | (unverified) |
| Commercial support | Community only | Purchasable | Included from 5M LOC | Community |

Inconsistency in docs: "Project coverage" is a check for all plans in the comparison table, but the page itself requires org **Administer** permission (any plan).

### 3.2 Pricing facts
- Team "starts at **$34/month** for up to 100k LOC" (pricing page; "previously listed at $65"). Monthly Team got a **~5% price increase**: new customers 2026-07-01, existing in Aug 2026 `[internal]`. Whether $34 already reflects that is (unverified).
- Monthly card billing currencies: EUR, GBP, JPY, USD by billing country (new billing customer portal, new customers only).
- Annual Team and Enterprise: coupon/license via sales. Enterprise: one-year or multi-year license, billed annually.
- LOC tiers available on Team between 100k and 1.9M; exact tier list and per-tier prices (unverified).

### 3.3 Trials
| Trial | Mechanics | Source |
|---|---|---|
| Team standard trial (control) | 14 days free on first monthly card signup; card collected up front; plan picker Free vs Team; first charge day after trial ends | billing-model, pricing FAQ |
| **Team reverse trial (variant, 50/50 since 2026-10-01)** `[internal]` | Brand-new users + brand-new orgs only. Plan picker removed; org created with no payment section. 14 days Team + Advanced Security. Hidden 5M LOC cap. Hunter and Vortex excluded. Card can be added anytime from billing page (silent conversion at day 15). Day 15 without card: org **suspended** (drops to OSS entitlements); friendly screen with two paths: add card (stay Team) or continue on Free. Orgs above 5 members or 50k LOC must remove projects/members first via existing downgrade flow | GROW-340, Confluence "Experiment measure of success: Reverse trial" |
| Advanced Security trial | Monthly Team: self-serve "Start free trial for Advanced Security" in Billing and usage. Annual Team / Enterprise: via sales | signing-up-for-plan |
| Enterprise trial | Sales-led | pricing FAQ |
| Vortex / Remediation / Hunter | Sales-led trial | signing-up-for-plan |
| Server editions | Evaluation license via form; sales activates | Server pricing FAQ |

Control baseline for the reverse trial: 2.7 paid orgs per 100 in 21 days (from team memory, not re-verified this session).

### 3.4 Plan changes
- Free to Team: Billing and usage > Modify plan; first upgrade shows 14-day trial; or apply coupon.
- LOC change (monthly): increase is immediate and pro-rated on next bill; decrease takes effect next cycle. Annual: contact sales.
- Team to Free: takes effect next cycle; wizard enforces 5-member limit, shows feature loss, requires typing org name.
- Feature loss on downgrade (destructive items): **custom groups deleted** (Owners recreated), **permission templates deleted**, **SOTs deleted**, SSO accounts must be deleted first. Non-destructive (hidden, restored on re-upgrade): custom QPs/QGs, webhooks, branch/PR results.
- Downgrade over LOC: cannot analyze all private projects; **CI auto-provisioning will then create public projects** (exposure risk).
- OSS can only move to Free. Legacy paid plan is being retired; must migrate.
- Adding a Team org into an Enterprise cancels the Team subscription with **no refund**.
- Terminate monthly: delete org or downgrade to Free.

Last verified 2026-10-29: docs subscription-plans, billing-model, signing-up-for-plan, changing-plan; sonarsource.com/plans-and-pricing; Glean GROW-340, Confluence 5565513780, reverse-trial appendix (Drive) `[internal]`.

---

## 4. SonarQube Server editions and Community Build

| | Community Build | Developer | Enterprise | Data Center |
|---|---|---|---|---|
| Price | Free, OSS | Per instance/year by LOC | Per instance/year by LOC | Per instance/year by LOC |
| Recommended size | — | 100k+ LOC | 1M+ LOC | (high availability; unverified threshold) |
| Languages | Subset (prior knowledge) | 40 | 48 (adds Apex, COBOL, JCL, PL/I, RPG, VB6, DataWeave, Gosu) | 48 |
| Branch + PR analysis, PR decoration | No; main branch only (prior knowledge) | Yes | Yes | Yes |
| DevOps integrations | (prior knowledge: limited) | One per platform | Unlimited | Unlimited |
| GitHub/GitLab auto-provisioning + permission sync | No | **Yes** | Yes | Yes |
| SCIM (Entra ID, Okta) | No | No | Yes | Yes |
| Applications | (unverified) | Yes (per pricing table) | Yes | Yes |
| Portfolios, executive + compliance reports, audit logs | No | No | Yes | Yes |
| Monorepo PR decoration + guided setup | No | No | Yes | Yes |
| Parallel processing | No | No | Yes | Yes |
| AI CodeFix | No | No | Yes | Yes |
| AI Code Assurance, MCP Server, CLI, plugins | (unverified) | Yes | Yes | Yes |
| Advanced Security | No | No | Add-on | Add-on |
| Vortex, Remediation, Hunter (2026.5+) | No | No | Add-on | Add-on |
| Support | Community | Purchasable | Included from 30M LOC | Included from 30M LOC |

Notes:
- Server public pricing page now shows only Developer and Enterprise cards; Data Center appears only in FAQ. DCE is **not discontinued** `[internal]`; ZIP install for DCE deprecated in 2026.5 (Docker/Helm recommended).
- Agentic add-ons on Server require the **new license management** (Sonar License user portal); old server-ID licenses must migrate `[internal]`.
- Server usage-based products and LOC overage (monthly consumption billing for online EE/DCE) introduced Sept 2026 `[internal]`, details (unverified).
- Server 2026 releases: 2026.1 LTA (Jan), 2026.2 (Mar: new navigation, model-agnostic AI CodeFix), 2026.3 (May), 2026.4 (Jul: architecture, agentic AI quality gate, guided GitHub App setup, scanners need Java 21), 2026.5 LTA (Sep 29: agentic add-ons, LLM governance, org-wide architecture beta). 2026.6 planned Dec 9 (not LTA); 2027.1 LTA ~Feb 2027 `[internal]`.

Last verified 2026-10-29: sonarsource.com/plans-and-pricing/sonarqube; Glean 2026.5 LTA FAQ, comms calendar `[internal]`.

---

## 5. SonarQube for IDE, CLI, MCP Server, agent plugins

### 5.1 SonarQube for IDE
- **Standalone:** free local analysis as you type with built-in rules; focus-on-new-code filter can be enabled manually.
- **Connected mode** (to Cloud, Server, or Community Build) adds: server quality profile and rule settings, file exclusions and analyzer parameters applied locally; issues marked Accepted/False positive on server are suppressed locally; taint (injection) vulnerabilities from server shown in IDE; extra languages unlocked (Apex, COBOL, PL/SQL, T-SQL); "Open in IDE" from web UI; smart notifications (quality gate change, new issues you introduced); AI CodeFix in IDE (VS Code, IntelliJ) when enabled on the org.
- Connected mode **does not push issues to the server**.
- Branch matching: exact name, else closest branch by commit distance, else main. With Cloud, **short-lived branch** issue resolutions are not synced. PR analysis not synchronized.
- Shared binding: one dev exports binding config into repo; others get prompted to bind.
- Auth: Cloud personal access token (user token).
- Known limits: Open in IDE not in remote envs (Codespaces, GitPod); Jupyter notebooks ignore connected mode.
- IDE "AI Integrations" workflow configures only a self-hosted (local) MCP server.

### 5.2 SonarQube CLI (`sonar`)
- Install via Homebrew, Mise, script, or binary. Auth: interactive browser login (keychain), `--with-token`, or env vars (`SONARQUBE_CLI_TOKEN`, `SONARQUBE_CLI_ORG`) for CI/agents.
- **Requires a user token**; project, global, or scoped organization tokens do not work.
- Commands include `sonar list projects`, `sonar analyze secrets`, `sonar analyze --staged` (secrets + Vortex analysis if subscribed), `sonar link`, `sonar import` (**Beta, Cloud only, org admin**: `--all`, `--repo`, `--regex`), Git hooks.
- Integrations: Claude Code, Copilot CLI, Codex, Cursor, Antigravity, OpenCode.

### 5.3 MCP Server
- Self-hosted (stdio/local) or **Cloud-hosted** at `https://api.sonarcloud.io/mcp` (US: `api.sonarqube.us/mcp`), available on all Cloud plans.
- Cloud-hosted: OAuth sign-in or user token; read-only by default (`SONARQUBE_READ_ONLY`), toolsets: analysis, coverage, dependency-risks, duplications, quality-gates, issues, measures, projects, rules, security-hotspots. **No Vortex and no IDE bridge tools** on hosted (need local filesystem). OAuth not supported for Server yet.
- Agent apps for GitHub: one-time tokens mirroring user permissions, valid up to 1 hour; user can disable in My account > Access Tokens > Agent Apps.

Last verified 2026-10-29: docs sonarqube-for-vs-code connected-mode, sonarqube-cli quickstart, sonarqube-mcp-server cloud-hosted, managing-tokens.

---

## 6. Advanced Security

| Capability | Detail |
|---|---|
| SCA: vulnerabilities | CVEs in third-party deps; reachability analysis for prioritization; sources NVD, OSV, EPSS, CISA KEV, checked at least hourly |
| SCA: malicious packages | Against OpenSSF Malicious Packages and others |
| SCA: licenses | License profiles and policies |
| SBOM | Export of dependency inventory; VEX supported on Server 2026.3+ `[internal]` |
| Advanced SAST | Taint analysis into open-source dependency code; JS/TS, Java, C#/.NET (Python top 1k libs added on Server 2026.2 `[internal]`) |
| Container scanning | **Open beta on Cloud since 2026-10-20**, included with Advanced Security; Cloud GA planned late Nov/early Dec 2026; Server by 2027.1 LTA `[internal]` |
| CBOM | GA planned 2026-11-04 `[internal]` |
| UI | Project/portfolio "Dependency Risks" and "Dependencies" |

Packaging:
- Cloud: requires Team or Enterprise plus a separate subscription. Monthly Team adds it self-serve; annual Team and Enterprise via sales; on Enterprise it is enabled at enterprise level. Removal from monthly Team takes effect at end of billing period.
- OSS plan includes Advanced SAST (not SCA).
- Server: Enterprise/DC add-on only.
- Price signal: 100k LOC Team = $34/month without, $56 with `[internal]`.
- Secrets detection is core (not Advanced Security): 400+ patterns, 340+ rules; custom secret rules on Server Enterprise.

Last verified 2026-10-29: docs advanced-security/introduction, signing-up-for-plan; Glean `[internal]`.

---

## 7. AI and agentic products

Sonar frames these as the **Agent Centric Development Cycle (AC/DC)** with three loops:

| Loop | Products |
|---|---|
| Agentic loop (inside the coding agent) | **Sonar Vortex**: Guide (project context, rules, constraints) + Verify (CI-precision analysis of agent changes) |
| CI verification loop (PRs) | **SonarQube** analysis + quality gate; **Gitar** AI code review |
| Code maintenance loop (long-lived branches) | **Hunter Agent** (find), **Remediation Agent** and **AI CodeFix** (fix) |

### 7.1 AI CodeFix
- Cloud Team and Enterprise; Server Enterprise and DC. Org admin enables in Administration > AI capabilities > AI CodeFix, chooses LLM provider, selects All or Only selected projects (new projects not auto-enabled if "selected").
- Rule subset in Java, JS, TS, Python, HTML, CSS, C#, C++. "Generate AI Fix" in web UI; Generate/Apply in IDE (VS Code, IntelliJ connected mode).
- Monthly usage quota per org, reset on the 1st; users see an error when exhausted (quota size unverified).
- Server 2026.2 made AI CodeFix model-agnostic `[internal]`.

### 7.2 AI Code Assurance
- Project admin marks "This project contains AI-generated code" (Administration > AI Code Assurance), then selects an AI-qualified quality gate. Eligible projects can publish an AI Code Assurance badge.
- Built-in **Sonar way for agentic AI** quality gate and **Sonar agentic AI** quality profiles, recommended for agent-centric development. Available on all Cloud plans.
- Server pricing page lists "Autodetect AI-generated code" in Developer; Cloud docs describe only manual labeling (auto-detection on Cloud unverified).

### 7.3 Sonar Vortex
- Cloud: separate subscription on **annual Team or Enterprise**. Nothing to deploy.
- Prerequisites per project: analyzed in **CI on a long-lived branch** (Vortex restores CI analyzer context per project and branch); architecture analysis recommended. Java on Automatic Analysis = basic results only.
- Developers need org key, region URL, **personal access token** (SOTs not supported), project key.
- Runs via SonarQube CLI, agent plugin, or **local** MCP server, not the Cloud-hosted MCP.

### 7.4 Remediation Agent
- Cloud: separate subscription on **annual Team or Enterprise**; Server 2026.5+ EE/DC.
- Requires bound project (GitHub, GitLab, Azure DevOps), analysis enabled (auto or CI), private projects.
- Modes: automated backlog (schedule; 1 PR per repo per run, up to 5 issues), manual backlog ("Fix with Agent", max 20 issues), PR remediation (GitHub/GitLab only; offered when QG fails and PR has 20 or fewer new issues), CI failure recovery (GitHub Actions only, up to 3 retries).
- Fixes maintainability, reliability, selected security issues in C#, Java, JS/TS, PHP (live 2026-10-22), Python; secrets; SCA dependency vulns; Hunter findings (any language).
- **BYO LLM key**: OpenAI or Anthropic; up to 3 keys per org; Sonar picks the model (Claude Opus 4.6 / GPT-5.5). Usage billed to customer's provider account.
- GitHub: a GitHub admin installs the separate **SonarQube Agent** GitHub app (read/write code + PRs). GitLab/ADO reuse the import PAT (GitLab PAT needs `api` scope and Maintainer role).

### 7.5 Hunter Agent
- Cloud **Enterprise only** (separate subscription); Server 2026.5+ EE/DC with self-deployed agent and customer LLM (Opus 4.8 + Sonnet 4.6).
- Finds broken access control (IDOR, missing authz, CSRF), business-logic flaws, auth/session flaws via playbooks; findings appear as regular issues plus a per-project Hunter Agent page. Marketing claims 90% precision.
- Server: instance admin enables once; project admins schedule scans; projects must be bound and analyzed.

### 7.6 Gitar
- AI PR review: inline comments, summaries, walkthroughs, diagrams; writes fixes and iterates until CI passes. Separate signup at app.gitar.ai. Team: $20/user/month annual (Core); Enterprise: outcome-based per PR; free for OSS.
- Gitar SQC integration targeted Dec 2026 (TBC); Gitar SSO and startups program Q4 TBD `[internal]`.

Last verified 2026-10-29: docs ACDC readme, sonar-vortex, administer-remediation-agent, hunter-agent, enable-ai-codefix, ai-code-assurance overview; pricing page; Glean `[internal]`.

---

## 8. Core concepts

| Concept | Definition and key rules |
|---|---|
| **Enterprise** (Cloud only) | Container above orgs, Enterprise plan only. Max 200 orgs. Holds the LOC pool (Shared, or Allocated per org), SSO config, portfolios, Advanced Security entitlement. Created by entering a license key from Sales |
| **Organization** (Cloud) | Billing and permission unit. One-to-one with one DevOps org (GitHub org/personal account, GitLab group, ADO org, Bitbucket workspace). Cannot bind to more than one DevOps platform. Can be bound later; **binding of a bound org cannot be changed**. Free-plan orgs viewable by anyone; Team/Enterprise orgs visible to members only. Org key unique across SQC |
| **Instance** (Server) | Equivalent of the org: one install, one license, global permissions |
| **Project** | Unit of analysis; key unique across SQC. Bound (imported from repo) or unbound (manual). Default visibility private on Cloud import; mirrors repo visibility. Server default visibility for new projects is **public** unless admin changes it |
| **Branch** | Main + long-lived (pattern configurable at org level on Enterprise) + short-lived. Free: only main branch analysis |
| **Pull request** | Analyzed against target branch; only new-code conditions apply; QG status decorated on the PR and can block merge |
| **New code definition** | Previous version, Number of days (default 30, max 90), Specific version, Specific date. Org level supports only first two; project overrides org. No org default set by default. Chosen at project creation |
| **Clean as You Code** | Principle: gate on new code so overall quality improves over time |
| **Quality gate** | Conditions on new and/or overall code. Built-ins: **Sonar way** (default, read-only: no new issues / A ratings, 100% hotspots reviewed, coverage >= 80%, duplication <= 3% on new code) and **Sonar way for agentic AI**. Custom gates from Team. Fudge factor: coverage and duplication ignored under 20 new lines. "Not computed" until second analysis or if no NCD |
| **Quality profile** | Set of active rules per language. Built-in Sonar way profiles; custom from Team; MISRA profiles Enterprise |
| **Rules** | Analyzer checks; 40-48 languages depending on edition/plan |
| **Issues** | Raised when a rule is broken. Affect one or more software qualities (Security, Reliability, Maintainability) with severity (Blocker, High, Medium, Low, Info) (severity scale: prior knowledge). Clean Code attributes on rules (prior knowledge). Auto-assigned to last committer if mapped to a user. Statuses: Open, Confirm, Accept, False positive. Changing status needs Administer Issues |
| **Security hotspot** | Security-sensitive code needing human review; status changes need Administer Security Hotspots. Gate requires 100% reviewed on new code |
| **Coverage** | Imported from CI test reports; **not supported with Automatic Analysis** |
| **Architecture** | Team+ on Cloud: visualize current vs intended architecture; "Administer architecture" project permission |
| **Portfolio / Application** | Cloud: portfolios on Enterprise (cross-org). Server: Applications (Developer+ per pricing table) and Portfolios (Enterprise+) |

Last verified 2026-10-29: docs about-new-code, introduction-to-quality-gates, issues/introduction, permissions, setting-up-your-enterprise.

---

## 9. Analysis methods

| | Automatic Analysis (AutoScan) | CI-based analysis |
|---|---|---|
| Platforms | GitHub, GitLab.com (not self-managed), Azure DevOps. **Not Bitbucket** | Any CI: GitHub Actions, GitLab CI, Bitbucket Pipelines, Azure Pipelines, CircleCI, Jenkins, others |
| Requires bound project | Yes | No |
| Setup | Starts automatically after import if eligible (>= 20% supported-language LOC; Java <= 10MB, Maven/Gradle at root) | Scanner config + token in CI |
| Scope | Default branch + PRs (GitHub: 5 most recent active PRs on first run). **No other branch analysis** | All branches and PRs (plan permitting) |
| Coverage, external reports, logs | **No** | Yes |
| Monorepo | **No** | Yes |
| Languages | All except Objective-C, Dart, Rust; Java has reduced rules (no XSS, fewer Gradle security issues) | All |
| Config | `.sonarcloud.properties` in default branch (ignores `sonar-project.properties`) | `sonar-project.properties` or scanner params |
| Conflict | Running both makes CI analysis **fail and break the build**; must disable one | |
| Vortex | Basic results for Java only | Required for full Vortex precision |

Scanners: SonarScanner for Maven, Gradle, .NET, NPM, Python (prior knowledge), generic SonarScanner CLI; CFamily via build-wrapper or compilation database, with C/C++ AutoConfig on Server and auto analysis on Cloud. Server 2026.4+ scanners need Java 21 `[internal]`.

Org-level (Enterprise plan) admins can disable Automatic Analysis for new projects.

Internal finding (team context): AutoScan converts better than CI/CD on GitHub Cloud.

Last verified 2026-10-29: docs automatic-analysis, monorepo-support.

---

## 10. DevOps platform integration

### 10.1 Binding
- **Org binding** happens by importing a DevOps org. **Project binding** happens only by importing a repo from a bound org. Manual orgs and projects are "empty containers" linked only by `sonar.organization` and `sonar.projectKey` in CI.
- Bound-project benefits: Automatic Analysis, PR decoration auto-configured, privacy mirrors repo, Remediation Agent eligibility.
- Unbound project can be bound later; bound project can be rebound to another repo. Bound org cannot change binding.

### 10.2 Import per platform (Cloud)
| Platform | Mechanism | Notes |
|---|---|---|
| GitHub.com | Install **SonarQubeCloud** GitHub app (must be GitHub org owner); repo access "All" or "Only select" | Legacy **SonarCloud** app may coexist; access must be granted in the new app. Repos not in app scope cannot be imported, analyzed, or decorated. GHE.com and GHES have separate import flows; login for them only via SSO |
| GitLab | Group import with `api`-scoped PAT | Auto analysis gitlab.com only |
| Azure DevOps | Org import with PAT (specific scopes for auto analysis) | |
| Bitbucket Cloud | Workspace import | No Automatic Analysis; SSO users cannot bind (must use Bitbucket account) |

### 10.3 Creating projects
- Needs org **Create Projects** permission and a bound org.
- Select repos > Set up > choose new code definition > Create (auto analysis starts if eligible).
- **Bulk import all repositories:** skips already imported, public repos if org is private-only, private repos if plan lacks private support; GitHub only processes repos authorized in the app. Batches of 25; leaving the tab stops it; CSV report; imported projects auto-favorited (100 favorite cap). Retry after 10-15 min on error.
- **Auto-import new repositories:** GitHub only; on by default at org import; requires app access "All repositories"; only repos created after enabling. Spike in repos can hit LOC cap and pause analysis.
- CLI: `sonar import` (Beta).

### 10.4 Monorepo
- CI-based only; GitHub, Bitbucket Cloud, ADO, GitLab. Wizard "Setup a monorepo": add projects manually or upload JSON (`projectKey`, `projectName`). Sonar cannot detect sub-projects. Flat list, no hierarchy. Each CI build passes its own project key; PR decoration distinguished by project name. Selecting an already bound repo converts it into the monorepo. JSON import silently skips key collisions.

### 10.5 Project coverage page (Cloud)
- Org admin page tracking 3 steps: Organization binding > Repositories imported > Projects analyzed, plus a timeline and an All projects list (filters by analysis status and mode, actions: configure CI, restore access, re-run automatic analysis). Requires Administer (view) and Create projects (import/configure).

Last verified 2026-10-29: docs binding-with-dop, setting-up-project, importing-github-organization, monorepo-support, project-coverage.

---

## 11. Permissions model: SonarQube Cloud

### 11.1 Levels and groups
- Levels: enterprise, portfolio, organization, project. Groups exist **only at org level** (portfolios can use groups from multiple orgs).
- Built-in groups: **Members** (all org members; cannot rename, delete, or edit membership) and **Owners** (creator; Team+ can rename, edit, delete).
- Effective permission = **union** of user grants + all group grants.
- With SSO, **groups are mandatory**: a user is an org member only if in a group of that org.

### 11.2 Permission matrix
| Level | Permission | Grants |
|---|---|---|
| Enterprise | Administer Enterprise | Manage enterprise permissions, add/remove/downgrade/rename orgs, portfolio permission templates |
| Enterprise | Create Portfolios | Create portfolios |
| Portfolio | Administer / Edit / View | Change perms / delete, add-remove projects / view (projects filtered by Browse) |
| Org | Administer organization | Everything incl. members, groups, permissions, templates, recover project admin, bulk apply templates, billing |
| Org | Administer Quality Gates | Create/update gates |
| Org | Administer Quality Profiles | Create/update profiles |
| Org | Execute analysis | Get settings incl. secrets, push results, **scan any project incl. private regardless of project perms** |
| Org | Create projects | Create (import) projects |
| Project | Browse (private) | View project, assign, comment, tag, bulk change |
| Project | See source code (private) | View source (needs Browse) |
| Project | Administer issues | Accept, False positive |
| Project | Administer security hotspots | Change hotspot status (needs Browse on private) |
| Project | Administer architecture | Define intended architecture, patterns, directives |
| Project | Execute analysis | Get settings, push results |
| Project | Administer | Settings, permissions, visibility, delete, webhooks, PDF (needs Browse on private) |

### 11.3 Defaults
| | Members | Owners |
|---|---|---|
| Org level (new org) | None | All (Administer, QG, QP, Create projects, Execute analysis) |
| Project level (default template) | Browse, See source code, Administer issues, Administer security hotspots | Administer, Execute analysis, Administer architecture |

On **Free**, these defaults are fixed and cannot be changed (no group permission edits, no custom groups, no templates). On Team/Enterprise they are editable defaults.

### 11.4 Permission templates (Team+)
- Define permissions for users, groups, **project creator**. One default template + optional templates matched by **full-key regex**. If more than one regex matches, **error** at creation.
- Applied **once** at creation or on manual "Apply"; editing a template does not update existing projects. Bulk apply via Projects Management page (Enterprise plan feature; docs say multi-project apply is Enterprise).
- Deleted on downgrade to Free.

### 11.5 Recovery
- Lost org admin: email contact@sonarsource.com. Org admin can recover project admin access. Enterprise admin recovery has its own page. Docs recommend 2 enterprise admins.

Last verified 2026-10-29: docs permissions, organization-permissions, user-group-concept, templates, managing-the-enterprise-related-permissions.

---

## 12. Permissions model: SonarQube Server

- **Global permissions:** Administer System, Administer Quality Gates, Administer Quality Profiles (also tag rules), Execute Analysis (default on **sonar-users**, which lets all users see branch status of any project; Sonar recommends reviewing), Create Projects, Create Applications, Create Portfolios.
- **Project permissions:** Browse, See Source Code, Administer Issues (also change severity on Server), Administer Security Hotspots, Administer project, Execute Analysis.
- **Built-in groups:** sonar-users (all users), sonar-administrators (recommended to rename for security) (group names: docs + prior knowledge).
- **Default visibility of new projects: public** (anyone incl. anonymous can browse and see source) until admin switches to private.
- **Templates:** same regex logic as Cloud; separate defaults for Projects, Applications, Portfolios; changes require reapplying.
- **Auth methods:** built-in DB, HTTP header, LDAP, SAML (Entra ID, Keycloak, Okta), GitHub, GitLab, Bitbucket Cloud.
- **Provisioning:**
  - JIT (default): user created on first login; groups created by admin; membership synced at login if same-name group exists (overrides local memberships).
  - Automatic: GitHub and GitLab (Developer+) sync users, groups, **and project permissions**; GitHub groups named `Org/Team`; hourly sync; optional project visibility sync; default GitHub role-to-permission mapping, customizable incl. custom roles. Once managed, **permissions on GitHub-managed projects cannot be edited in Sonar**. SCIM with Entra ID/Okta (Enterprise+).
  - Only one automatic provider; enabling it makes the instance "managed" and all other accounts become restricted "local users".
- **Tokens:** user tokens, project analysis tokens, global analysis tokens (prior knowledge). Deactivating a user in the IdP does not revoke Sonar tokens; deactivate in Sonar too.
- Lost admin: SQL queries against the DB.

Last verified 2026-10-29: docs sonarqube-server user-permissions, authentication/overview, authentication/github.

---

## 13. Cloud vs Server comparison

| Topic | Cloud | Server |
|---|---|---|
| Top container | Enterprise > Organization | Instance |
| Billing unit | Org (Free/Team) or Enterprise LOC pool | Instance license by LOC |
| Self-serve purchase | Team monthly by card | No; trial license + sales |
| DevOps binding | Org-to-DevOps-org, one platform per org | Instance-level DevOps platform configs (Developer: one per platform; Enterprise: unlimited) |
| Automatic Analysis | Yes (GitHub, GitLab.com, ADO) | No (CI only) (prior knowledge) |
| Default project visibility | Private on import; mirrors repo | Public unless changed |
| Member source | DevOps login (JIT), GitHub member sync (Team+), SSO/SCIM (Enterprise) | Local, LDAP, SAML, GitHub/GitLab/Bitbucket, SCIM |
| Permission sync from DevOps | **Membership only** (GitHub); groups and permissions **not** synced | **GitHub and GitLab sync users, groups, and project permissions** (Developer+) |
| SSO | Enterprise plan; SAML or OIDC via Auth0; SP-initiated only; one config | SAML, LDAP, etc. on any paid edition (prior knowledge for edition gating) |
| SCIM | Enterprise plan, any IdP | Enterprise+, Entra ID and Okta |
| Machine tokens | Scoped Organization Tokens (`sqco_`, Team+), personal tokens | Project analysis and global analysis tokens (prior knowledge) |
| Free tier | Free plan (50k LOC, 5 members) + OSS plan | Community Build |
| Agentic add-ons | Vortex/Remediation on annual Team or Enterprise; Hunter Enterprise | EE/DC 2026.5+, new license mgmt, self-deployed Hunter, customer LLM |
| Release cadence | Continuous | ~Bimonthly releases; 2 LTAs per year `[internal]` |

---

## 14. Identity: authentication, member sync, SSO/SCIM, tokens (Cloud)

- **DevOps login:** GitHub.com, GitLab, Bitbucket, Azure DevOps via Auth0. JIT account creation on first login. Login names get a random suffix (use email, not login, in automations). GHE.com/GHES users must use SSO.
- **Multiple accounts problem:** an account from platform A does not see an org imported with platform B unless added as member separately.
- **Adding members manually:** org admin adds by **exact email**; user must already have signed up; not possible when GitHub member sync or SSO is active. Unverified email addresses may not appear.
- **GitHub member sync** (Team+, GitHub.com only): enabled by default at import unless SSO. Adds existing Sonar users who are org members; adds new users at signup; mirrors add/remove. **Groups and permissions are not synced.** Can be disabled. Disabled automatically when enterprise enables SSO.
- **SSO** (Enterprise): SAML or OIDC, SP-initiated (IdP-initiated only via Okta Express), shortcut URL `sonarcloud.io/login/sso?enterprise_key=...`, domain verification avoids OTP. SSO users cannot join orgs outside their enterprise. Switching from DevOps auth to SSO creates new accounts with **no history** (comments, favorites lost).
- **SCIM:** provisions/deprovisions users and groups, syncs membership. All SSO user/group membership ops happen in IdP only. Deprovision revokes sessions, deletes SSO account, revokes tokens. Limits: 10,000 groups, 200,000 members per group, no nested groups, 25 req/s.
- **JIT + automatic group sync** (SSO without SCIM): user added to same-name groups at login (case-sensitive), memberships reset each login; user in no group lands on an **empty org page**.
- **Tokens:**
  - Personal access token: 7/30/60/90 days or custom up to 1 year; no-expiry tokens removed after 60 days inactivity; deleted when user deleted. Docs state the Personal Tokens tab is "only available to users signed in with GitHub" (scope of that limitation unverified).
  - Scoped Organization Token (Team+, org admin creates): not tied to a person; `sqco_` prefix; scope = specific projects (Browse, Administer projects, Execute analysis) or org-wide (Administer org, Execute analysis on all, Create projects with custom access). Expiry fixed at creation. Not supported by Vortex or SonarQube CLI. Deleted on downgrade to Free.
  - Agent app tokens: one-time, mirror user permissions, max 1 hour.

Last verified 2026-10-29: docs devops-platform-authentication, github-member-synchronization, organization-members, sso-and-provisioning/about, scoped-organization-tokens, managing-tokens.

---

## 15. Billing and licensing mechanics

- **LOC counted:** sum over **private** projects of the **largest long-lived branch** (Cloud wording; Server: largest branch or PR from most recent analysis). Excludes tests, excluded files, unsupported languages, comments, blank lines. Not per analysis: analyzing 100 times = same LOC. Provisioned-but-unanalyzed main branch counts 0, but a secondary long-lived branch still counts.
- **Exceeding the cap:** Cloud **refuses the analysis** with an explanatory error; no overage. Notification as you approach (org-level caps only; not supported for Enterprise shared pool). Server rejects analyses exceeding license LOC, keeps browsing and config. Server LOC overage via usage billing introduced Sept 2026 for online EE/DCE `[internal]` (unverified details).
- **Public projects never count** on Cloud.
- **Failed payment or expired coupon/license:** private projects **suspended** (no new analyses), data preserved and viewable; reactivate by re-entering card or coupon, or downgrade to Free. Long abandonment leads to deletion after warnings. Enterprise license expiry banner 2 months before.
- **Invoicing:** Team monthly, billed the day after trial ends, auto-renews monthly.
- **Enterprise LOC:** Shared pool by default; can Allocate fixed LOC to specific orgs, others share remainder.
- Future: "compute analysis measurements" to monitor analysis volume planned (pricing FAQ; no date).

Last verified 2026-10-29: docs subscription-plans, billing-model; pricing FAQs (Cloud, Server).

---

## 16. How things interact (concrete chains)

**A. Who can create a project in Cloud, and with what permissions**
1. Org must be **bound** (imported DevOps org) to import repos; otherwise only manual unbound project + CI.
2. On GitHub, the repo must be inside the **SonarQubeCloud app's repository access**; else it is invisible to import, analysis, and decoration.
3. User needs org **Create projects** (Owners have it by default; Members do not). On Free this cannot be granted to Members, so only Owners create projects. A SOT with "Create projects and add custom access" can also create projects.
4. At creation, Sonar picks the permission template: regex match on project key, else default (Team+). On Free, the fixed built-in template applies.
5. Template grants (default): Members get Browse/See source/Administer issues/hotspots; Owners get Administer/Execute analysis/architecture; creator rules per template.
6. Visibility mirrors repo for bound projects; manual projects take whatever the creator sets (exposure risk on Free/after downgrade, where CI auto-provisioning creates public projects).
7. Private LOC is checked at analysis time, not at creation; import can succeed and the first analysis then fails on LOC cap.

**B. Who can see a private project**
Member of org (via DevOps login + manual add, GitHub member sync, or SSO group) AND Browse via user grant, group grant, or template. GitHub repo permissions do **not** flow into Cloud project permissions (Server can sync them).

**C. Who can run analysis**
Org Execute analysis (any project) OR project Execute analysis. Token in CI: personal token (breaks when person leaves) or SOT (Team+). Automatic Analysis needs no token but only for bound projects.

**D. Getting from signup to first gate result (Cloud, GitHub)**
DevOps login > create org > install SonarQubeCloud app (needs GitHub org owner) > pick repo access > choose plan (or reverse trial: no picker) > import repos > set new code definition > Automatic Analysis if eligible (else configure CI) > first analysis > **quality gate computed only after second analysis** > PR decoration on next PR.

**E. Plan drives features drives permissions**
Free plan > no groups/templates/custom QG/QP/branches > single admin model. Upgrade unlocks editing. Downgrade **deletes** groups, templates, SOTs and hides custom gates/profiles.

**F. Advanced Security on a Team org**
Monthly Team > Billing and usage > start AS trial (or included in reverse trial) > SCA runs on analysis > Dependency Risks tab > Remediation Agent can fix SCA vulns if subscribed.

**G. Agentic stack prerequisites**
Vortex needs: subscription + CI analysis on long-lived branch + personal token + local CLI/plugin/MCP. Remediation Agent needs: subscription + bound private project + analysis + BYO OpenAI/Anthropic key + (GitHub) SonarQube Agent app installed by GitHub admin. Hunter needs: Enterprise + subscription. AI CodeFix needs: Team+ and org admin enablement + project selection.

**H. IDE consistency**
IDE connected mode pulls QP and exclusions from the bound project; issues accepted on server disappear locally (long-lived branches only on Cloud). Changing org quality profile changes IDE results without developer action.

**I. Enterprise onboarding**
Sales license key > Create enterprise > import or add orgs (Team org added = subscription cancelled, no refund) > set enterprise admins > per org: verify templates, org-level config > optional SSO + domain verification + SCIM (disables GitHub member sync) > allocate LOC.

---

## 17. Common user friction points

| Friction | Why it happens | Source |
|---|---|---|
| Setup friction is the root cause of SQS churn | Confirmed by UXR (team finding) | Team context |
| Repo missing from import list / PR not decorated | GitHub app repo access set to "Only select", or access granted on legacy SonarCloud app instead of SonarQubeCloud app | importing-github-organization |
| Cannot see org after import | Imported with GitHub account, logged in with ADO/other account | organization-members |
| Cannot add a teammate | They must sign up first; exact email needed; unverified emails hidden; manual add blocked when member sync/SSO on; Free cap 5 members | organization-members, plans |
| Members cannot create projects or change anything on Free | Free locks built-in group permissions | user-group-concept |
| CI build suddenly fails | Automatic Analysis still on while CI analysis added | automatic-analysis |
| No coverage, no branch analysis, no logs | Using Automatic Analysis | automatic-analysis |
| Java/Gradle results thinner on AutoScan | Reduced Java rules; Gradle file must be at root | automatic-analysis |
| Bitbucket users cannot use AutoScan | Not supported | automatic-analysis |
| Quality gate "Not computed" | Only one analysis so far, or no new code definition | introduction-to-quality-gates |
| Analysis refused | LOC cap exceeded; auto-import spikes; trial hidden cap 5M | subscription-plans, importing-github-organization, GROW-340 |
| Enterprise shared pool gives no early warning | Notification not supported for shared pool | subscription-plans |
| Unexpected public project | Manual project visibility, or post-downgrade CI provisioning creates public projects; Server default public | changing-plan, binding-with-dop, Server user-permissions |
| Permissions drift after template edit | Templates are one-time; must reapply | permissions, templates |
| Project creation error | Two template regexes match the key | templates |
| Lost groups/templates/tokens | Downgrade to Free deletes them | changing-plan |
| Pipeline breaks when admin leaves | Personal token used in CI; SOTs only Team+ | scoped-organization-tokens |
| SSO migration loses history | New SSO accounts, no carryover | sso about |
| JIT SSO user lands on empty org | No matching group | sso about |
| Bulk import stops | Navigating away; errors need 10-15 min wait; 100-favorite cap | setting-up-project |
| Monorepo sub-projects not detected | Must be listed manually or via JSON; CI only | monorepo-support |
| Reverse trial end | Day-15 suspension, not downgrade; over-limit orgs must remove projects/members before Free | GROW-340 `[internal]` |
| Pricing page vs product mismatch on Advanced Security in Team | Marketing copy says included, billing says add-on | pricing page vs docs `[internal]` |
| Remediation Agent not offered on PR | More than 20 new issues, unsupported language, ADO (no PR mode), or QG passed | administer-remediation-agent |
| Vortex not working via hosted MCP or with SOT | Requires local filesystem and personal token | sonar-vortex |
| CLI auth errors | Non-user token, wrong region (EU vs US), token predates org membership | CLI quickstart |

---

## 18. Recent changes 2025-2026 and what is coming

### Shipped (2026)
| Date | Change |
|---|---|
| Jan 26-29 | Server 2026.1 LTA |
| Mar 3 | Architecture GA (scheduled) `[internal]` |
| Mar 16 | Cloud-hosted MCP server GA `[internal]` |
| Mar 23-27 | Server 2026.2: new navigation, model-agnostic AI CodeFix `[internal]` |
| Mar 25 | Remediation Agent open beta `[internal]` |
| May 18-21 | Server 2026.3 (Jenkins rules, VEX) `[internal]` |
| May 21 | **Gitar acquired** (public press release) |
| Jun 2 to Jul 1 | Agent plugins: Copilot CLI, GitHub agent app, then Cursor, Antigravity, Codex; Claude Code plugin listed on site `[internal]` |
| Jun 8 / Jun 16 | SonarQube CLI GA (technical / announcement) `[internal]` |
| Jun 30 | **Sonar Vortex launch; Remediation Agent GA** (public blog) |
| Jul 1 / Aug | Monthly Team ~+5% price (new / existing) `[internal]` |
| Jul 22-23 | Server 2026.4: architecture, agentic AI QG, Java 21 scanners |
| Jul 9 / Aug 27 | Hunter Agent beta / **GA on Cloud Enterprise** |
| Sep (A/B) | Pricing page test reducing Free plan prominence `[internal]` |
| Sep 29 | **Server 2026.5 LTA**: Vortex, Remediation, Hunter for self-managed; LLM governance; org-wide architecture beta |
| Oct 1 | **Reverse trial 50/50 experiment live** `[internal]` |
| Oct 20-22 | **Container scanning open beta** (Cloud, with Advanced Security); Remediation Agent PHP |

### Planned (internal targets, not commitments) `[internal]`
| Target | Item |
|---|---|
| Nov 4 2026 | CBOM GA |
| Late Nov / early Dec 2026 | Container scanning Cloud GA |
| Dec 2026 (TBC) | Gitar to SonarQube Cloud integration |
| Dec 7 2026 / Jan 2027 | Cloud Australia region EA / GA |
| Dec 9 2026 | Server 2026.6 (not LTA) |
| Early 2027 | Advanced Security renamed **Supply Chain Security** |
| ~Feb 2027 | Server 2027.1 LTA; container scanning on Server by then |
| TBD | Devin, Factory, OpenCode/Pi integrations; AI BOM; Swift SCA; air-gapped SCA; Gitar SSO, startups |

Last verified 2026-10-29: Glean comms calendar, 2026.5 LTA FAQ, press releases `[internal]`; sonarsource.com blog.

---

## 19. Open questions / unverified

- Whether $34/month Team includes Advanced Security for paying customers going forward (pricing page says yes; billing and docs say no). Needs a pricing owner to confirm.
- Exact Team LOC tiers and prices above 100k; whether $34 is pre- or post-5% increase.
- AI CodeFix monthly quota size; which LLM Cloud uses today (docs variable unrendered; recommends Claude Sonnet 4).
- Whether Cloud auto-detects AI-generated code (Server pricing claims "Autodetect AI-generated code").
- OSS-plan access to SOTs, Jira, AI CodeFix, MCP.
- Community Build exact feature limits (stated from prior knowledge).
- Server token types and edition gating for SAML/LDAP (prior knowledge, not re-fetched).
- Data Center Edition current packaging (missing from pricing page cards).
- "Personal Tokens tab only for GitHub-signed-in users" scope.
- What SonarSweep is.
- Reverse trial results to date (not pulled; see Growth reverse-trial digests).

---

## 20. Technical reference (source URLs)

Public:
- https://www.sonarsource.com/plans-and-pricing/
- https://www.sonarsource.com/plans-and-pricing/sonarqube/
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/subscription-plans
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/billing-model
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/signing-up-for-plan
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/changing-plan
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/permissions
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-organization/users-and-permissions/organization-permissions
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-organization/users-and-permissions/organization-members
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-organization/manage-org-projects/manage-project-permissions/templates
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/about-sonarqube-cloud-solution/user-management/user-group-concept
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/about-sonarqube-cloud-solution/user-management/github-member-synchronization
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/about-sonarqube-cloud-solution/user-management/devops-platform-authentication
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/about-sonarqube-cloud-solution/resources-structure/binding-with-dop
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/enterprise-security/sso-and-provisioning/about
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-organization/scoped-organization-tokens
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-enterprise/managing-the-enterprise-related-permissions
- https://docs.sonarsource.com/sonarqube-cloud/getting-started-with-enterprise/setting-up-your-enterprise
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-organization/creating-organization/importing-github-organization
- https://docs.sonarsource.com/sonarqube-cloud/managing-your-projects/administering-your-projects/setting-up-project
- https://docs.sonarsource.com/sonarqube-cloud/quickstart-guides/project-coverage
- https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/automatic-analysis
- https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/monorepo-support
- https://docs.sonarsource.com/sonarqube-cloud/standards/about-new-code
- https://docs.sonarsource.com/sonarqube-cloud/standards/managing-quality-gates/introduction-to-quality-gates
- https://docs.sonarsource.com/sonarqube-cloud/standards/ai-code-assurance/overview
- https://docs.sonarsource.com/sonarqube-cloud/managing-your-projects/issues/introduction
- https://docs.sonarsource.com/sonarqube-cloud/managing-your-account/managing-tokens
- https://docs.sonarsource.com/sonarqube-cloud/advanced-security/introduction
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/ai-features/enable-ai-codefix
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/ai-features/sonar-vortex
- https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/ai-features/administer-remediation-agent
- https://docs.sonarsource.com/agent-centric-development-cycle/readme
- https://docs.sonarsource.com/agent-centric-development-cycle/in-your-long-living-branches-the-code-maintenance-loop/hunter-agent
- https://docs.sonarsource.com/sonarqube-mcp-server/setup/sonarqube-cloud-hosted
- https://docs.sonarsource.com/sonarqube-cli/quickstart-guide
- https://docs.sonarsource.com/sonarqube-for-vs-code/connect-your-ide/connected-mode
- https://docs.sonarsource.com/sonarqube-server/instance-administration/user-management/user-permissions
- https://docs.sonarsource.com/sonarqube-server/instance-administration/authentication/overview
- https://docs.sonarsource.com/sonarqube-server/instance-administration/authentication/github
- https://www.sonarsource.com/company/press-releases/sonar-acquires-gitar/
- https://www.sonarsource.com/blog/introducing-sonar-vortex/
- https://community.sonarsource.com/t/announcing-the-sonarqube-hunter-agent/187762

Internal `[internal]` (Confidential):
- Jira GROW-340 "Reverse trial v1": https://sonarsource.atlassian.net/browse/GROW-340
- Confluence "Experiment measure of success: Reverse trial": https://xtranet-sonarsource.atlassian.net/wiki/spaces/Storefront/pages/5565513780
- Drive reverse-trial-appendix-additions-prototype.html: https://drive.google.com/file/d/1cpWTIGvS58Xs1Fp_E7iXy28Dwy6Emqvh
- Jira SC-16228 "Introduce the new Free plan": https://sonarsource.atlassian.net/browse/SC-16228
- [WEEKLY] Comms x PMM Product Announcement Sync: https://docs.google.com/document/d/1Fkg0FjcmM6Yx9KmAz7AuLNI7v1krY_OBcUC9S47WJLw
- SonarQube Server 2026.5 LTA FAQ: https://docs.google.com/document/d/1M2WIFn45g8gBSw5P5QqLhhuvjWms6PCxxN9VvO-jDxo
- New products & Overage - SQS Launch Plan (SEP26): https://docs.google.com/document/d/1QQyFn1v8ZeDJaqGa9R7h3PWsSqufCJmjkoxOWCtOpSI
- StoreFront Prime Meeting 2026-07-23 (Team +5%): https://docs.google.com/presentation/d/1Nma-yhHBBblwyiZhuPq0c7iFtMsICQp-xjeFdVkwpaQ
- Launch Readiness Form - Supply Chain Security: https://docs.google.com/document/d/1jEWGnmLPSKWp-hxOgfLnA5K3Xf13c7VHMChs0GcEnkI
