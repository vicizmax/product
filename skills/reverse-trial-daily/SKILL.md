---
name: reverse-trial-daily
description: Daily Stripe update for the SonarQube Cloud reverse-trial 50/50 A/B experiment (live since 2026-10-01) — Free / old trial / new trial counts vs previous periods, control vs variant, reverse-trial status and cancellations. Reads Stripe and LaunchDarkly only; appends to experiments/reverse-trial/log.md. Supports --dry-run. Use when asked for the "daily update" or reverse-trial stats.
user-invocable: true
---

# reverse-trial-daily

Measure whether the reverse trial (no card at signup, everyone in the variant
lands on a 14-day Team 1.9M LOC trial) grows **total** subscriptions, using
Stripe Sigma. **Day 0 = 2026-10-01**, when it went live on production.

**Prerequisite:** the Stripe MCP server must be connected (`/mcp`, then
authenticate). Account `acct_1P8lXPBpPNTvMsKo`, `livemode: true`, tool
`stripe_analytics`. The LaunchDarkly MCP must be connected too. This skill only reads from Stripe and LaunchDarkly; it never writes to either.

## The experiment
- **LaunchDarkly 50/50.** Variant users all get the new trial, with no Free or old trial possible. Control users get Free or the old card-required trial.
- **LaunchDarkly:** project `sonarcloud`, flag `growth-enable-reverse-trial`, env `production`, via the LaunchDarkly MCP (read-only: never toggle or edit the flag).
- **The fair comparison** is control (free + old_trial) vs variant (new_trial), counted only in the hours the flag was on.
  The flag log in `experiments/reverse-trial/log.md` lists those hours.

## Buckets (one row per distinct subscription)
The Advanced Security add-on sits on the same subscription as Team, so count subscriptions, not items.
- **free:** the product name starts with `SonarCloud Free` (v1 and v2).
- **new_trial:** a `1MIL900K` trial whose `trial_settings_end_behavior_missing_payment_method` is `pause` (default) or `cancel` (scheduled to Free). Set at creation, so it stays put when the customer adds a card.
  Old card trials use `create_invoice`, and can have a schedule too, so a schedule alone doesn't mark a reverse trial.
- **old_trial:** otherwise, `trial_start IS NOT NULL`.
- **excluded:** `SonarCloud Suspended`, and Team paid with no trial.
- **System cancels:** a new_trial canceled within 10 seconds of creation is a setup failure. Leave it out.
  9 of these happened on 2026-10-01 between 08:47 and 09:26 UTC, all missing the Advanced Security item.
- **Variant people:** count the variant once per email (`lower(customers.email)`), because users retry after failures.

## Suspension mechanics: read these before interpreting a cancellation
- **Regular suspension** (customer has a card): the old subscription is canceled and a NEW one is created on `SonarCloud Suspended`.
- **Reverse-trial suspension** (no card): the customer stays on the same 1MIL900K subscription, and its status becomes `paused`. Stripe's trial-end behavior is `pause`.
  The earliest possible date is 2026-10-15, when the first trials end.
- So **a canceled reverse-trial subscription is never a suspension.** Check `cancellation_details_reason`, how many minutes it took, and whether the same email has another subscription.

## What's scheduled at trial end (check this daily from now on)
- **Default:** `trial_settings_end_behavior_missing_payment_method = pause`, with no `schedule_id`. The subscription will pause at trial end.
  **This is intended** (confirmed by the squad on 2026-10-05). Don't flag it as a problem; report the count.
- **Downgrade to Free chosen:** the subscription has a `schedule_id` pointing to a 2-phase `subscription_schedules` entry.
  The phases run Team 1.9M (+ Advanced Security) until trial end, then `SonarCloud Free_v2`. The sub's trial-end behavior flips to `cancel`.
  Join `subscription_schedule_phases` and `subscription_schedule_phase_configuration_items` (column `price`, not `price_id`) to see which plans each phase uses.
- **Continuing on Team:** the customer has added a card. `trial_end_outcomes.sql` reports these as `card added -> continues on Team` (end behavior `pause` + customer has a card).
- On 2026-10-05: 423 had nothing scheduled (pause, intended), 23 were scheduled to Free (created 0–25 h after signup), and 0 were going to Team.

## Steps

1. **State the plan.** List the five Stripe queries and three LaunchDarkly reads you'll run (all read-only) and the files you'll write.
   The files are a dated entry in `experiments/reverse-trial/log.md` and raw CSVs in `experiments/reverse-trial/results/`, which is gitignored.
   With `--dry-run`, stop here.
2. **Pull the flag state from LaunchDarkly**, in parallel with the Stripe queries (LaunchDarkly MCP, read-only):
   - `get-flag` (env `production`): on/off, the fallthrough rollout (expect 50000/50000 on `user`), and any rules, individual targets or prerequisites (expect none). Anything else changes who is in the experiment, so lead with it.
   - `query-change-history` (`resourceKind: flag`, `resourceKey: growth-enable-reverse-trial`, `env: production`, `startDate` = the last flag-log entry): only the "turned on/off" and rollout-update entries matter; skip approval-request noise and `Staging` entries. Update the flag log from these (UTC).
   - `get-flag-unique-context-exposures` (`envKey: production`): once from `2026-10-01T11:15:00Z` to now, and once for the last full UTC day. Use the `user` row. The flag is served when someone tries to create an organization, and it's evaluated per user because most of them don't have an org yet; ignore the `organization` row.
     So exposures = distinct users who reached org creation, **not split by variation** (expect about half per arm).
   - **Check the split is a true 50/50 (sample-ratio mismatch).** Get distinct users per variation (`true` / `false`) since `2026-10-01T11:15:00Z`, then compute z = (n_true − n_false) / √(n_true + n_false).
     |z| > 3.3 (p < 0.001) means the split is broken and every arm comparison is suspect, so lead the report with it. Only users who reached org creation count; never use Stripe subscriptions for this, because they are the outcome.
     Source: ask the user for the distinct users per variation from the flag's **Evaluations / Insights** tab in the LaunchDarkly UI (production, since 2026-10-01 11:15 UTC).
     **Evaluation counts are not users.** On 2026-10-05 the UI gave 15.5k false / 4.8k true "since Oct 1", which is about 14× the unique users, includes the flag-off windows (everyone got false), and lets arms differ in re-evaluations. Reject numbers like that: sanity-check the total against `get-flag-unique-context-exposures`, and require a start of 11:15 UTC on Oct 1 or later.
     **Daily evaluations from Oct 2 on are an acceptable proxy**, as long as you correct for clustering. Get that day's users from `get-flag-unique-context-exposures` (a one-day window),
     estimate users per arm as users × the evaluation share, and compute z on those (equivalently, raw evaluation z ÷ √(evaluations per user)). Never test raw evaluation counts directly.
     On 2026-10-05: Oct 2 8.0k/8.2k (470 users) z ≈ +0.3; Oct 3 4.8k/4.5k (330 users) z ≈ −0.6; Oct 4 4.6k/4.8k (299 users) z ≈ +0.4; Oct 5 partial 3.1k/3.3k (154 users) z ≈ +0.4; Oct 2–5 combined ≈623/630 users, z ≈ +0.2, so balanced.
     The MCP can't supply it: LaunchDarkly observability holds no SonarCloud data (sessions, traces and events were empty, with no flag or variation dimension, on 2026-10-05), and there's no evaluation-summary tool. The MCP's unique-exposure tool can't do it: it isn't split by variation. If no source is available, report the split as **unverified**; don't infer it.
   - If the LaunchDarkly MCP isn't connected (`/mcp`), ask whether the flag changed and don't block on the answer: the data shows the on/off times, because new trials stop when the flag is off.
3. **Run in parallel** (the queries are in `queries/` next to this file):
   - `daily_since_launch.sql` **is the main query.** It gives one row per day from 2026-09-24, a week before launch, up to today, with every comparison already calculated:
     - Free / old trial / new trial / total, with the total 1 and 2 weeks earlier and `pct_vs_same_weekday` / `pct_vs_baseline`.
     - `*_to_cutoff` columns for a fair partial-day comparison today.
     - People per day (control, Free, variant) and the variant/Free ratio.
     - Running totals of people and the running variant/Free ratio with its z-score.
     - Per signup day: system cancels, later cancels, scheduled to Free, paused, converted.
   - `variant_people.sql` gives variant status per person (trialing, active, paused, canceled later, only system cancels).
   - `late_cancels.sql` lists every reverse-trial cancellation that came more than 10 seconds after creation, with minutes to cancel and the reason.
   - `trial_end_outcomes.sql` shows what happens at trial end for each reverse trial: pauses (nothing scheduled), scheduled to Free, card added (continues on Team), converted, already paused, or ended. It also counts trials ending within 48 hours.
   - `new_vs_existing.sql` gives clean-window people per arm, split into new vs existing (the email had a subscription before 2026-10-01 11:15 UTC). **New-only control vs variant is the main arm comparison.**
   Optional queries: `flag_windows.sql`, only when the flag log changes (it splits days by on/off windows), and `buckets_vs_previous.sql`, the older per-day version kept for reference.
4. **Wait for each run.** Sleep about 45 seconds with `perl -e 'select(undef,undef,undef,45)'`, because foreground `sleep` is blocked, then call `retrieve_query_run`.
   Small results come back inline. For large ones, `curl` the download URL straight away (it expires after about 5 minutes) into `experiments/reverse-trial/results/YYYY-MM-DD_<name>.csv`.
5. **Compare** with:
   - the same weekday 1 and 2 weeks earlier;
   - the weekday average of the 10 weekdays before launch (2026-09-17..30: total ≈307, free ≈276, old trial ≈31 per full day). Weekend baseline (Sep 19/20/26/27): ≈204 per day (Sat ≈210, Sun ≈199). Up to 2026-10-04 total signups rose in **both** arms (traffic, not the variant), so always check whether control alone moved too before reading a total bump as a reverse-trial effect.
   - Use the `*_to_cutoff` columns for today.
6. **Report** in this format:
   1. **Headline**, two or three sentences:
      - Is there a bump in total?
      - Is it the variant, or did control move too?
      - What does the running variant/Free ratio and z-score say?
   2. **Flag (LaunchDarkly):** on/off, rollout split, rules/targets (should be none), changes since the last log entry, and the 50/50 check (n per variation, z, verdict; or "unverified" and why).
      Unique `user` exposures since the clean window and for the last full day, plus people who subscribed ÷ exposures (org-creation → subscription rate; it was ≈68% on 2026-10-05). A drop in exposures means less traffic reaching org creation and explains a drop in signups without any variant effect.
   3. **Daily table, one row per day from the week before launch to today.** Columns: Day N, date and weekday, Free, Old trial, New trial, **Total**, % vs the same weekday (average of 1 and 2 weeks earlier), and % vs baseline (weekday or weekend).
      For today, use `pct_to_cutoff_vs_same_weekday` and `pct_to_cutoff_vs_baseline`, and mark the row as partial. The pre-launch rows show the normal noise level.
   4. **Weekly rollup:**
      - All full days since launch vs the same weekdays 1 and 2 weeks earlier.
      - The normal week-to-week swing before launch: `pct_vs_same_weekday` for 2026-09-24..30 ranged −13.5% to +29%, a standard deviation of about 16%.
      - A total change inside about ±16% is not a signal on its own.
   5. **Control vs variant per day (people, flag-on time only), new people only** (from `new_vs_existing.sql`): control, Free, old trial, variant, variant/control per day.
      Add the running variant/control and variant/Free ratios with z-scores (|z| ≥ 2 means significant). Show existing people as one line underneath; their old trials partly come from outside the experiment.
   6. **Reverse-trial people since launch:** trialing, converted (active), paused, canceled later, system cancels, with the change since the last log entry.
   7. **Trial-end outcomes:** a table of pauses (intended default) / scheduled to Free / continues on Team / converted / already paused / ended, with the change since the last log entry.
      Include how many trials end within 48 hours, and the scheduled-to-Free count per signup day from the daily table.
      From 2026-10-15, add a cohort view per signup day: share paused, share converted, share moved to Free.
   8. **Cancellations:** later cancels per signup day, how many came within 2 minutes, the median minutes to cancel, and whether those users signed up again. Also any system cancels.
   9. **Things to look into:** anything unusual or new since the last entry.
   10. **Reliability:** people per group so far, the smallest lift that could be detected, and the current verdict.
      About 145 people per arm per full weekday means about 3 full weekdays to detect a 20% lift and about 11 for 10%. As an approximation, the smallest detectable lift ≈ 2.8 × √(2/n) at n people per arm.
7. **Append** a dated entry to the Log in `experiments/reverse-trial/log.md`, using **aggregates only**: no customer IDs, emails or names.
   Update the flag log from the LaunchDarkly change history. Don't commit; that's the human's call, as everywhere in this repo.

## Known caveats (mention them when they're relevant)
- **Old trials from existing customers are partly outside the experiment** (checked 2026-10-05 with `new_vs_existing.sql`).
  New-customer old trials halved as expected (Fri 2: 13 vs a pre-launch weekday average of 19.5), but existing-customer ones didn't (9 vs 10.7). That's probably `/upgrade` and other non-onboarding paths.
  So compare arms on **new people only**; there, control includes old trial and needs no Free-only workaround.
- **Escapes aren't in Stripe.** Users can leave either arm via the OSS plan (free, public projects) or a coupon (annual Team). Neither creates a Stripe subscription we can see (checked 2026-10-05).
  So a variant gap can partly be people escaping, not people lost. Estimate it as the post-launch rise in OSS and coupon org creations (control behaves as before, so the rise comes from the variant), using SonarCloud org data.
- **Watch the end-behavior rule once conversions start (2026-10-15).** Check that a converted reverse trial keeps `pause` and doesn't flip to `create_invoice`; if it flips, it would drop back into old_trial.
- **Stripe's reporting data lags** live data by about 30–60 minutes. Always cut every day you compare at the same UTC time.
- **Raw CSVs can contain customer and subscription IDs.** That's why `results/` is gitignored. Never paste IDs or emails into the log.
