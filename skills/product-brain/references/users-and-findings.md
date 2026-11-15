# Growth squad internal knowledge: reference for flow brainstorming (SQC + SQS)

Classification: **Confidential** (SonarSource). Internal aggregates, ARR, churn and customer names. Do not paste outside approved tools.
Compiled 2026-10-29 from the Growth Shared Drive (`Growth (1H26 Project - CPA3)/`) plus Glean reads of the May 2026 enterprise onboarding interview notes. All paths below are relative to that drive root. Every number cites its file; "not found" means no source in the drive.

Conventions used here: SQC = SonarQube Cloud, SQS = SonarQube Server, RT = reverse trial, "normal" = control arm. Team Monthly (self-serve, Stripe) and Team Annual (sales-led, coupon) are different populations. Do not mix their rates.

---

## TOC

1. Strategy and goals now (H2 2026)
2. Users and segments
3. Established findings with numbers
4. Onboarding and activation funnel today, known drop-offs
5. Permissions and admin pain at scale
6. Experiments: running, results, lessons
7. Known friction list (ranked)
8. Open questions and unsettled debates
9. Data sources, events and tables
10. Glossary
11. Source index

---

## 1. Strategy and goals now (H2 2026)

### 1.1 Squad mandate (standing)
- Reduce first-year churn in SQS and SQC paid plans, especially existing customers; improve activation in both; build the growth operating model across Data, CS, Product (`CLAUDE.md`, `AGENTS.md`).
- Trio: Simone Divakova (PM), Bjorn (EM), Sietze-Jan Sietzema (UX; also owns the SonarOne onboarding workstream) (`strategy/growth-q4-gameplan-2026-10-28.html`).
- Leadership audience: Ori (CPO), Tariq (CEO). Lauren Hanford is decision owner for SonarOne scope; Ali is steering (EVP Transformation) (`strategy/q4-dec15-scope-2026-10-28.md`).
- Operating stance: "not an experimentation org yet"; near-term maturity = instrumentation, rollout discipline, outcome ownership; measurement is part of Done (`publish/growth-ways-of-working-confluence.md`, 2026-08-07).

### 1.2 Q4 2026 commitment, as of 2026-10-28 (SonarOne / Gitar MVP, 15 Dec)
Source: `strategy/growth-q4-gameplan-2026-10-28.html`, `strategy/q4-dec15-scope-2026-10-28.md`. Scope provisional until the **2 Nov M0 lock**.
- SonarOne MVP (program, not Growth-owned): one login, one PR experience (one Sonar comment, duplicates removed, auto-fix), one billing path. Aimed first at **existing SQC customers who want Gitar**; sales-led new customers also in principle.
- Growth's five deliverables by 15 Dec:
  1. **Discovery from login, two states**: sales-led SQC admin sees AI code review exists and how to start it; developer in an entitled GitHub org learns the next PR gets one review.
  2. **Admin trial action**: one button. Either starts a two-week entitlement, or sends the Deal Desk request (MMF-6209) if Billing cannot provision. Sales-led SQC Enterprise and Annual Team, GitHub only.
  3. **Developer explanation**: one review on the PR; fix is opt-in per PR; no bot name until Ori decides branding. Shown only when org is entitled and GitHub app accepted.
  4. **Onboarding v3 cuts** (MMF-6068 / GROW-585) for every new SQC signup: skip /welcome/new, auto-pick DevOps platform when login already did, move optional settings out. **No Gitar step.** Kill rule: roll back any step that drops the share of users who start a scan.
  5. **Measurement**: discovery seen, trial started/requested, explanation seen, AI-reviewed PR within 7 days. No targets without baselines; cross-sell attach is the program metric.
- Explicitly out of Q4: marketplace/catalog, PAYG/checkout/self-serve price, **Gitar inside the 14-day reverse trial**, SQS, SQC on GitLab/Bitbucket/Azure DevOps, Gitar findings in SQ issues/QG/reports, setup page, Slack nudges, IDE, migrating direct Gitar customers.
- Billing constraint: Lauren, 27 Oct: Billing cannot support a self-serve Gitar trial in Q4; 26 Oct: PAYG will not land in Q4 (`strategy/q4-dec15-scope-2026-10-28.md`).
- Gitar defaults: auto-approve off, merge blocking off, auto-apply per-PR command, CI fixer off; Knowledge and cross-repo are Enterprise-only (`strategy/agentic-onboarding-plan-2026-10-27.html`, Julien 27 Oct in `strategy/q4-dec15-scope-2026-10-28.md`). Never write copy saying fixes "apply themselves" or features are "already on" unless confirmed.
- SQS: not in 15 Dec MVP; Gitar capabilities target first 2027 LTA, late Feb 2027. Existing Gitar customers migrate by 15 Dec 2027 ("same pattern as Tidelift").
- Superseded: the 27 Oct agentic onboarding plan (AI review modal for every new signup "included in your 14-day trial", marketplace page MMF-6190) is now history for Q4 scope (`strategy/growth-q4-gameplan-2026-10-28.html`). The 4-workstream structure (modal, v3 cuts, guided first PR + fix, setup page) remains the Q1 shape (`strategy/agentic-onboarding-plan-2026-10-27.html`).

### 1.3 Other live tracks (Q4)
- **Reverse trial MMF-5949** (live since 2026-10-01; decision late Nov). Planning assumption: reverse trial becomes the default door for self-serve Team (`strategy/q4-plg-value-moments-2026-09-08.md`; confirmed in `strategy/team-email-nurture-review-2026-10-15.md`).
- **MMF-6069** "next step after first scan is a serious issue to fix" (READY TO BUILD 29 Oct) and **MMF-6067** "after an organic first fix, a teammate's PR gets reviewed" (`publish/mmf-6069-6067-spec-fixes-confluence.md`).
- **Email nurture MMF-6066 / SF-5280**: replace Stripe trial reminders with 4 trial-end emails (`strategy/team-email-nurture-review-2026-10-15.md`, `notes/email-nurture-opening-2026-10-22.md`).
- **EOAS Q4 scope** (locked 7 Sep with Shubham, Joan, Farah): simplified scanner + PRs at scale (new customers), Bitbucket AutoScan, CLI (SQS, multi-org, ALM binding), Azure + Bitbucket bulk import, permissions at scale, tokenless analysis (`publish/q4-eoas-scope-2026-09-07-slack.md`).
- **Project Coverage page for SQC org admins** MMF-6181 / GROW-471, flag `growthEnableOnboardingDashboard`; SQS shipped equivalent in 2026.5 LTA (21 Sep 2026) (`backlog/mmfs/sqc-project-coverage-dashboard-2026-10-20.md`).
- Weekly update next items: CLI onboarding for remaining DOPs on SQC + SQS version in review; UTM storage for signup attribution; one onboarding path (retire old org-creation flows); cancellation reasons storage (lower priority) (`publish/weekly-update-2026-10-23-growth-confluence.md`).

### 1.4 Commercial targets and KPI apex
- KPI apex: **GRR**; operating apex for SQC Team Monthly = **90-day paid retention** (63.8% of dated churns land in billing months 0–2). SQS stays year-1 (`strategy/kpi-tree-2026-08-24.md`).
- Tariq bar: transactional book −2% today, **+20% by EOY**, ~$60M next year; rest-of-Q4 ~$6.5M. Base not locked with Finance (`strategy/q4-plg-value-moments-2026-09-08.md`).
- Online (Team monthly) ARR $32.6M (~7% of company), GRR ~70%, Team NRR low 80s, Free→paid ~2% (Tariq "walk in the woods", meeting notes, not a finance freeze: `notes/reforge-plg-elena-verna/2026-08-25-tariq-plg-smb-walk-in-the-woods.md`).
- Tariq: "PLG = hands-off was the mistake"; don't invest in individual-developer Cloud for revenue; growth path is the corporate user; every deal <$5k should close online (same file).
- Working thesis: "SQC already has PLG packaging (Free + Team trial + self-serve checkout). It does not yet have a PLG motion." Oct/Nov 2025 "send all leads online" raised signups not revenue; undone 19 May 2026 (`notes/reforge-plg-elena-verna/RUNNING-BRIEF-ori.md`).
- Two Q4 tracks, do not collapse: EOAS (sales-led, product-assisted, no 14-day clock) vs PLG/SMB (product-led acquire/engage; activation supposed to be product-led and today is not) (`strategy/q4-plg-value-moments-2026-09-08.md`).

---

## 2. Users and segments

### 2.1 Use cases (Reforge growth hypothesis, Sonar-filled)
Source: `notes/reforge-plg-elena-verna/2026-08-25-growth-hypothesis-worksheet-filled.md`, `presentations/plg-motion-ori/2026-08-28-five-slides.md`.

| Use case | User job | Buyer | Same person? | Product |
|---|---|---|---|---|
| Code in the workflow | Ship the PR; review AI code; get the PR through the Quality Gate | Often the user under ~$5k; a manager once spend isn't a card | Often, flip point unknown | SQC Free → Team |
| Org risk / audit | Mandated developers live in the PR, see QG as "velocity tax" | CISO / VP Eng / Head of Quality / champion | No | SQS + SQC Enterprise |
| Corporate self-serve Team (target) | Same workflow job at business email, small $ | Team lead / EM with card | Often | SQC Team (Tariq's +20%) |
| Weekend / personal explorer | Try on own repo; verify AI-generated code | Individual if anyone | Yes | SQC Free. "Keep, do not invest" |

Caveat (`⚠` in source): not proven that workflow vs org-risk are two jobs rather than one product used two ways.

### 2.2 Personas from UXR synthesis (Motivational Maps, Mar 2026)
Source: `strategy/motivational-maps-research.md` (Community, Drive UXR, Zendesk, Productboard; qualitative scores).
- **A. Stalled Rollout (enterprise champion, 6–18 months post-purchase)**: CI connected, licenses assigned, devs ignore the tool, QGs are warnings, renewal approaching. Job: prove ROI in business language. Blockers: SSO/identity at scale is the #1 config blocker (8 sources); permissions cannot be automated (5 sources; Deloitte IAM: "You'll kill Entra. Don't do it."; Zebra: "no bulk way of updating anything"); developer cultural resistance ("big brothery"); docs gaps (Azure DevOps). Real alternative: spreadsheets, pen tests, legacy AppSec (Checkmarx, Veracode), GHAS, Snyk.
- **B. Weekend Explorer (individual dev)**: no mandate; engagement budget is a single sitting; failure is silent. Blockers: gap from signup to useful result, CI assumptions, private-repo limits on Free, setup decisions before first scan, dashboards without "what next", noisy findings. Real alternative: asking ChatGPT/Claude to review code, IDE linters, CodeRabbit/Copilot. Done well = "senior mentor", green check on PR, catching something the AI introduced.
- **C. Shelfware Problem (compliance champion)**: scans run, devs override QG. Job: auditable evidence (SOC2, CRA, ISO 27001); outnumbered 50-to-1. Urgency episodic around audits; CRA Sept 2026 cited as forcing function.
- Strategic-area impact scores: Prospect conversion **63.6**, Product adoption 36.3, Enterprise onboarding 24.5, Online upgrade/upsell 12.5 (research gap, not a verdict).

### 2.3 Roles in practice (who does what)
- **Creator / Contributor / Viewer** (hypothesis): creator connects, runs analysis, admin; contributor acts on issues, PR author responding to QG; viewer sees QG on PR without configuring (manager, mandated "always-viewer"). Viewers cannot complete Setup; measure each type separately (`notes/reforge-plg-elena-verna/2026-08-28-activation-team-metrics.md`).
- **Core first person** for self-serve: high motivation x can finish Setup (GitHub org admin, EM who can get CI connected, AutoScan path). Gmail weekend users and mandated QG users are not the first person this flow is for (`notes/ori-onboarding-session-2026-09-04.html`).
- **Enterprise onboarding roles** (Glean read of May 2026 interviews, Sietze-Jan; see 5.4):
  - One lead admin or small group coordinates; brings in Identity/DevOps specialists as needed (Keith, 2026-05-21).
  - **License recipient ≠ technical implementer**; flow must support handover after license key applied (Lukáš, 2026-05-21; Cole, 2026-05-28).
  - Enterprise creator often ≠ SSO configurer; Sonar admin usually doesn't control the IdP (Joe 2026-05-20, Cole, Brett 2026-05-29).
  - Delta Dental: platform engineering sets up enterprise readiness; DevOps integrates pipelines; CyberOps owns SSO; **development teams must initiate analyses** (central team can't safely trigger for them).
  - Excentia (partner): onboarding executed by technical engineers; CTO/CISO dashboards are post-onboarding.
- **Permission roles in auto-sync design**: Engineer, Security Lead, DevOps Coach, AppSec Auditor, Project/Global Admin; scopes org > portfolio > app > project (`publish/permission-auto-sync-design-review-confluence-ready.md`, 2026-06-23).

### 2.4 SQC vs SQS; Team vs Enterprise
- SQC Team plan base: 13,825 Team customers, min 100K LOC, median 200K, 58% in 100–250K band; Free 497,082 orgs avg 17.5K LOC, only 0.4% (2,026) ≥50K; Enterprise 1,597 orgs avg 6.6M LOC (`analysis/team-customer-loc-analysis-2026-06-05.md`).
- Free V2 limits: 50K LOC, 5 users, main branch only, default gates. Team has 20+ features Free V2 lacks. Community Build beats Free on unlimited LOC/users, hotspots, taint, portfolios (`analysis/community-free-team-policy-revised-2026-06-05.md`).
- SQS is not a PLG permission surface ("SQS supply is not immediate"); Enterprise buyer skips the Cloud wizard; migration kills self-serve (`notes/reforge-plg-elena-verna/2026-08-25-growth-hypothesis-worksheet-filled.md`, `notes/ori-onboarding-session-2026-09-04.html`).
- Motion grid (should-be): Team = product-led acquire/activate/engage, monetize product-led <$5k with card else sales-led after usage; Enterprise = sales-led, product-assisted activate/engage, sales-led monetize. Today: Team activation is "neither product-led nor sales-assisted" (outreach ~0, champion still required) (`presentations/plg-motion-ori/2026-08-28-five-slides.md`).
- Factor scores (mostly unearned): Team user motivation is either High (owns PR) or Low (gate is a tax), do not average; ability Low except AutoScan ("Snowflake on setup, Dropbox on AutoScan"); developer permission on company code Low/varied; Enterprise buyer WTP High (same file + worksheet).

### 2.5 Who is coming next
- **Corporate self-serve Team** at business email (Tariq's target). Prefer work email, don't require it (`notes/ori-onboarding-session-2026-09-04.html`).
- **Existing SQC sales-led admins and their developers discovering Gitar AI code review** (SonarOne, 15 Dec) (`strategy/growth-q4-gameplan-2026-10-28.html`).
- **Reverse-trial default users**: every new self-serve user on 14-day Team, no card (`strategy/q4-plg-value-moments-2026-09-08.md`).
- **Developers verifying AI-generated code**: explicit motivation in Weekend Explorer research; AI value gap and GitHub AI cited in churn (`strategy/motivational-maps-research.md`, `presentations/churn-reasons-redesign-2026-06-04.pptx`).
- SDR signal: 1,735 Team users with ≥1M LOC; ~6% not contactable; 113 meetings → 101 opps; Don wants to go to 500k LOC (`notes/reforge-plg-elena-verna/2026-08-25-tariq-plg-smb-walk-in-the-woods.md`).

### 2.6 Jobs-to-be-done (consolidated)
| Who | Job | Evidence |
|---|---|---|
| PR author / developer | Get my change through the gate without surprises; know what to fix | `notes/reforge-plg-elena-verna/2026-08-25-growth-hypothesis-worksheet-filled.md` |
| Tech lead / EM on Team | Shared, trusted read on whether a change is safe to ship, and a way to act when not | `strategy/q4-plg-value-moments-2026-09-08.md` |
| Platform/DevOps admin (Enterprise) | Get every repo scanned at account scale; see which are not; least-privilege permissions without click-ops | `publish/enterprise-onboarding-cli-one-pager-2026-06-18-confluence.md`, Delta Dental concept test |
| AppSec / compliance champion | Produce auditable evidence; enforcement structural, not goodwill | `strategy/motivational-maps-research.md` |
| Buyer (CISO/VP Eng) | Show ROI/adoption at renewal; CISO reads one view in 30s | same |
| Weekend explorer | Honest second opinion in one sitting; verify AI code | same |

---

## 3. Established findings with numbers

Team-standing (do not re-litigate without new evidence; `CLAUDE.md`): setup friction is the root cause of SQS churn (UXR); AutoScan converts better than CI/CD on GitHub Cloud; cohort health correlates with +1 active user/month and +1.5 active projects/month.

### 3.1 SQC Team Monthly churn (self-serve)
| Finding | Number | Source |
|---|---|---|
| Paid Team Monthly lifetime churn, Jun 2025+ cohort | **31.6% count / 24.6% ARR** (2,033/6,430; $1.89M/$7.68M) | `strategy/kpi-tree-2026-08-24.md` (Max, DATA-6809, freeze 2026-07-24) |
| Share of dated churns in billing months 0–2 | **63.8%** (n=1,988) | same |
| Snapshot 31 Jul: churn | 31.2% of paid (2,054/6,577); 22.7% of $ ($1.91M/$8.44M) | `notes/hackathon-cancellation-numbers-2026-10-01.html` |
| Churners by billing month 1–6 | 600 / 431 / 248 / 196 / 153 / 95 | same |
| Churn by users in week 1 | 1 user 43%; 2–3 users 29%; 4+ 18%; median 1 user churners vs 3 stayers | same |
| Paid customers with zero analysed projects in week 1 | **1,157** | same |
| Where churners went | Free 43.5%; org deleted 40.3%; card never recovered 13.9%; silent lapse 2.3% | same |
| By contract move | no tier change 35%; downgraded 32%; upgraded 12% | same |
| Users per org | ≤1 user **50.3%** churn vs 10+ users **12.6%** | `strategy/kpi-tree-2026-08-24.md` |
| Active projects | 0 projects **51.7%** vs 10+ **13.0%** | same |
| Upgraders | upgrade_only **13.6%** vs stable 35.3% | same |
| Paid never analyse | ~8% of paid Team Monthly | same |
| Personal email | 44.8% churn but ~3% of book ARR; never-paid personal 39.9% vs corporate 8.7% | same |
| April 2026 exits (deep dive v2) | 850 exits: 41% suspended, 31% canceled, 28% to Free; $1.45M ARR | `analysis/published/churn-deep-dive-confluence.md` (2026-05-28) |
| Post price-increase churn | 10.8%/month vs 3.7% before | same |
| Zero active projects among churners | 89% (535 accts, $836K); 265 never connected a DOP | same |
| Suspended but analysing within 7 days | 54% (214); 24% recovered later | same |
| Save flow | `cancel_at_period_end` used by 4 of 565K subscriptions ever: effectively no save flow | same |
| First-charge failures | 47% of native suspensions fail at first charge (median tenure 29 days) | same |
| May 2026 YoY Team Monthly | GRR 66.0%, NRR 77.0% (different method from adjusted waterfall) | `publish/monthly-metrics-2026-05.md` |

### 3.2 AutoScan, CI, platforms
| Finding | Number | Source |
|---|---|---|
| AutoScan vs CI first analysis in 30 days | **93% vs 19%**; AutoScan 2.5x Free→Team | `publish/enterprise-onboarding-cli-one-pager-2026-06-18-confluence.md` |
| GitHub + all-AutoScan paid churn | **42%** (n=1,170) vs mixed AutoScan+CI 15–25% | `strategy/kpi-tree-2026-08-24.md` |
| Azure retains | 22.4% count / 16.9% ARR churn | same |
| Rule | "AutoScan converts. AutoScan-only does not retain." Policy proposal: AutoScan to convert, CI/mixed to retain (open) | same |
| Azure AutoScan eligibility | **19.1%** vs ~48% GitHub; fell 21%→17%; top blocker `missing_permissions` 27.3% | `analysis/feature-impact-bulk-import-autoscan-azure-2026-05-26.md` |
| Bulk Import | 1,188 users, 46,593 repos, 99.94% success | same |
| Bulk/Auto Import adoption Mar–May 2026 | 3,053 orgs (27% of active base) | `analysis/churn-by-plan-type-and-creation-proxy-2026-06-04.md` |
| Zero-project rate in paying Team yearly | Bitbucket Cloud 29.5%, Azure DevOps 20%, GitHub 11.7% | `analysis/sqc-team-annual-churn-2026-08-24.md` |
| TFOR speed | Rejected as retention proxy: <20 min self-serve does not predict conversion or 6-month retention (Laura 2026-08-19) | `strategy/kpi-tree-2026-08-24.md` |

### 3.3 Habit and first fix (Sep–Oct 2026)
| Finding | Number | Source |
|---|---|---|
| Orgs with serious issue open within 24h of first scan | 50% (3,195 of 6,431, Sep 15–Oct 13) | `analysis/mmf-6069-6067-fix-window-2026-10-28.md` |
| Fixed within 14 days | 884 (28% of eligible); 81% of those within 7 days; 46% on day 0 | same |
| First scan on trial day 0 | 94% of orgs that scan, both arms | same |
| Came back within 14 days of first scan | 4x as likely still scanning in weeks 3–4 (60–64% vs 14%); fixing adds +4 pts still scanning, +3 pts 2+ members (correlational) | `publish/mmf-6069-6067-spec-fixes-confluence.md` |

### 3.4 Pricing / legacy migration (May 2025 price change)
| Finding | Number | Source |
|---|---|---|
| Legacy cohort | 10,220 customers; paid logos 9,534→6,929 (−27.3%); MRR −14.6% (−$3.77M ARR) | `analysis/legacy-migration-churn-2026-06-04.md` |
| End state | stayed paid 67.8%, canceled 14.2%, suspended 6.5%, Free 11.6% | same |
| Enterprise uplift | 47→151 logos; MRR $41K→$266K | same |
| Excess churn above 3%/mo baseline | ~700 logos (25% of ~2,800 churned in 12 months); directional, not causal | `presentations/slide5-estimating-price-effect-2026-06-09.pptx` |
| Migrated churners' price | $99→$229/month (+130%) | `analysis/published/churn-deep-dive-confluence.md` |
| Team Annual churn | 192 logos, $1.39M (21% of 920 base); 83% of SCT churn opps tagged "Price Increase"; Closed Lost reason blank 133/133 | `analysis/sqc-team-annual-churn-2026-08-24.md` |
| Churn-reasons deck | Argues against further +5%: no tier between 100K and Enterprise; 14-day trial too short; no GitHub Enterprise import; org binding unchangeable; AI value gap. Competitors: Copilot, Codacy, CodeRabbit, Aikido, CodeQL, Semgrep, Cursor Bugbot | `presentations/churn-reasons-redesign-2026-06-04.pptx` |

### 3.5 Portfolio and sales-led
| Finding | Number | Source |
|---|---|---|
| Portfolio adjusted GRR / NRR Feb → Jul YoY | 90.3% → **89.8%**; 114.6% → 113.4%; 1pp GRR = €2.93M | `analysis/grr-nrr-feb-vs-july-2026-08-25.md`, `analysis/grr-nrr-strategy-analysis-2026-03-12.md` |
| SQS EE leak | GRR 88.8%, €20.5M (~61% of total leak) | `analysis/grr-nrr-feb-vs-july-2026-08-25.md` |
| SQC Team Annual GRR | 73.8% → 76.7% | same |
| 25% of new logos churn at first renewal; ~97–98% of SQC Free never converts | | `analysis/grr-nrr-strategy-analysis-2026-03-12.md` |
| 15 SQC EP interviews: biggest issue | Permissions/user management at scale ("Click-Ops"), multi-SCM, rigid templates, SSO | same |
| Year-1 churn Feb 2025–Mar 2026 | $23.56M ARR, 1,816 accts; top reasons Budget 14.8%, Org changes 13.1%, Stopped responding 12.9%, Tool consolidation 12.1%; Pricing only 3.4% | `analysis/year1-churn-analysis-2026-03-13.md` |
| SQS underutilized | 129 customers ≥500 projects <50% LOC used; 23% have undetected DOP | `analysis/sqs-underutilized-customers-2026-07-08.md` |
| AT&T | 21,261 projects, 10.7% active vs peer median ~45–48% | `analysis/att-active-project-rate-comparison-2026-03-21.md` |
| Stalled accounts | Goldman Sachs ~4K onboarded / ~15K idle; Interac 0 projects after 6 months; Deloitte 150M LOC | `publish/enterprise-onboarding-cli-one-pager-2026-06-18-confluence.md` |
| Churn drivers (TA view) | slow project onboarding, under-utilized LOC, no perceived ROI (Roberto, 2026-05-29, Glean) | Enterprise onboarding interviews |

---

## 4. Onboarding and activation funnel today

### 4.1 SQC self-serve flow (v2 `/onboarding/*`, live telemetry since 2026-07-27)
Spine (Mixpanel): `UserOnboardingStarted` → `UserOnboardingDopSelected` → `UserOnboardingPlanSelected` → `OrganizationCreated` → `UserOnboardingCompleted` (`import_method` single/bulk/skipped_project). Alt branches: `AppImported`, `ManualSetupSelected` (`analysis/team-github-onboarding-funnel-spec-2026-08-05.md`).

GitHub → Team snapshot, 27 Jul–6 Aug 2026 (small N):
| Step | Users | Step conv |
|---|---|---|
| Started (v2) | 1,286 | — |
| DopSelected github | 1,109 | 86% |
| PlanSelected team | 71 | **6%** (biggest cliff) |
| OrganizationCreated | 43 | 61% |
| Completed team | 17 | 40% |
Side: Advanced Security addon 29 removed vs 3 added (default-on addon is a tax) (same file).

- Reverse-trial variant removes plan picker and card; `PlanSelected` does not fire there (`notes/reverse-trial-tracking-gap-2026-09-07.md`).
- Live Completed mix 1 Aug–7 Sep: mostly Free (single 989, bulk 407, skipped 123); Team small (60/57/6) (same file).
- Old v1 routes (/welcome, /welcome/new, /create-organization, /projects/create) still exist; MMF-6068 redirects to /onboarding (`analysis/user-onboarding-events-contract.md`, `strategy/agentic-onboarding-plan-2026-10-27.html`).
- Exposure: ~68–73% of users exposed to the flag at org creation end up with a subscription (`experiments/reverse-trial/log.md`, 2026-10-05).
- First scan within 24h: ~72% RT vs ~73% normal for Oct signups (`experiments/reverse-trial/slack-digest-log.md`, 2026-10-28).

### 4.2 Activation definitions (state of the debate)
- Proposed lock (Aug): v2 user reaches `UserOnboardingCompleted` with `import_method ∈ {single, bulk}` within 7 days of DopSelected. Skipped ≠ activated (`analysis/multi-dop-onboarding-analytics-vision-2026-08-06.md`).
- Reforge reframe (Sep, current thinking): **Setup** = DevOps connected + scan running on their code, first session; **Aha** = someone on the team viewed/understood a finding on a change they care about (ideally acted on it / saw it on a PR); **Habit** = QG used to ship or finding acted on, repeating in PR/CI loop, by more than the admin. First analysis dump of 100+ issues can be an **anti-aha**. Login, invite modal, +1 user are not habit (`strategy/q4-plg-value-moments-2026-09-08.md`, `notes/reforge-plg-elena-verna/2026-08-26-reflection-we-dont-know-the-aha.md`).
- E4 (lock Setup/Aha/Habit vs 90-day retention and PQA) is **still open**; shadow new metric beside Mixpanel first-value; do not freeze first-analysis, first-fix or 14 days as KR (same files).
- Closest analogue Snyk: Setup = connect + first scan; Aha = finding seen; Habit = fix (possibly another person). Sonar sits "between Amplitude (consume output) and Snyk (fix)" (`notes/reforge-plg-elena-verna/2026-08-28-activation-team-metrics.md`).
- Habit candidates to score day 0–30 vs day-90 health: analyses on ≥2 days, ≥1 PR analysis, QG fail→pass, issue fixed, second active user, more projects, CI present, issue-email click → action (`analysis/sqc-plg-habit-cohort-analysis-brief-2026-08-10.md`). DS pass not yet delivered.
- Value-moment ordering for Q4 design: habit → aha → setup, designed backward (`strategy/q4-plg-value-moments-2026-09-08.md`).

### 4.3 Target guided journey (Q1 shape, from 27 Oct plan)
7 steps: Connect (v3 flow, repos pre-selected) → First scan (AutoScan main branch) → See one finding (1–3 most severe, plain explanation) → Open a PR ("Fix this in a PR"; email if no PR in 48h) → Fix a first issue (AI fix or by hand) → Merge on green → Team repeats (nudges: invite, Slack, IDE). Setup page "4 of 10 done" holds everything removed from onboarding; nudges only after first scan/first fix; max one in-product nudge per session (`strategy/agentic-onboarding-plan-2026-10-27.html`).

### 4.4 Enterprise / EOAS onboarding
- "Perfect flow": Bulk Import → Auto Import → AutoScan where platform allows; active customer = >50K private LOC (`publish/eoas-whiteboard-2026-06-04-confluence.md`).
- **`sonar onboard` CLI flow (SQS)**: prerequisite GitHub connected → list orgs → check access per org → **diff against already-onboarded** → LOC analysis of unboarded set → if fits license, import all minus archived/inactive; if over, AI recommendation (hard filters, score on activity/contributors/CI presence, pack by score per LOC) shown as Recommended / Borderline / Excluded with one-line reasons (`notes/onboarding-cli-flow-2026-06-04.md`, `publish/onboarding-cli-flow-confluence.md`, root `sonar onboard CLI Flow.html`).
- **`sonar import` (SQC)**: GA without experiment, GitHub-bound orgs, one org per command. Blockers: silent partial failures (GROW-345, e.g. 80/100 imported without reasons), success URL (GROW-406), CLI telemetry (GROW-288/CLI-981) (`strategy/sqc-cli-sonar-import-launch-2026-09-08.md`).
- CLI rationale: only surface for rollout-as-code, parameter-free CI entry point, agentic workflows; 16 Jun pivot toward parameter-free scanner + PR automation at scale (`publish/enterprise-onboarding-cli-one-pager-2026-06-18-confluence.md`).
- SQS DevOps onboarding dashboard / Project Coverage shipped 2026.5 LTA, instance-level only; no portfolio view, unconnected GitLab or monorepo support (`notes/richemont-onboarding-dashboard-email-2026-08-21.md`). Bug: personal GitHub orgs show 1/1 instead of 1/23 (`notes/backlog-candidates-2026-10-23.md`).
- SQS onboarding telemetry: 9 metrics, all hypotheses; decisions D1–D5 open (denominators, "imported" definition, progress formula, history grain, multi-install) (`analysis/sqs-lta-onboarding-telemetry-gap-sheet-2026-08-14.md`).

### 4.5 Known drop-offs (ranked by evidence strength)
1. Plan select + card: DOP → Team **6%** (`analysis/team-github-onboarding-funnel-spec-2026-08-05.md`). Reverse trial targets this.
2. Paid but never scanning: ~8% of paid Team Monthly never analyse; 1,157 with zero analysed projects in week 1; 89% of April churners had 0 active projects (`strategy/kpi-tree-2026-08-24.md`, hackathon numbers, churn deep dive).
3. Org created → Completed 40%; skip-project counts as "Completed" but is not activation (funnel spec).
4. CI path: 19% first analysis in 30 days vs 93% AutoScan (CLI one-pager).
5. Non-GitHub: Azure AutoScan eligibility 19.1%; GitLab/Bitbucket CI-only; higher zero-project rates (feature-impact, Team Annual files).
6. Single-user orgs: 43–50% churn (hackathon, KPI tree).
7. Day 14 in reverse trial: ~80% of ended trials pause without choosing (digest 2026-10-16 to 10-22).
8. Enterprise: connected/imported ≠ analysed (Delta Dental ~1,200 repos; GS ~15K idle) (Glean interviews; CLI one-pager).

---

## 5. Permissions and admin pain at scale

### 5.1 Pain evidence
- 15 SQC EP interviews (customers starting May–Jul 2025): biggest issue = permissions and user management at scale ("Click-Ops"), multi-SCM, rigid templates, SSO (`analysis/grr-nrr-strategy-analysis-2026-03-12.md`).
- UXR: Gamma (templating painful, wants policy-based not repo-name-based); Deloitte (one group per role blocked by IAM); Zebra (no bulk updates); Entra group changes manually recreated; GitHub groups sync flagged as blocker for SC Enterprise (`strategy/motivational-maps-research.md`).
- Heavy template users, June: 25 target accounts from `apply_template`, `bulk_apply_template`, `add_group`, `add_user` (e.g. Inditex 87.5M LOC / 3,500 devs; Xero 45.3M / 1,812; ELCA 37.5M / 1,500); 13 heavy orgs unidentified (`publish/permissions-at-scale-target-accounts-2026-07-03-confluence.md`).
- SCIM/SSO not a broad underutilization cause: 1 of 37 underutilized customers (Enfuce) (`publish/scim-sso-communications-search-slack.md`).

### 5.2 Designs on the table
- **Auto-sync design review** (2026-06-23): recommended path SSO → SCIM → then one of DevOps-platform sync, IaC (YAML), SQ templates, or hybrid. Overlapping groups combine (highest wins). Hourly sync; source of truth wins. Targets <5 min per project setup, 80% fewer admin hours. 18 open questions incl. migrating 5,000 manual permissions across 300 projects, 55-min revocation window for a fired employee, scale test 10K projects / 2K users / 80 rules, export of 20M permission relationships (`publish/permission-auto-sync-design-review-confluence-ready.md`).
- **Wireframe v1 (manual templates)**: 4 templates on 237 projects (standard 156, engineering 63 IdP-synced, security 18); sync within 1h; warning when IdP group missing (`notes/permission-templates-v1-manual.html`).
- **Wireframe v2 (auto-sync)**: 11 screens, GitHub + Okta, 189 projects / 12 rules / 47 teams / 312 users; conflict modes source-wins, manual approval, additive-only; live sync, review/approve, audit log (`notes/permission-templates-v2-auto-sync.html`).
- **Goldman Sachs questions to Raj** (2026-06-29): SQC options SCIM groups → Organizations, or pattern/tag-based project mapping; SQS DCE options IdP group → SQS group → projects, or key-pattern rules. **No answers recorded** (`publish/goldman-sachs-permission-models-sqc-confluence.md`, `...-sqs-dce-confluence.md`).
- Feature placement: custom groups / permission templates = governance moat, unlikely to move to Free (`strategy/feature-placement-policy-2026-06-14-v2.md`).
- SonarOne: Gitar member/admin roles map onto existing SQ permissions; new role model out; design Q4, delivery Q1 (Chris Levis). Open: who can run "fix" commands (proposal: contributors only) (`strategy/q4-dec15-scope-2026-10-28.md`, `strategy/agentic-onboarding-plan-2026-10-27.html`).

### 5.3 SSO / identity sequencing tension
- Keith's ideal SQC sequence: log in → create enterprise → SSO → add orgs → groups via SSO → permission templates → onboard projects. Raymond session: orgs first, since group mapping/templates need them. Brett: break-glass enterprise admin first, copy-paste IdP instructions in UI. Joe: pre-filled email templates for IdP admins; enterprise admins can't be promoted until first login (JIT provisioning confusion) (Glean, May 2026 interviews).
- Customers disagree with SSO-first: Delta Dental preferred persona concept with **"without SSO"** temporary path; Excentia (Mario): time to first analysis is the critical metric; connect DOP → bind repos → first scan, then identity; only one of his clients willing to do SCIM; always creates "Sonar Administrators" and "Sonar Users" groups first (Glean: Delta Dental / Excentia concept validation).
- Synthesis (from Glean read): respect technical dependencies but allow resumable, optional paths; separate first value from governance completion.

### 5.4 Enterprise onboarding interviews (May 2026, Sietze-Jan; Gemini notes via Glean)
Mostly internal experts (CS/SE/TA), plus Delta Dental (customer) and Excentia (partner) concept tests. Olivier's notes are empty.
- Licensing confusion: organization vs enterprise; asked to create a Free org after buying Enterprise; "enterprise key" vs license key; trial-to-production in same instance (Sylvain, Cole, Lukáš, Joshua).
- Platform differences: GitHub easy due to AutoScan; ADO and GitLab need manual intervention (Brett). Orgs-to-platform mapping confusing (Lukáš).
- CI: AI-generated CI YAML aligned with GitOps, auto new-code period from trunk-based workflow (Joshua); validate coverage handling (Raymond).
- Scale: Delta Dental ~1,200 repos, manual binding despite bulk import; wants unanalysed-repo view and QG assignment at onboarding; ROI dashboard "convoluted" on day 1 but needed later "to chase teams".
- Agentic/AI: conditional support. Hybrid with manual decision tree, undo/reset (Joe); AI flow preferred by most Cloud customers, manual for government/SQS (Brett); **Goldman Sachs resisted AI pipeline modification, wanted an "Uber scanner"** inferring exclusions and coverage paths (Roberto); Excentia liked an in-house Sonar LLM for privacy but rejected AI flow that put provisioning before DOP connection.
- Sources: `notes/Enterprise onboarding interviews/*.gdoc` (pointers); content read via Glean 2026-10-29.

---

## 6. Experiments: running, results, lessons

### 6.1 Reverse trial, MMF-5949 / GROW-340 (headline experiment)
Design (`publish/reverse-trial-measure-of-success-confluence.md`, 2026-10-18):
- New users creating a new SQC org, all DOPs, 50/50 on LaunchDarkly flag `growth-enable-reverse-trial`. Variant: Team 1.9M LOC + Advanced Security for 14 days, no card; day 14: add card, move to Free, or paused. Control: pick plan; Team needs card (14-day card trial) or Free.
- Live 2026-10-01; clean data from 11:15 UTC (flag off ~3h). Decision **late Nov 2026** at ~7,000 orgs/arm 21+ days old (detects ~30% difference).
- Main metric: **paying orgs per 100 new orgs**, same age (≥21 days). Money: **cash collected per 100** (not ARR).
- Bar: Keep ≥ control on paying and cash, guardrails hold; Iterate 70–100%; Stop <70% at 6-week read (~Nov 12).
- Guardrails: first scan within 24h ≥5 pts lower; still scanning days 15–28 ≥5 pts lower; split off balance.
- Pre-launch control baseline: **2.7 paid orgs per 100 within 21 days** (240/8,982, Aug 1–Sep 9); card trials 53% paid (182/342); Free upgrades 0.7%, = 24% of payers; first payment ~$98. Never compare RT to card-trial 53%. Power: ≥50% diff in ~2.5 weeks, ≥30% in ~6 weeks, 20% needs ~14 weeks (memory `reverse-trial-break-even.md`, 2026-10-13).

Results so far (latest good read **2026-10-28**, day 27; `experiments/reverse-trial/slack-digest-log.md`):
| Metric | Reverse | Normal |
|---|---|---|
| New orgs since launch | 4,856 | 4,908 |
| Cohort past day 14 (Oct 1–13) | 2,181 | 2,232 |
| Paying orgs | 28 | 60 |
| Paying per 100 (day-14 read) | 0.87 | 2.20 (ratio 0.40, 95% 0.21–0.65) |
| Cash collected | $5,633 | $6,198 |
| Cash per 100 (day-14) | $241 | $242 (ratio 1.00, 0.30–2.79; P(RT ahead) 50%) |
| Cash per paying org | $277 | $110 |
| First scan within 24h | 71.8% | 72.8% (flat) |
- RT status 10-28: in trial 48%, paused 37%, Free 4%, chose Team 51 (28 paying + 23 pending), deleted 10%, moved to Enterprise 20 (<1%). Paths: RT 15 paid during trial ($4,755) + 13 came back after pause ($879); normal 48 card trial ($5,057) + 12 Free upgrades ($1,141).
- Bottom line posted 10-28: "More normal-trial orgs are paying, but reverse-trial payers pick bigger plans, so the money is close for now." The RT cash jump was driven by two large plans (1M $706; 1.5M $1,665).
- 10-29 (day 28): orgs 5,158 / 5,161; RT paused 1,966 (38%); charge query timed out, **no post (safety stop)**.
- Of trials that ended, ~81% paused without choosing (digest 10-16 to 10-22). 22 paused orgs came back by 10-23, 6 on Team (`publish/weekly-update-2026-10-23-growth-confluence.md`).
- Projection (recorded 2026-10-21, `analysis/reverse-trial-projection-2026-10-21.md`): Oct 1–6 cohort day 14 normal $398/100 vs RT $219/100. Normal predicted $979/100 by day 45; RT needs ≥$685/100 to stay in. Later dashboard: normal d49 $696 ($536–856), RT stays-in $487 (`notes/reverse-trial-cash-view-v3.html`, digest 10-28).
- **Real test: second monthly charge Nov 19–30.** Historically ~4 in 10 first payments don't repeat next month; card-trial "forgot to cancel" payers may drop (`publish/weekly-update-2026-10-23-growth-confluence.md`).
- Early volume signal: new subscribers variant/control 0.84 (z −2.65) on Oct 5, 0.875 (z −3.18) through Oct 8; variant users reach org creation as often but fewer subscribe; split verified balanced Oct 2–5 (`experiments/reverse-trial/log.md`). By late Oct new **orgs** ~1:1 (7-day ratio 0.99–1.05) (digest). The org vs subscriber discrepancy is not reconciled in the files.
- Early ops issues: 9 system cancels on day 0 (missing Advanced Security item); 94 user-initiated `cancellation_requested` within minutes (median 14.5 min), 45 re-signed up: suggests a back-out/restart path in onboarding that cancels the subscription; 23 (5%) scheduled to Free within hours via value modal "switch to free" (GROW-442) (`experiments/reverse-trial/log.md`).
- Stripe's trial dashboard (conversion 21.5%) is not comparable; every RT org counts as a trial (`publish/weekly-update-2026-10-23-growth-confluence.md`).
- Live customer harm: Stripe's trial email tells RT users they owe ~$2,000; contact inbox receiving complaints (`notes/email-nurture-opening-2026-10-22.md`).
- Open: 50/50 split check overdue since Oct 14; Massimiliano query review; Stripe reconciliation; commit-then-cancel tracking (digest; weekly update).

Lessons (`analysis/reverse-trial-data-guide-2026-10-27.md` §4b):
- Group orgs only from `subscription_created.trial_type` (any row `CARD_LESS`), never Stripe or latest subscription; choosing Team cancels the RT sub and creates a new one.
- `cad_billing_customers` "canceled" label ≠ churn (unmapped price).
- Compare whole control (card trial + Free), same window, same age; read at **day 49** (after second charge), baseline Aug 1–Sep 30 only.
- Convert every currency (USD/EUR/GBP/JPY; JPY no cents).
- Don't call a winner early; show resampled ranges.
- Elena framing: card is an intent filter; paid rate may be flat; this is "necessary packaging, not the motion"; without ability (E2) and habit (E4) it is "Nov 2025 with nicer copy" (`notes/ori-onboarding-session-2026-09-04.html`).
- If they never scanned, don't ask for a card (Ori-aligned design principle; same file).

### 6.2 Email nurture (MMF-6066 / SF-5280)
`strategy/team-email-nurture-review-2026-10-15.md`:
- Current Team sequence never mentions the trial, end date, or what happens next. RT users get **13 emails in 15 days**, 6 on consecutive days D10–D15.
- Effort 1: 4 trial-end emails keyed to `trial_end_at`: T1 D7 (merged into QG email), T2 D11, T3 D14 morning local time, T4 D15. Stop on card added / deleted / Enterprise / Free (check current subscription). Turn off only Stripe trial reminders; price from actual tier. Sender Jeremy Lang (Digital CS), replies to a read inbox.
- Effort 2: 10 emails in 15 days, 12 by D35; Gitar email moved after D21 (converters/Free movers only); D18 Enterprise suppressed for non-converters; D21 "Your projects are still here"; D35 one-question reply.
- D15 behavior confirmed: Stripe suspends; user sees a choice in product (keep Team with card, or Free). Copy must never say "suspended". Advanced Security included in RT.
- Reaching value slightly behind at the time: first-scan 71.2% vs 74.5% (Oct 1–11, z ~2.1).
- Open: do scans keep running before the D15 choice; who owns RT→Free follow-up; card-trial legal reminder rules; does plan change re-enroll into Free welcome; Tariq alignment ("no commercial overtones until D12").
- 22 Oct sync: one journey this week (audience exit rules, 4 emails, nightly feed for price and end date); Nicolò wants trial-end decoupled from onboarding (`notes/email-nurture-opening-2026-10-22.md`).

### 6.3 MMF-6069 / MMF-6067 (after first scan)
`publish/mmf-6069-6067-spec-fixes-confluence.md`, `analysis/mmf-6069-6067-fix-window-2026-10-28.md`:
- 6069: show the 1–3 most severe issues (Blocker/Critical security or equivalent supply-chain; hotspots don't count) with a way to fix one in a PR. **Main result: org still scanning days 15–28**; secondary: serious issue fixed within 14 days. No email in v1. Assignment logged at first-scan finish for both arms.
- 6067: after a fix, ask for the teammate who opens PRs; count teammate PR reviewed. Recommended window: 7 days after fix, not "before trial ends" (19% of fixers have ≤7 trial days left).
- Blocker: warehouse has no PR author or fixer identity; need a product event with PR author and org-membership; fallback = new member joins + PR analysis within 7 days.

### 6.4 Cancellation flow hackathon (6–8 Oct)
`notes/hackathon-cancellation-flow-plan-2026-10-01.md`, `notes/hackathon-cancellation-numbers-2026-10-01.html`:
- One reason screen, "Continue cancellation" on every screen; no discounts, no extra "look what you lose" screens.
- Reasons → intervention: not using (no projects → get one scanning; real use → one factual line), too expensive (lower tier only if scanning; prototype, no coupon), project ended (Monthly: offer Free; Annual: let leave), setup was hard (help link), missing something (ask what), switching (ask which tool), moving to Annual/Enterprise (confirm, not a failed save).
- Card-failure slice (13.9%) never sees this screen; out of scope.
- Status: storing cancellation reasons is a lower-priority next item after check with Billing (`publish/weekly-update-2026-10-23-growth-confluence.md`). Results of the demo: not found.

### 6.5 Earlier / paused
- Paused GitHub-only "default Team on org create" A/B (Mixpanel board 11464109): not a template (`notes/reverse-trial-tracking-gap-2026-09-07.md`).
- Oct/Nov 2025 "send all leads online": more signups, not revenue; undone 19 May 2026 (`notes/reforge-plg-elena-verna/RUNNING-BRIEF-ori.md`).
- Growth experiment backlog HTMLs exist (`backlog/growth-experiments-2026-10-18.html`, cursor variants); e.g. pre-select up to 3 active AutoScan-eligible repos ("Growth experiments #1") (`strategy/agentic-onboarding-plan-2026-10-27.html`).

---

## 7. Known friction list (ranked)

Ranked by (evidence strength × revenue at stake). Evidence in brackets.

1. **Setup needs a champion; paid orgs never reach a first scan.** ~8% paid never analyse; 1,157 zero-project paid in week 1; 89% of April churners 0 active projects; setup friction = root cause of SQS churn (UXR) [`strategy/kpi-tree-2026-08-24.md`, hackathon numbers, `analysis/published/churn-deep-dive-confluence.md`, `CLAUDE.md`].
2. **Card + plan picker at signup.** DOP → Team 6% [`analysis/team-github-onboarding-funnel-spec-2026-08-05.md`]. Being tested by RT.
3. **Single-player orgs churn.** 1 user 43–50% churn vs 10+ 12.6%; churners median 1 user [KPI tree; hackathon].
4. **AutoScan-only doesn't retain; CI is slow.** 42% churn GitHub all-AutoScan; CI 19% first analysis in 30 days [KPI tree; CLI one-pager].
5. **Anti-aha after first results.** 100+ issues with no next step; dashboards without "what to do next"; noisy findings destroy trust [`notes/reforge-plg-elena-verna/2026-08-26-reflection-we-dont-know-the-aha.md`, `strategy/motivational-maps-research.md`]. MMF-6069 addresses.
6. **Enterprise permissions / SSO / SCIM click-ops.** #1 config blocker (8 sources); 15 EP interviews; SSO-first sequencing blocks first value [motivational maps; GRR strategy; Glean interviews].
7. **Pricing/plan confusion in upgrade and checkout.** Advanced Security tile with green tick reads "included"; prospect lost ("pretty misleading"), GROW-604 high priority; 200K tier disappears between modal and checkout GROW-605; card form errors unclear GROW-603 [`backlog/backlog-candidates-2026-10-27.md`]. Default-on SQAS addon 29 remove vs 3 add [funnel spec].
8. **Trial-end communication wrong or missing.** Stripe email implies ~$2,000 charge; no email mentions trial end; ~81% of ended RT trials pause without a choice [`notes/email-nurture-opening-2026-10-22.md`, nurture review, digest].
9. **Payment failure / no save flow.** 13.9% churn from card never recovered; 47% of native suspensions fail at first charge; save flow effectively nonexistent [hackathon; churn deep dive].
10. **Non-GitHub platforms second-class.** Azure AutoScan eligibility 19.1% (`missing_permissions` 27.3%); ADO/GitLab manual; Bitbucket Cloud 29.5% zero-project [feature impact; Team Annual churn; Brett interview].
11. **Connected ≠ analysed at scale.** GS ~15K idle projects; AT&T 10.7% active; Delta Dental 1,200 repos manual binding; SQC admins have no released coverage view (MMF-6181) [CLI one-pager; ATT file; Glean; project coverage MMF].
12. **Licensing / org vs enterprise model confusion** (enterprise key vs license key; Free org after buying Enterprise; org binding can't be changed) [Glean interviews; churn-reasons deck].
13. **Project import ordering**: repos not sorted by activity; large orgs scroll/search (GROW-601) [`backlog/backlog-candidates-2026-10-27.md`]; import-count bug picker 28/31 vs 31 [`strategy/q4-plg-value-moments-2026-09-08.md`].
14. **Onboarding back-out cancels subscription** (94 early `cancellation_requested`, half re-sign up) [`experiments/reverse-trial/log.md`].
15. **AI value perception gap.** FRISS, TapClicks left for GitHub AI though Team had AI features [`analysis/community-free-team-policy-revised-2026-06-05.md`, `strategy/feature-placement-policy-2026-06-14-v2.md`].
16. **Gitar discoverability / onboarding.** "If Gitar launched in SonarQube today, nobody would find it" (Lauren 21 Oct); Gitar onboarding call: wants direct GitHub App install link, Jira/Linear step confusing, two-step flow like CodeRabbit [`backlog/mmfs/marketplace-page-v1-2026-10-22.md`, `notes/backlog-candidates-2026-10-23.md`].
17. **Settings menu** redesign pending direction (Lauren/Laura) [`backlog/backlog-candidates-2026-10-27.md`].

---

## 8. Open questions and unsettled debates

- **Aha / habit definition (E4)**: which day-0–30 behaviors predict 90-day health and PQA? First fix vs QG fail→pass vs PR analysis vs second active user. Grouping unit for "team" (project, permission group, GitHub org/team) not chosen (`notes/reforge-plg-elena-verna/2026-08-28-activation-team-metrics.md`).
- **Reverse trial verdict**: paying-orgs (behind, ratio 0.40) vs cash (even) — which is the decision metric? Cash can't detect <~60% difference by late Nov (`analysis/reverse-trial-projection-2026-10-21.md`). Late-Nov call after second charge.
- **14 days vs CI/SCA time-to-value**: AutoScan aha fits; CI/SCA takes weeks ("wrong quadrant"); don't stretch 14→30 hoping CI fits (`notes/ori-onboarding-session-2026-09-04.html`).
- **AutoScan to convert, CI/mixed to retain** as GitHub policy: too sharp before day-0–30 confirmation? Azure retention: platform bet or customer-mix artifact? (`strategy/kpi-tree-2026-08-24.md`).
- **What's in the trial / Free**: no Hunter, no LLM agents in Team trial/Free (BYOK exception) per Ori; Advanced Security is included in RT (confirmed) though the Sep doc said not day-0; AI "usage-gated across all tiers" proposal; custom QGs to Free? (`notes/ori-onboarding-session-2026-09-04.html`, `strategy/team-email-nurture-review-2026-10-15.md`, `strategy/feature-placement-policy-2026-06-14-v2.md`).
- **Missing middle tier** between 100K Team and Enterprise; "Branch Analysis" ~$50/month tier option (`analysis/community-free-team-policy-revised-2026-06-05.md`).
- **SonarOne**: which new orgs in scope for 15 Dec (sales-led only vs any new SQC GitHub org); "Team Plan" vs "Annual Team"; real trial vs Deal Desk request; who cuts the unified PR comment if it slips; connectivity date TBC; branding (Ori) (`strategy/q4-dec15-scope-2026-10-28.md`).
- **Marketplace framing**: catalog vs single entry, "install" vs "turn on"; name collision with SQS Administration > Marketplace; nobody knows what "marketplace" means (Chris) (`backlog/mmfs/marketplace-page-v1-2026-10-22.md`). Out of Q4.
- **Enterprise sequencing**: SSO/groups/templates first (internal experts) vs first scan first with "without SSO" path (customers/partner) (Glean interviews).
- **Agentic vs controlled automation**: AI-modified pipelines (Joshua) vs "Uber scanner" inference (Goldman) (Glean).
- **Permissions model at scale**: DevOps-platform sync vs IaC vs templates vs hybrid; GS answers not received (`publish/permission-auto-sync-design-review-confluence-ready.md`).
- **PQA / PLS**: PQA not defined; ≥1M LOC is size not usage; humans only on ICP setup errors, migrations, buyer-skip; who owns E5 (`notes/reforge-plg-elena-verna/2026-08-27-product-led-sales.md`, RUNNING-BRIEF).
- **Work email**: prompt, don't require (consensus in Growth, Tariq favours corporate user).
- **Ownership**: RT→Free email follow-up; setup page code (Growth vs unified onboarding squad); product doors owners (`analysis/product-doors-2026-09-07.md`).
- **D15 scanning behavior**: do scans/PR checks keep running before the keep/Free choice? (`strategy/team-email-nurture-review-2026-10-15.md`).
- **Finance base for +20%**: online ARR vs online + SMB bookings; commission border PLG vs SLG (RUNNING-BRIEF).

---

## 9. Data sources, events and tables

### 9.1 Systems and what they're for
| System | Use | Don't use for | Source |
|---|---|---|---|
| Redshift (`sonarsource`, schemas `product_events.*`, `sonar.*` marts) via **Atlan MCP** (`query_assets_tool`; connection `default/redshift/1720789348`) or SonarData MCP | GRR/NRR, churn $, billing, first scan, experiment readouts | `staging`, `intermediate`, `gtm_source` (Data-Team only, permission denied) | `analysis/reverse-trial-data-guide-2026-10-27.md`, `strategy/kpi-tree-2026-08-24.md` |
| Mixpanel project **Sonarsource-prod (3667556)** | Onboarding funnels, DOP mix, setup health | GRR/ARR, billing identity, calling the RT test | `strategy/kpi-tree-2026-08-24.md` |
| Metabase `metabase.sonardata.io`, **Storefront North Star #397** | TFOR, Storefront KPIs; RT A/B tab | Experiment assignment | same; `publish/reverse-trial-experiment-handoff-2026-09-07.md` |
| LaunchDarkly | Flag `growth-enable-reverse-trial`; split checks via Evaluations/Insights tab | Per-variation unique users not available via MCP | `experiments/reverse-trial/log.md` |
| Stripe | Current subscription state only | Splitting RT groups; trial conversion (21.5% dashboard not comparable) | data guide |
| Marketing Cloud | Email journeys; can get `trial_type`, `trial_end_at`, status | Product-signal emails (not wired) | nurture review |
| Tableau | Live sales-led GRR/NRR | — | `strategy/kpi-tree-2026-08-24.md` |
| RT Readout artifact + daily Slack digest (#mmf-5949-reverse-trial-team) | Single view for RT | — | `publish/weekly-update-2026-10-23-growth-confluence.md`, `.agents/skills/reverse-trial-slack-digest/` |

### 9.2 Mixpanel boards
- SQC self-serve onboarding by platform: board 11432950. Team × GitHub funnel: 11432824. Growth — SQC reverse trial (MMF-5949) health/setup: 11509445. Experiment guide (conventions): 11455441. Growth — Start here: 11473628. Paused default-Team A/B: 11464109 (don't reuse) (`strategy/kpi-tree-2026-08-24.md`, `notes/reverse-trial-tracking-gap-2026-09-07.md`, `publish/reverse-trial-experiment-handoff-2026-09-07.md`).

### 9.3 Key Mixpanel events (FE via GESSIE as `Analytics.Webapp.<Event>`)
- Spine: `UserOnboardingStarted` (`plan_preselected`), `UserOnboardingDopSelected`, `UserOnboardingAppImported`, `UserOnboardingManualSetupSelected`, `UserOnboardingPlanSelected`, `OrganizationCreated` (backend), `UserOnboardingCompleted` (`import_method`).
- Side: `UserOnboardingPricingComparisonOpened`, `PlanChanged`, `FreeToTeamUpsellClicked`, `OrgDetailsEdited`, `LocChanged` (`loc_option`), `AddonAdded/Removed` (`addon_name`: AdvancedSecurity, RemediationAgent, AnalysisAsAService, ContextAugmentation, HunterAgent), `CouponApplied` (Team Annual proxy), `AutoImportDisabled`, `Exited` (`destination`).
- Common fields: `source=ui`, `user_uuid`, `version` (v1/v2), `devops_platform` (github|gitlab|azure|bitbucket|manual; warehouse uses `azure_devops`), `plan` (free|team|oss). Filter Team intent on `PlanSelected`, never on `plan` of Started/DopSelected (URL-polluted) (`analysis/user-onboarding-events-contract.md`, funnel spec).
- First analysis in Mixpanel: `synthetic_first_completed_analysis_by_project` (and `_failed_`); does not join FE user funnels (grain mismatch). Don't use raw `AnalysisFinished` in funnels.
- Billing events: `SubscriptionCreated` (`planname`, `subscriptionchannel` ONLINE_LED/SALES_LED, `loclimit`), `SubscriptionPlanChanged`, `SubscriptionTierUpdated`, `SubscriptionSuspended`, `SubscriptionResumed`, `SubscriptionCanceled`, `SubscriptionAddonAdded`, `SubscriptionBillingPeriodChanged`.
- **Dead events (0 events Aug–Sep 2026)**: `Trial Started`, `Organization Trial to Team`, `... Paid`, `Payment Succeeded`, `Payment Failed`. Not in lexicon: `experiment_name`, `variant`, card/checkout events (`notes/reverse-trial-tracking-gap-2026-09-07.md`).
- Agent usage: `AiAgent*` (e.g. `AiAgentJobCycleCompleted`) (`backlog/mmfs/defer-cc-until-after-team-trial-2026-08-17.md`).

### 9.4 Redshift tables (names; see data guide for SQL)
- Events: `product_events.organization_created`, `subscription_created` (`trial_type` CARD_LESS/CARD_BACKED, `planname`, `loclimit`, `trial_end_date`, `_is_sonar_internal`), `subscription_tier_updated`, `subscription_suspended` (`reason='trial_expired'`), `subscription_resumed`, `subscription_plan_changed` (no tier field), `subscription_canceled` (`organization_deleted`, `Organization added to enterprise`), `analysis_finished` (`analysis_status='completed'` = first scan; `user_uuid` is the scanning account, not the developer), `enterprise_created` (from ~Apr 2026), `subscription_addon_added_table`.
- Marts: `sonar.dim_billing_charges` (VERIFIED; weekdays, 1–3 days behind), `sonar.cad_billing_customers` (entity_id ↔ customer_id; plan label unreliable), `sonar.dim_sc_organization` (`is_internal`, `adjusted_sonar_plan` 'Team' monthly vs 'Team - yearly'; misses ~230 AutoScan first scans), `sonar.dim_sc_organization_enterprise`, `sonar.cad_time_to_first_analysis_of_orgs` (grain = project; `is_autoscan`; dedupe org), `sonar.fct_sc_organization.first_analysis_date`, `sonar.fct_sc_issue_last_6_months` (VERIFIED; use for first-scan issues, backdated), `sonar.fct_sc_sca_issue_enriched`, `sonar.fct_billing_subscriptions`, `sonar.cad_billing_customers_purchase_history` (`is_trial`, `plan_conversion`), `sonar.fct_sales_online_asset_daily` (VERIFIED, online ARR), ARR waterfalls `sonar.fct_sales_child_account_arr_waterfall_yearly` / `fct_sales_online_arr_waterfall_yearly` / `fct_sales_combined_arr_waterfall_yearly`, `sonar.fct_sales_account_product` (SQS utilization), `sonar.cad_sqc_latest_customer_product_usage`, `cad_sf_sqs_account_telemetry_status` (`analysis/reverse-trial-data-guide-2026-10-27.md`, `strategy/kpi-tree-2026-08-24.md`, `analysis/mmf-6069-6067-fix-window-2026-10-28.md`, `analysis/sqs-lta-onboarding-telemetry-gap-sheet-2026-08-14.md`).
- Grain traps: Stripe Team births before Jun 2025 are a backfill spike; count churn ≠ ARR churn; lifetime cohort ≠ waterfall window (~4.6% on $32.5M book); AutoScan config flag ≠ usage; issue tables key on `organization_id` not `organization_uuid_v4`; `is_issue_on_main_branch` unreliable for new orgs (`strategy/kpi-tree-2026-08-24.md`, MMF-6069 analysis).
- Missing telemetry that limits flow measurement: PR author / fixer identity; experiment assignment in Mixpanel; DOP auth success/fail; org-created FE path context; Gitar events joined to SQ orgs (unknown); `creation_flow`, `was_autoscan` (`analysis/multi-dop-onboarding-analytics-vision-2026-08-06.md`, `analysis/feature-impact-bulk-import-autoscan-azure-2026-05-26.md`, agentic plan).

### 9.5 Reference Jira
DATA-6809 (Max's Team Monthly churn), PRODATA-1511–1514 (TFOR, revenue, acquisition, retention KPI definitions), PRODATA-1796 (RT boards) (`strategy/kpi-tree-2026-08-24.md`).

---

## 10. Glossary

| Term | Meaning (as used by the squad) |
|---|---|
| MMF | Minimum Marketable Feature; Jira project MMF-#### holds briefs; delivery in GROW epics/stories |
| GROW-### | Growth squad Jira tickets |
| CPA3 | Part of the drive name "1H26 Project - CPA3"; expansion **not found** in files |
| EOAS | Enterprise Onboarding at Scale (initiative; Slack `#enterprise-onboarding-at-scale`) |
| SonarOne | 2026 program unifying SonarQube + Gitar: one login, one PR experience, one billing (M1 15 Dec 2026) |
| Gitar | AI code review and CI-fixing agent working in the PR (GitHub, GitLab GA; Bitbucket, Azure DevOps beta); 14-day Pro trial standalone; tiers Core/Pro/Enterprise; now part of Sonar (`gitar/apps/external/gitar-docs/*.mdx`, `strategy/q4-dec15-scope-2026-10-28.md`) |
| Vortex / Hunter / Remediation Agent | Sonar agent products; agent doors mostly Contact sales; Vortex 1-click proposed (D35), not live (`analysis/product-doors-2026-09-07.md`) |
| DOP | DevOps platform (GitHub, GitLab, Azure DevOps, Bitbucket); ALM = same concept in code |
| AutoScan | Automatic analysis without CI (GitHub, Azure; Bitbucket in Q4 EOAS) |
| Bulk Import / Auto Import | Import many repos at once / auto-import new repos |
| TTA / TTFA | Time to first analysis (`cad_time_to_first_analysis_of_orgs`) |
| TFOR | Storefront's operational north star (speed metric, PRODATA-1511); full expansion not stated in files; rejected as Growth retention proxy |
| LTA | SQS Long-Term Active release (e.g. 2026.5 LTA, 21 Sep 2026; first 2027 LTA late Feb) |
| NCLOC / LOC | Non-comment lines of code; billing unit. Say "lines of code" in copy |
| GRR / NRR | Gross / Net Revenue Retention (YoY, migration-adjusted waterfall for portfolio) |
| SQS / SQC | SonarQube Server / SonarQube Cloud |
| EE / DCE / Developer | SQS Enterprise / Data Center / Developer editions |
| EP | SQC Enterprise plan |
| Team Monthly / Team Annual | Self-serve Stripe Team vs sales-led coupon Team ("Team - yearly") |
| Free V2 | SQC Free: 50K LOC, 5 users, main branch, default gates |
| SQAS / Advanced Security | SonarQube Advanced Security add-on (SCA, licenses, secrets); included in RT |
| SCA | Software composition analysis (supply chain) |
| QG | Quality Gate |
| RT / reverse trial | 14-day Team (1.9M LOC + Advanced Security), no card; day 14 keep/Free/paused |
| CARD_LESS / CARD_BACKED | `trial_type` values: RT vs card trial |
| D7/D11/D14/D15 | Days relative to trial start in email plan; D15 = choice screen |
| E1–E8 | Experiment seeds from Reforge brief: E1 paid value in Free/trial, E2 first analysis without a champion, E3 defer card (MMF-5949), E4 lock Setup/Aha/Habit, E5 PQA→buyer, E6 <$5k online/marketplace, E7 champion kit, E8 account-management friction |
| PQA / PQL | Product-qualified account / lead; PQA not yet defined |
| PLG / SLG / PLS | Product-led growth / sales-led / product-led sales |
| ICP | Ideal customer profile |
| Setup / Aha / Habit | Reforge activation stages (see 4.2) |
| Anti-aha | First results that overwhelm with no next action |
| Creator / Contributor / Viewer | User types for team activation |
| W2 / P1 / E1 / Q1–Q9 | Named queries in the RT digest skill and data guide |
| CAD | Prefix of curated warehouse tables (`cad_*`); expansion not found |
| GESSIE | Event ingestion pipeline feeding Mixpanel |
| LD | LaunchDarkly |
| Deal Desk / MMF-6209 | Sales-ops activation of Gitar add-on for sales-led SQC Enterprise and Annual Team |
| CRA | EU Cyber Resilience Act (forcing function for compliance personas) |
| Sonar Select | Large enterprise accounts with TA support (e.g. Goldman Sachs) |
| Product doors | Inventory of 39 entry points into the product (1-click, contact sales, download, marketplace) |
| M0 / M1 / M2 | SonarOne milestones: 2 Nov scope lock / 15 Dec MVP / Q1 2027 |

---

## 11. Source index

Strategy and plans
- `strategy/growth-q4-gameplan-2026-10-28.html` — Growth Q4 deliverables to 15 Dec (current)
- `strategy/q4-dec15-scope-2026-10-28.md` — SonarOne charter implications, Billing conflict, owners
- `strategy/agentic-onboarding-plan-2026-10-27.html` — 4 workstreams, 7-step guided journey, setup page (Q1 shape)
- `strategy/friday-review-gameplan-2026-10-27.html` — superseded Friday plan, surface inventory
- `strategy/team-email-nurture-review-2026-10-15.md` — trial-end emails, cadence
- `strategy/q4-plg-value-moments-2026-09-08.md` — Setup/Aha/Habit value moments, capacity map, non-bets
- `strategy/sqc-cli-sonar-import-launch-2026-09-08.md` — `sonar import` launch blockers
- `strategy/kpi-tree-2026-08-24.md` + `publish/growth-kpi-tree-2026-08-24.html` — KPI tree, Team Monthly churn drivers
- `strategy/transactional-motion-proposal-ori-2026-08-28.md`, `presentations/plg-motion-ori/2026-08-28-five-slides.md` — growth hypothesis
- `strategy/feature-placement-policy-2026-06-14-v2.md`, `strategy/feature-placement-catalog-2026-06-14.md` — Free/Team/Enterprise placement
- `strategy/motivational-maps-research.md` — personas A/B/C (Mar 2026 UXR synthesis)

Analysis
- `analysis/reverse-trial-data-guide-2026-10-27.md`, `analysis/reverse-trial-projection-2026-10-21.md`, `analysis/reverse-trial-paying-and-revenue-by-version-2026-10-18.md`, `analysis/reverse-trial-ended-early-orgs-2026-10-13.csv`
- `analysis/mmf-6069-6067-fix-window-2026-10-28.md`
- `analysis/product-doors-2026-09-07.md` (+ .html/.csv)
- `analysis/grr-nrr-feb-vs-july-2026-08-25.md`, `analysis/grr-nrr-strategy-analysis-2026-03-12.md`
- `analysis/sqc-team-annual-churn-2026-08-24.md`
- `analysis/sqs-lta-onboarding-telemetry-gap-sheet-2026-08-14.md`
- `analysis/sqc-plg-habit-cohort-analysis-brief-2026-08-10.md`
- `analysis/team-github-onboarding-funnel-spec-2026-08-05.md`, `analysis/multi-dop-onboarding-analytics-vision-2026-08-06.md`, `analysis/metabase-tta-autoscan-by-dop-2026-08-06.md`, `analysis/user-onboarding-events-contract.md`
- `analysis/sqs-underutilized-customers-2026-07-08.md`, `analysis/sqc-underutilized-customers-2026-07-08.md`
- `analysis/community-free-team-policy-revised-2026-06-05.md`, `analysis/team-customer-loc-analysis-2026-06-05.md`, `analysis/churn-by-plan-type-and-creation-proxy-2026-06-04.md`, `analysis/legacy-migration-churn-2026-06-04.md`
- `analysis/published/churn-deep-dive-confluence.md`, `analysis/Team Monthly Churn — April 2026 Exploration.md`
- `analysis/feature-impact-bulk-import-autoscan-azure-2026-05-26.md`
- `analysis/year1-churn-analysis-2026-03-13.md`, `analysis/year1-success-vs-churn-profiles-2026-03-24.md`, `analysis/att-active-project-rate-comparison-2026-03-21.md`

Experiments
- `experiments/reverse-trial/log.md` (Oct 1–9 ops log), `experiments/reverse-trial/slack-digest-log.md` (daily to Oct 29), `experiments/reverse-trial/results/*.csv`
- `.agents/skills/reverse-trial-slack-digest/` (queries), memory `reverse-trial-break-even.md`, `team-email-nurture.md`

Publish
- `publish/reverse-trial-measure-of-success-confluence.md`, `publish/mmf-5949-experiment-measure-of-success-confluence.md`, `publish/reverse-trial-experiment-handoff-2026-09-07.md`
- `publish/mmf-6069-6067-spec-fixes-confluence.md`, `publish/weekly-update-2026-10-23-growth-confluence.md`
- `publish/q4-eoas-scope-2026-09-07-slack.md`, `publish/enterprise-onboarding-cli-one-pager-2026-06-18-confluence.md`, `publish/onboarding-cli-flow-confluence.md`, `publish/eoas-whiteboard-2026-06-04-confluence.md`
- `publish/permission-auto-sync-design-review-confluence-ready.md`, `publish/goldman-sachs-permission-models-sqc-confluence.md`, `publish/goldman-sachs-permission-models-sqs-dce-confluence.md`, `publish/permissions-at-scale-target-accounts-2026-07-03-confluence.md`, `publish/scim-sso-communications-search-slack.md`
- `publish/exit-interview-gift-cards-confluence.md`, `publish/monthly-metrics-2026-05.md`, `publish/growth-ways-of-working-confluence.md`

Backlog
- `backlog/backlog-candidates-2026-10-27.md`, `notes/backlog-candidates-2026-10-23.md`
- `backlog/mmfs/marketplace-page-v1-2026-10-22.md`, `backlog/mmfs/sqc-project-coverage-dashboard-2026-10-20.md`, `backlog/mmfs/defer-cc-until-after-team-trial-2026-08-17.md`
- `backlog/growth-experiments-2026-10-18.html` (not fully read)

Notes
- `notes/reforge-plg-elena-verna/RUNNING-BRIEF-ori.md` (system of record for E1–E8) and dated session notes (activation, PQA, acquisition, Tariq walk)
- `notes/ori-onboarding-session-2026-09-04.html`, `notes/reverse-trial-tracking-gap-2026-09-07.md`
- `notes/hackathon-cancellation-flow-plan-2026-10-01.md`, `notes/hackathon-cancellation-numbers-2026-10-01.html`, hackathon screen HTMLs
- `notes/email-nurture-opening-2026-10-22.md`, `notes/reverse-trial-readout.html`, `notes/reverse-trial-cash-view-v3.html` (+ appendix)
- `notes/onboarding-cli-flow-2026-06-04.md`, root `sonar onboard CLI Flow.html`
- `notes/permission-templates-v1-manual.html`, `notes/permission-templates-v2-auto-sync.html`
- `notes/richemont-onboarding-dashboard-email-2026-08-21.md`, `notes/cs-onboarding-health-dashboard-wireframes-2026-08-18.md`, `notes/polaris-call-prep-2026-06-08.md`
- `notes/Enterprise onboarding interviews/` (.gdoc pointers; content via Glean): Joe 05-20, Keith 05-21, Lukáš 05-21, Raymond 05-26, Sylvain 05-28, Olivier 05-28 (empty), Cole 05-28, Joshua 05-29, Roberto 05-29, Brett 05-29; Concept tests Delta Dental, Excentia

Presentations and Gitar
- `presentations/churn-reasons-redesign-2026-06-04.pptx`, `presentations/slide5-estimating-price-effect-2026-06-09.pptx`
- `gitar/README.md`, `gitar/apps/external/gitar-docs/` (quickstart, plans, connecting-code), `gitar/docs/internal/plans/auth0-idp-migration-phase-1.md`

Gaps (not found / not read): CPA3 and TFOR expansions; Goldman Sachs permission answers; hackathon demo outcome; summary of "4 exit interviews"; activation baselines for agentic/Gitar metrics; DS day-0–30 habit result; reverse-trial Oct 29 payment numbers (query failed); .gslides strategy decks (pointers only, not read).
