---
name: reverse-trial-slack-digest
description: Short daily Slack digest on how the SonarQube Cloud reverse-trial experiment (MMF-5949, live 2026-10-01, 50/50) is performing and converting, for the CPO, web marketing and product. Refreshes the Reverse Trial Readout dashboard (Claude artifact), then posts to #mmf-5949-reverse-trial-team, #product-web-marketing and the private chat with Ori, Sietze-Jan and Don. Data from the Gessie billing events in product_events and the Redshift sonar.* marts via Atlan. Use for "reverse trial update", "how is the reverse trial doing", "post the reverse trial digest", "daily experiment update", or the daily 09:00 scheduled run. Mondays add a weekly read. For the full analyst log, use reverse-trial-daily (Bjorn's skill) instead.
user-invocable: true
---

# reverse-trial-slack-digest

The exec-facing layer on top of `reverse-trial-daily`. That skill is the analyst log. This one is **one short Slack post a stakeholder can read in 30 seconds**, which sends them to the dashboard for the detail.

## Coaching frame (Elena Verna): what this post is for

A reverse trial does not win on starts. Removing the card guarantees more trial starts, so counting them is a vanity metric. A reverse trial wins only if:
1. more people **reach value** (first scan), and
2. more of them **pay** (count of still-paid Team orgs), while
3. those who don't pay **land on Free and keep using it**, instead of churning.

So every post answers three questions in this order: **Is anyone paying? Are people reaching value? Is anything broken?**

Rules that follow from this:
- **Compare the arms, never pooled totals, never before/after.** Totals rose in both arms after launch (traffic), so a before/after bump is not the experiment.
- **Report daily, decide weekly.** The daily post is a health check. Keep / iterate / kill calls only on Mondays, and only once cohorts are mature.
- **Every charge lands 14–20 days after signup** (both trials charge at day 14). Count payers from signups that have reached day 14.
- **The second monthly charge lands between day 42 and 49** (Aug–Sep history). The fair cash read for the Oct 1–8 signups is day 49 (Nov 19–26), after the Nov 12 six-week read.
- **Don't frame it as a conversion-rate lift** (decision D-1). The keep bar is *more still-paid Team orgs (count)* with setup not worse. See [Experiment measure of success](https://xtranet-sonarsource.atlassian.net/wiki/spaces/Storefront/pages/5565513780).

## Hard rules on data (Simone, 2026-10-23)

- **Normal vs reverse is ALWAYS decided from the billing events**: `product_events.subscription_created.trial_type` (`CARD_LESS` = reverse trial; `CARD_BACKED` card trial or started on Free = normal). Never from Stripe or `cad_billing_customers`. Stripe can't split the groups: choosing Team replaces the reverse-trial subscription, and Stripe shows current state only.
- **One cohort for everything**: orgs from `product_events.organization_created` since 2026-10-01 11:15 UTC. Cash = every succeeded charge since Oct 1 to those orgs (net of refunds, converted to USD per currency: € × 1.12, £ × 1.335, ¥ ÷ 157.7 with no cents; fixed 2026-10-27, never treat a non-USD currency as dollars), whatever the path: card trial, Free upgrade, reverse chose Team, paused then came back, tier change.
- **LOC tier** from the events: `subscription_created.loclimit`, then `subscription_tier_updated.newloclimit` or `subscription_resumed.newloclimit` (latest wins). Free → Team upgrades carry no tier (`subscription_plan_changed` has none); fall back to the `cad_billing_customers` plan for those only.
- `cad_billing_customers.current_billed_product_name = 'canceled'` is **not churn**: it appears when a Stripe price isn't mapped to a plan. Check `subscription_canceled` events for real cancellations.
- Cash includes the Advanced Security add-on where kept. It's on one bill, on by default in both flows, so no adjustment. Reverse-trial payers keep it far less often (4 of 28 vs 26 of 60 on Oct 27); to tell who has it, use the Stripe line in `sonar.fct_billing_subscription_item_change_events` (product "SonarQube Cloud Advanced Security"), not the `subscription_addon_added` event.

- **Exclude Sonar internal orgs everywhere** (Simone, 2026-10-29): drop any org with `sonar.dim_sc_organization.is_internal = true` in any snapshot, or `_is_sonar_internal = true` on its events, in the cohort step of every query (orgs, statuses, payers, cash, first scan, tiers, Advanced Security, history baseline). 23 orgs on Oct 28 (14 reverse, 9 normal), none paying. The flag lags 1–3 days for brand-new orgs.
- Salesforce deal descriptions can contain Enterprise trial license keys: never copy them into posts, logs or files.

## Sources and how to read each one

| Question | Source | Notes |
|---|---|---|
| Trial funnel, groups, tiers | **Billing events** in `sonarsource.product_events` via Atlan `query_assets_tool`, connection `default/redshift/1720789348`, database `sonarsource` | Load nightly ~00:50 UTC with data through yesterday. Queries E1, W2, P1, F1 in `queries.md`. |
| Paying orgs and cash | `sonar.dim_billing_charges` joined via `sonar.cad_billing_customers.entity_id` | 1–3 days behind. Check `max(payment_intented_at)`. |
| Stripe, Mixpanel | Reference only | Not used for the post since 2026-10-14. |

### Background (2026-10-14)
- E1 replaced the Stripe and Mixpanel funnel. Cancellation reasons in `subscription_canceled`: `organization_deleted` → Deleted org; `Organization added to enterprise` → **Joined their company's Enterprise account** (renamed from "Moved to Enterprise" on 2026-10-29). It means a company with a Sales contract or a Sales-issued Enterprise trial added the org to its Enterprise account; never call it an upgrade from the trial. 29 of 35 such orgs on Oct 28 had a Sales relationship before the org existed (analysis/reverse-trial-moved-to-enterprise-2026-10-29.md).
- Data contact while Carlos is out: **Massimiliano Chiorboli**. He owns the A/B readout spec (`no-card-trial-ab-export-spec.md`). Keep the post's buckets aligned with his outcomes, and confirm his "paid" definition.

## Queries

Stored in `queries.md` next to this file (E1, W2, P1, F1, plus reference queries). The dashboard's queries are in the Readout appendix, section 12. All read-only. Append a trailing `/* mcp-query: ts=<UTC> */` to warehouse SQL. Never select emails, names or IDs into the output.

## Steps

0. **Refresh the Reverse Trial Readout before posting.** It's the dashboard the post links to: Claude artifact `https://claude.ai/artifact/5nGJQ2eodLiaFoG9DCZVRn`, built from `notes/reverse-trial-readout.html` (wrapper) plus `notes/reverse-trial-dashboard-mockup-v2.html`, `notes/reverse-trial-cash-view-v3.html` and `notes/reverse-trial-cash-view-v3-appendix.html`.
   - **Currency rule (2026-10-27):** convert every charge with `case payment_currency when 'usd' then net/100.0 when 'eur' then net/100.0*1.12 when 'gbp' then net/100.0*1.335 when 'jpy' then net/157.7 end` (net = amount_charged − refunds; yen has no cents). First list the currencies of succeeded charges since Aug 1; if a new one appears, stop and DM Simone. Before this fix, pounds and yen were counted as dollars (yen also ÷ 100) and normal's cash was ~2.5% low.
   - Rerun the queries behind each number: orgs per group per signup day; payer charges by age (anonymous per-org id); where every org is today; W2; paying orgs by path and tier.
   - Recompute:
     - the fixed cohort: signups up to (data date − 14 days), payers and cash by day 14 per 100 orgs, 4,000-resample 95% ranges
     - normal's weekly projection: day-14 value × the Aug–Sep multiples (days 21–70: 1.16, 1.26, 1.30, 1.36, 2.88, 3.07, 3.16, 3.35; rebuilt 2026-10-27 with the currency fix)
     - the "stays in" (70%) and "beats normal" (100%) lines at day 49
   - A weekly point is actual (filled dot) only when the whole cohort has reached that day.
   - Edit only numbers, dates and the cohort label. Keep wording and layout, and keep the recorded Oct 21 prediction untouched.
   - **Advanced Security split** (appendix section 3c, from 2026-10-29): rerun Q10 from the data guide and replace only the `AS_DATA` block (one entry per day from Oct 14). "With Advanced Security" = the Stripe line in `fct_billing_subscription_item_change_events`, never the `subscription_addon_added` event.
   - **Paused-at-day-14 split** (appendix section 3d, from 2026-11-07): rerun Q11 and replace only the `PAUSE_SPLIT` block (set `asof` to the data date). Keep "No project" (`p0`) as its own column, never fold it into "1 project". Takes about a minute; if it times out after one retry, leave the block as it was and add "paused split not refreshed" to the log line.
   - **Activity after day 14** (main dashboard section, from 2026-11-07): rerun Q12 and Q13 and replace only the `ACT_DATA` block in `reverse-trial-dashboard-mockup-v2.html` (rows: Reverse / Normal card trial / Normal started on Free under Paying; Reverse paused / Normal on Free under Not paying; set `asof`). Never add Reverse on Free to it. Keep the section's text unchanged. If a query fails after one retry, leave the block as it was and note it in the log line.
   - **Statuses and cards** (from 2026-11-07): rerun **Q2v** and replace the status table, the "Paying now" card and the stack bars. Rules:
     - Card "Paying now" = Q2v `1 paying_now` per arm. Pill "−n" next to it = Paid once (P1) minus Paying now, hidden when 0 (Nov 7: Normal −2; Reverse none). Put the reasons (deleted, Enterprise, refunded, moved to Free, suspended) in the "Paid, then stopped" row text.
     - Row order: Paying now, Paid then stopped, On Free, In trial, Paused at day 14, Deleted never paid, Enterprise, test orgs, All new orgs. There is no first-charge-due row (removed 2026-11-07): `5 chose_team_due` + `8 undecided` roll into Reverse "In trial", `5 card_trial_due` into Normal "In trial". Stack bars follow the same merge.
     - Reverse on Free stays its own row but never in the activity section.
   - **Second-charge dates** (fixed text, change only when the cohort window moves): "Still paying next month" cell = "First read Nov 12 / full read Dec 10" (day 42 of Oct 1 signups; day 49 of Oct 22 signups). Lead `next` = "First read Nov 12, full read Dec 10".
   - **Cash view table**: columns say "paid once" (orgs with any succeeded charge, includes later stoppers; cash keeps their payments). Keep the note "Paid once includes orgs that stopped later" and update its count (Normal: 2 deleted).
   - **Lead block** (top of the dashboard): update the `LEAD` object: `rev`/`nor` = paying-now orgs and cash. Bar = Reverse as % of Normal (Normal = 100%), scale clamps at 130%, tick at 76.9%. Chip rule, symmetric and never leading with who is ahead: "Too early to call" (until the second charge, Nov 19 to Dec 10) then "Leaning Normal/Reverse" then "Normal/Reverse wins". Keep `note` and `next` wording unless the stage changes.
   - **Hard-coded sentence numbers**: "Will normal's lead hold" section: Paid once per arm, the "~n if usual 4 in 10 drop off" figure (Paid once × 0.57, rounded), "% are still scanning" (Q13 payer total) and "paused" count (Q2v `7 paused`). Update the meta line "data to {date}", the shell status badge date ("updated {date}", "latest payments {date}") and the footer first-scan figures.
   - **Reconciliation checks C1 to C7** (in `queries.md`): run all before republishing. Any failure is a safety stop. Log the results in one line.
   - **Overdue first charge** (Q14): log the count each run. Health line "{n} Normal-trial orgs past trial end without a charge" when up 20% or more versus yesterday's log. Don't add it to the dashboard.
   - **New reasons:** a cancel or suspend reason not in Q2v (deleted, Enterprise, trial_expired, License got expired, Transitioning to online-led subscription) is a Health line, never silently bucketed.
   - Republish: Artifact `action: "read"` on the URL first, then publish the wrapper with that `url` and `files` mapping the three file names.
   - **Safety stop:** if a query fails after one retry or totals drop versus the log, don't republish. Keep yesterday's version, add a Health line "Dashboard not refreshed today" and DM Simone the reason. Never publish half-updated numbers. Never let this block the post.
1. Take the post's numbers from the same queries as the dashboard (step 0), so the post and the page never disagree: paying orgs and cash from signups that have reached day 14, where reverse-trial orgs are today, and W2 for first scan. E1 stays as the cross-check for the trial statuses.
2. Check the guardrails. If one trips, add a **Health** line, tagging `<@U07B8J4FMNE>` (Simone) and `<@U05HA0AGC8P>` (Bjorn) in the team channel only.
3. Write the post using the template below. No emojis.
4. **Post the same message to THREE conversations, every day including weekends:**
   - #mmf-5949-reverse-trial-team (`C0BU83SFESG`)
   - #product-web-marketing (`C0BUHM12UGL`, public)
   - Private conversation with Ori, Sietze-Jan, Don Norton and Simone (`C0C7FJ5U9DJ`)
   Rules for these conversations:
   - Always end with the dashboard call to action in all three.
   - Tag people in a Health line only in the team channel; in the other two, post the Health line without tags.
   - Post the Monday weekly read thread only in the team channel.
   **Post directly. No approval step** (Simone, 2026-10-13, overriding the team's review-first default for this post only).
   - **Safety stop:** don't post if any of these is true:
     - a data source failed
     - the total of reverse-trial orgs is lower than yesterday's logged total
     - any figure moved more than 30% day-over-day without an obvious reason
     - a payment currency other than usd, eur, gbp, jpy appeared
   - In those cases, DM the draft to Simone (`U07B8J4FMNE`) with a one-line reason instead.
5. Append a dated, aggregates-only line to `experiments/reverse-trial/slack-digest-log.md`: whether the dashboard was refreshed, paying now and paid once per arm, the C1 to C7 results, and the overdue-charge count.

## Guardrails (tag Simone + Bjorn when tripped)

| Guardrail | Trips when |
|---|---|
| Setup failures | Any reverse-trial sub canceled ≤10 s after creation in the last day |
| Manual cancels | Last-day cancel share > 2× the running average (running ≈7% on 2026-10-13) |
| Org ratio | Variant ÷ control orgs (last 7 days) < 0.85 or > 1.15 |
| Activation | Variant first-scan-in-24h is ≥5 points below control on ≥300 orgs per arm |
| Trial end (from Oct 15) | Paused share at day 14 jumps, or first-charge failures appear |
| Still scanning after day 14 (from Oct 29) | Query **F1**: share of orgs with a completed scan in days 15–28 after creation. Trips when reverse trial is ≥5 points below control on ≥300 orgs per group that are 28+ days old. |
| Payments freshness | `max(payment_intented_at)` more than 2 days old |

## Post template (format v12, Simone 2026-10-29)

The scheduled task prompt holds the exact bar rules; this is the same template.

````
**Reverse trial · Day {N} · {Ddd Mon D}**

```
PAYING ORGS
Reverse {bar} {payers_rt}
Normal  {bar} {payers_n}

CASH COLLECTED
Reverse {bar} ${cash_rt}
Normal  {bar} ${cash_n}

LATE-NOVEMBER CHECK
Cash per 100 new orgs, after their second monthly payment
Reverse {track} ${now_rt} → ${stay_in} = what reverse needs to stay in
Normal  {track} ${now_n} → ${beat} = where normal usually lands
```

**Bottom line:** {one plain sentence someone can repeat from memory}

**Where reverse-trial orgs are:** {a}% still in trial · {b}% paused at day 14 · {c}% chose Free · {d}% chose Team · {e}% deleted
**Reaching value: {flat | slightly ahead | slightly behind | ahead | behind}** · first scan within 24h {v_rt}% vs {v_n}%

{Only if something needs attention:} **Health:** {item, max 2; tag Simone + Bjorn when a guardrail trips, team channel only}

**→ [Open the dashboard](https://claude.ai/artifact/5nGJQ2eodLiaFoG9DCZVRn)** for the cash trend, projection and what decides it.
````

Example (Oct 28 data):
````
**Reverse trial · Day 27 · Wed Oct 28**

```
PAYING ORGS
Reverse ███████▌         28
Normal  ████████████████ 60

CASH COLLECTED
Reverse ██████████████▌  $5,633
Normal  ████████████████ $6,198

LATE-NOVEMBER CHECK
Cash per 100 new orgs, after their second monthly payment
Reverse ██████░░░░│░░░░░ $241 → $487 = what reverse needs to stay in
Normal  ██████░░░░░░░░░░ $242 → $696 = where normal usually lands
```

**Bottom line:** More normal-trial orgs are paying, but reverse-trial payers pick bigger plans, so the money is close for now.

**Where reverse-trial orgs are:** 48% still in trial · 37% paused at day 14 · 4% chose Free · 1% chose Team · 10% deleted
**Reaching value: flat** · first scan within 24h 72% vs 73%

**→ [Open the dashboard](https://claude.ai/artifact/5nGJQ2eodLiaFoG9DCZVRn)** for the cash trend, projection and what decides it.
````

Writing rules for the post:
- Short and plain. Its job is to give the headline and send people to the dashboard; detail lives on the dashboard.
- **Same numbers as the dashboard.** Sonar internal orgs are excluded everywhere, matching the dashboard.
- **Title:** {N} = days since launch, Oct 1 = Day 0. The only day number in the post; never write "day 49" in the text.
- **Paying orgs and cash collected:** from 2026-11-07 "paying orgs" means paying now (not Paid once): orgs that paid and have not since been deleted, joined Enterprise, been refunded or moved to Free. Say "paying now" in the post wording. Payers and their cash from signups that have reached day 14 (data date − 14 days), any path, USD with all currencies converted. Shown as text bars in the code block; no separate paying line.
- **Late-November check:** day-14 cash per 100 new orgs for that cohort, against the reverse "stays in" line (70% of normal's expected day 49) and normal's expected day 49. The only per-100 rates in the post. Never compare against the card trial's 53%.
- **Text bars:** 16 cells; no extra line breaks (Slack wraps long lines). Slack can't take images from this connector, so the bars are the visual.
- **Bottom line:** always present. One plain sentence in everyday words that someone can repeat from memory. No jargon ("first payments", "second monthly charge", "cohort"), at most one date, never repeat a number from the post. Don't mention issues the team and Ori already know about (e.g. the end-of-trial email). Change it only when the story changes.
- **Where reverse-trial orgs are:** one line of whole percentages of all reverse-trial orgs: still in trial, paused at day 14, chose Free, chose Team (paying + first charge pending), deleted. Add "joined their company's Enterprise account" only if ≥1%. Each org in one bucket; when a paused org later chooses Team or Free (`subscription_resumed`), it moves to that bucket.
- **Reaching value:** one line, W2, reverse first. "flat" = gap < 2 pts; "slightly" = 2–5 pts; ≥5 pts trips the guardrail.
- **Dashboard call to action** always last, bold, on its own line.
- No people counts, no method notes, no customer names, emails, org keys or IDs.
- **Decision rule** (xtranet page): keep if reverse ≥ control on paying orgs and cash per 100; iterate at 70–100%; stop below 70% at the 6-week read. Cash is lumpy: paying orgs per 100 is the more reliable decider (Readout appendix section 8).
- Known issues already being handled, don't put in Health: end-of-trial email showing a ~$2k price.
- **Never mention the 50/50 split check** (the LaunchDarkly user check): permanently dropped by Simone, 2026-10-29. The org-ratio guardrail stays.

## Monday add-on: weekly read (thread reply under the daily post, team channel only)

- Week-over-week per arm: orgs, first-scan rate, chose Team, chose Free, paused.
- From 2026-10-29: **Still scanning after day 14** (F1), "{x}% vs {y}% of orgs scanned in days 15–28".
- Cohort table per signup week: paying orgs, paying orgs per 100, cash per 100, cash per paying org.
- Keep / iterate / stop signal against the success page. Write "too early" until ≥2 cohorts are mature.
- One learning, not a number.

## Next up (agreed 2026-10-23, start week of Oct 26)
- Track orgs that commit and then cancel, in both groups: chose Team / gave a card but cancelled before the first charge; paid and then cancelled (second-charge window Nov 19–26). Agree scope with Simone before changing the views.

## Don'ts
- Don't report total subscriptions vs September as an experiment effect.
- Don't paste customer names, emails, org keys or Stripe IDs into Slack or the log.
- Don't decide groups from Stripe or `cad_billing_customers`.
- If a source fails, say which one in the Health line. Never fill the gap with estimates.
