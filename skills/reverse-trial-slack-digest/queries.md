# Queries — reverse-trial-slack-digest

All read-only. Classification: outputs are Confidential (billing). Keep only aggregates.

**Internal orgs (rule from 2026-10-29: excluded from every number; see SKILL.md and the data guide):**
- **Warehouse (W1):** filters `dim_sc_organization.is_internal = false`. That flag is reliable for orgs created on or after 2025-02-13.
- **Stripe (S2c):** has no internal flag, so it excludes customers whose email contains `sonarsource`.
- **What each method catches** (2026-10-13):
  - The email rule caught 16 of 2,061 reverse-trial orgs (0.8%).
  - The warehouse flagged 9 reverse-trial orgs and 5 control orgs as internal.
- **Gap:** employees testing with a personal email slip past the Stripe filter. The impact is under 1%, so it doesn't change any rounded percentage.

## S1 — Stripe daily buckets (stripe_analytics → execute_query_run)

```sql
with sub_prod as (
  select s.id, s.created, s.trial_start,
         s.trial_settings_end_behavior_missing_payment_method as teb,
         max(case when p.name like 'SonarCloud Free%' then 1 else 0 end) as is_free,
         max(case when p.name like '%Suspended%' then 1 else 0 end) as is_susp,
         max(case when p.name like '%1MIL900K%' or pr.nickname like '%1MIL900K%' then 1 else 0 end) as is_1m9
  from subscriptions s
  join subscription_items si on si.subscription_id = s.id
  join prices pr on pr.id = si.price_id
  join products p on p.id = pr.product_id
  where s.created >= timestamp '2026-09-17 00:00:00'
  group by 1,2,3,4
)
select date(created) as d,
  sum(case when is_free=1 then 1 else 0 end) as free,
  sum(case when is_free=0 and is_susp=0 and teb in ('pause','cancel') and is_1m9=1 then 1 else 0 end) as new_trial,
  sum(case when is_free=0 and is_susp=0 and trial_start is not null and not (teb in ('pause','cancel') and is_1m9=1) then 1 else 0 end) as old_trial
from sub_prod group by 1 order by 1
```

Context only. **Never** present the total vs September as the experiment's effect.

## S2 — Stripe reverse-trial status (people + yesterday deltas)

```sql
with rt as (
  select s.id, s.customer_id, s.created, s.status, s.trial_end, s.canceled_at, s.schedule_id, s.default_payment_method_id
  from subscriptions s
  where s.created >= timestamp '2026-10-01 00:00:00'
    and s.trial_settings_end_behavior_missing_payment_method in ('pause','cancel')
    and exists (select 1 from subscription_items si join prices pr on pr.id=si.price_id join products p on p.id=pr.product_id
                where si.subscription_id=s.id and (p.name like '%1MIL900K%' or pr.nickname like '%1MIL900K%'))
)
select
  count(distinct lower(c.email)) as people,
  count(distinct case when date(rt.created) = current_date - interval '1' day then lower(c.email) end) as people_yesterday,
  sum(case when rt.canceled_at is not null and date_diff('second', rt.created, rt.canceled_at) <= 10 then 1 else 0 end) as system_cancels,
  sum(case when rt.canceled_at is not null and date_diff('second', rt.created, rt.canceled_at) <= 10 and date(rt.created) = current_date - interval '1' day then 1 else 0 end) as system_cancels_yesterday,
  sum(case when rt.canceled_at is not null and date_diff('second', rt.created, rt.canceled_at) > 10 then 1 else 0 end) as manual_cancels,
  sum(case when rt.status='trialing' then 1 else 0 end) as trialing,
  sum(case when rt.status='active' then 1 else 0 end) as active_paid,
  sum(case when rt.status='paused' then 1 else 0 end) as paused,
  sum(case when rt.schedule_id is not null and rt.canceled_at is null then 1 else 0 end) as chose_free,
  sum(case when rt.canceled_at is null and (rt.default_payment_method_id is not null or c.invoice_settings_default_payment_method_id is not null or c.default_source_id is not null) then 1 else 0 end) as card_added,
  sum(case when rt.canceled_at is null and rt.status='trialing' and rt.trial_end < current_timestamp + interval '48' hour then 1 else 0 end) as ending_48h
from rt join customers c on c.id = rt.customer_id
```

## S2d — Trial status per org (USE THIS IN THE POST; replaces S2c from 2026-10-14)

**Why it changed (confirmed by Dimitris and Quentin on 2026-10-14):**
- When a reverse-trial user picks a Team plan and adds a card before day 14, Stripe **cancels the 1MIL900K subscription** and creates a **new regular `SonarCloud Team …` subscription**.
- That new subscription keeps the remaining trial days and auto-pays at trial end.
- S2c only looked for a card on a *live* reverse-trial subscription, so it reported "Added a card: 0" and pushed these orgs into "canceled".

```sql
with rt as (
  select s.id, s.customer_id, s.created, s.status, s.canceled_at, s.schedule_id, s.default_payment_method_id
  from subscriptions s
  where s.created >= timestamp '2026-10-01 00:00:00'
    and s.trial_settings_end_behavior_missing_payment_method in ('pause','cancel')
    and exists (select 1 from subscription_items si join prices pr on pr.id=si.price_id join products p on p.id=pr.product_id
                where si.subscription_id=s.id and (p.name like '%1MIL900K%' or pr.nickname like '%1MIL900K%'))
    and not (s.canceled_at is not null and date_diff('second', s.created, s.canceled_at) <= 10)
), latest as (
  select rt.*, row_number() over (partition by rt.customer_id order by rt.created desc) as rn from rt
), org as (
  select l.*,
    (l.default_payment_method_id is not null or c.invoice_settings_default_payment_method_id is not null or c.default_source_id is not null) as has_card,
    exists (select 1 from subscriptions s2 join subscription_items si2 on si2.subscription_id = s2.id join prices pr2 on pr2.id = si2.price_id join products p2 on p2.id = pr2.product_id
            where s2.customer_id = l.customer_id and s2.created > l.created and s2.status in ('trialing','active','past_due')
              and p2.name like 'SonarCloud Team%' and p2.name not like '%1MIL900K%') as chose_team,
    exists (select 1 from subscriptions s3 join subscription_items si3 on si3.subscription_id = s3.id join prices pr3 on pr3.id = si3.price_id join products p3 on p3.id = pr3.product_id
            where s3.customer_id = l.customer_id and s3.created > l.created and s3.status = 'active') as paying_now
  from latest l join customers c on c.id = l.customer_id
  where l.rn = 1 and lower(coalesce(c.email,'')) not like '%sonarsource%'
)
select count(*) as orgs,
  sum(case when canceled_at is null and status = 'trialing' and schedule_id is null and not has_card then 1 else 0 end) as no_decision,
  sum(case when (canceled_at is not null and chose_team) or (canceled_at is null and has_card) then 1 else 0 end) as chose_team,
  sum(case when paying_now or status = 'active' then 1 else 0 end) as paying,
  sum(case when canceled_at is null and schedule_id is not null then 1 else 0 end) as scheduled_free,
  sum(case when status = 'paused' then 1 else 0 end) as paused,
  sum(case when canceled_at is not null and not chose_team then 1 else 0 end) as canceled_to_classify  -- split via warehouse: deleted / Enterprise / being checked / pending
from org
```

On 2026-10-14: 2,224 orgs · no decision 1,960 · **chose Team 10** (all with a card) · scheduled to Free 116 · canceled_to_classify 138 · paying 0 · paused 0.

## S2c — superseded by S2d (missed card-adds; kept for reference)

Each reverse-trial org is its own Stripe customer, so count one row per customer, using its latest reverse-trial subscription. Setup failures are excluded.

```sql
with rt as (
  select s.id, s.customer_id, s.created, s.status, s.canceled_at, s.schedule_id, s.default_payment_method_id, s.trial_end
  from subscriptions s
  where s.created >= timestamp '2026-10-01 00:00:00'
    and s.trial_settings_end_behavior_missing_payment_method in ('pause','cancel')
    and exists (select 1 from subscription_items si join prices pr on pr.id=si.price_id join products p on p.id=pr.product_id
                where si.subscription_id=s.id and (p.name like '%1MIL900K%' or pr.nickname like '%1MIL900K%'))
    and not (s.canceled_at is not null and date_diff('second', s.created, s.canceled_at) <= 10)
), latest as (
  select rt.*, row_number() over (partition by rt.customer_id order by rt.created desc) as rn from rt
), org as (
  select l.*, lower(c.email) as person,
    (l.default_payment_method_id is not null or c.invoice_settings_default_payment_method_id is not null or c.default_source_id is not null) as has_card
  from latest l join customers c on c.id = l.customer_id where l.rn = 1
    and lower(coalesce(c.email, '')) not like '%sonarsource%'   -- exclude internal (Stripe has no is_internal flag)
)
select
  count(*) as orgs,
  count(distinct person) as people,
  sum(case when status='trialing' and schedule_id is null and not has_card then 1 else 0 end) as in_trial_no_decision,
  sum(case when canceled_at is null and has_card then 1 else 0 end) as card_added,
  sum(case when canceled_at is null and schedule_id is not null then 1 else 0 end) as scheduled_free,
  sum(case when canceled_at is not null then 1 else 0 end) as canceled,
  sum(case when status='paused' then 1 else 0 end) as paused,
  sum(case when status='active' then 1 else 0 end) as paid,
  sum(case when trial_end < current_timestamp then 1 else 0 end) as trial_ended,
  sum(case when canceled_at is null and status='trialing' and trial_end < current_timestamp + interval '48' hour then 1 else 0 end) as ending_48h
from org
```

% = count ÷ `orgs`. The paused/paid % base = `trial_ended`.
On 2026-10-13: 2,061 orgs (1,926 people) · no decision yet 1,814 (88%) · card 0 (0%) · scheduled to Free 102 (5%) · canceled 145 (7%).
Paid read (weekly, from Oct 22): paid Team orgs ÷ people per group × 100. Control people come from LaunchDarkly exposure × the split, or from W1 org creators.

## S2b — per person (superseded by S2c; kept for reference)

```sql
with rt as (
  select s.id, s.customer_id, s.created, s.status, s.canceled_at, s.schedule_id, s.default_payment_method_id
  from subscriptions s
  where s.created >= timestamp '2026-10-01 00:00:00'
    and s.trial_settings_end_behavior_missing_payment_method in ('pause','cancel')
    and exists (select 1 from subscription_items si join prices pr on pr.id=si.price_id join products p on p.id=pr.product_id
                where si.subscription_id=s.id and (p.name like '%1MIL900K%' or pr.nickname like '%1MIL900K%'))
), j as (
  select lower(c.email) as person, rt.*,
    (rt.default_payment_method_id is not null or c.invoice_settings_default_payment_method_id is not null or c.default_source_id is not null) as has_card,
    (rt.canceled_at is not null and date_diff('second', rt.created, rt.canceled_at) <= 10) as is_system_cancel
  from rt join customers c on c.id = rt.customer_id
), per as (
  select person,
    max(case when not is_system_cancel and canceled_at is null and has_card then 1 else 0 end) as card_added,
    max(case when not is_system_cancel and canceled_at is null and schedule_id is not null then 1 else 0 end) as scheduled_free,
    max(case when not is_system_cancel and canceled_at is null and status = 'paused' then 1 else 0 end) as paused,
    max(case when not is_system_cancel and canceled_at is null and status = 'active' then 1 else 0 end) as paid,
    max(case when not is_system_cancel and canceled_at is null then 1 else 0 end) as has_live,
    max(case when not is_system_cancel and canceled_at is not null then 1 else 0 end) as had_manual_cancel,
    max(case when not is_system_cancel then 1 else 0 end) as real_person
  from j group by 1
)
select sum(real_person) as people, sum(card_added) as card_added, sum(scheduled_free) as scheduled_free,
  sum(paused) as paused, sum(paid) as paid,
  sum(case when has_live = 0 and had_manual_cancel = 1 then 1 else 0 end) as canceled
from per
```

% = count ÷ `people`. On 2026-10-13: 1,921 people · card 0 (0%) · scheduled to Free 101 (5%) · canceled 80 (4%).
The subscription-level S2 gave 145 cancels: that number includes people who canceled and signed up again. Use S2b in the post.

`card_added` was 0 on 2026-10-13. Cross-check against the `payment_methods` table (attached to the customer) before reporting 0 as fact on or after Oct 15.

## W1 — Warehouse activation by arm (Atlan query_assets_tool)

connection `default/redshift/1720789348`, database `sonarsource`, schema `sonar`

```sql
with base as (
  select o.organization_uuid_v4, o.creation_date, o.first_analysis_date,
    case
      when c.current_billed_product_name = 'canceled' and c.status_of_last_subscription = 'trialing'
           and c.trial_started_at is not null and o.creation_date >= '2026-10-01' then 'variant'
      when c.current_billed_product_name like 'SonarCloud Free%' then 'control'
      when c.current_billed_product_name like 'SonarCloud Team%' and c.trial_started_at is not null then 'control'
      else 'other' end as arm
  from sonarsource.sonar.dim_sc_organization o
  join sonarsource.sonar.cad_billing_customers c on c.entity_id = o.organization_uuid_v4
  where o.creation_date >= '2026-10-01 11:15:00' and o.creation_date < current_date
    and coalesce(o.is_internal, false) = false
)
select arm,
  count(distinct organization_uuid_v4) as orgs,
  count(distinct case when creation_date >= current_date - 7 then organization_uuid_v4 end) as orgs_7d,
  count(distinct case when first_analysis_date is not null and datediff(hour, creation_date, first_analysis_date) <= 24
                       and creation_date < current_date - 1 then organization_uuid_v4 end) as scanned_24h,
  count(distinct case when creation_date < current_date - 1 then organization_uuid_v4 end) as orgs_24h_eligible
from base group by 1 order by 1
/* mcp-query: ts=<ISO-8601 UTC> */
```

First-scan rate = `scanned_24h / orgs_24h_eligible`. The denominator excludes orgs younger than a day.
The start time 11:15 UTC on Oct 1 excludes the flag-off window, when everyone landed in control.
Baseline on 2026-10-13 (Oct 1–11, from 00:00): variant 1,596 orgs, 63.8%; control 1,712, 64.7%.

## W2 — First scan within 24h per group, from events (USE THIS for "Reaching value", from 2026-10-15; replaces W1)

**Why W2 replaces W1 (validated 2026-10-14):**
- **Fresher.** `product_events` loads nightly around 00:50 UTC with data through the end of the previous day, so the 09:00 run always has yesterday complete. (Corrected 2026-10-15: it is not hourly.) `dim_sc_organization` only refreshes daily, and it was a day late on Oct 14.
- **Uses the documented first-scan definition.** It's the earliest `analysis_finished` with `analysis_status = 'completed'`, the same definition as the VERIFIED `cad_time_to_first_analysis_of_orgs` (IC-FA).
- **Same group definition as E1**, taken from `subscription_created`.
- **`dim_sc_organization.first_analysis_date` misses many real first scans.** On the same 3,222 orgs (Oct 1–11), it showed none for ~230 orgs that do have a completed, error-free analysis in the events, mostly AutoScan. dim → 64% / 64%; events → **74% control vs 71% reverse trial**.

```sql
with org as (
  select organization_uuid_v4, min(_event_timestamp) as created_at
  from sonarsource.product_events.organization_created
  where _event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
grp as (
  select organization_uuid_v4,
         case when max(case when trial_type = 'CARD_LESS' then 1 else 0 end) = 1 then 'reverse_trial' else 'control' end as arm
  from sonarsource.product_events.subscription_created
  where _event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
fa as (
  select organization_uuid_v4, min(_event_timestamp) as first_scan_at
  from sonarsource.product_events.analysis_finished
  where analysis_status = 'completed' and _event_timestamp >= '2026-10-01'
  group by 1
),
base as (
  select o.organization_uuid_v4, o.created_at, g.arm, f.first_scan_at
  from org o
  join grp g on g.organization_uuid_v4 = o.organization_uuid_v4
  left join fa f on f.organization_uuid_v4 = o.organization_uuid_v4
  left join sonarsource.sonar.dim_sc_organization d on d.organization_uuid_v4 = o.organization_uuid_v4
  where coalesce(d.is_internal, false) = false
)
select arm,
  count(*) as new_orgs,
  sum(case when created_at < dateadd(hour, -24, getdate()) then 1 else 0 end) as orgs_24h_old,
  sum(case when created_at < dateadd(hour, -24, getdate())
            and first_scan_at is not null and datediff(hour, created_at, first_scan_at) <= 24 then 1 else 0 end) as scanned_24h
from base group by 1 order by 1
/* mcp-query: ts=<ISO-8601 UTC> */
```

First-scan rate = `scanned_24h / orgs_24h_old`; new orgs = `new_orgs`.
2026-10-14 (orgs created Oct 1–11): control 74.5% (1,248/1,675) vs reverse trial 71.2% (1,102/1,547), a gap of −3.3 pts (z ≈ 2.1). That's below the 5-pt guardrail, so the verdict word is "slightly behind", not "flat".
Internal filter caveat: the newest orgs aren't in `dim_sc_organization` yet, so the internal filter misses about a day's worth (<1%).

## P1 — Paying orgs and money collected per group, by signup cohort (USE for the paying line from 2026-10-22, and for Don's "ARR by test version")

- **Groups** come from `product_events.subscription_created` (the same rule as E1/W2):
  - `CARD_LESS` → reverse trial
  - `CARD_BACKED` → control card trial
  - everything else → control Free/other
  - **Control = card trial + Free/other.** This is intention-to-treat: compare the whole control group, never only its card trials.
- **Payments** come from `sonar.dim_billing_charges` (VERIFIED): succeeded charges, net of refunds, since Oct 1. They're joined org → customer via `sonar.cad_billing_customers.entity_id`.
- **Freshness:** `dim_billing_charges` lagged about 3 days on 2026-10-18 (max charge Oct 15 20:52). Always print `charges_fresh_to`. If it's more than 2 days old, add a Health line ("payments only loaded up to {date}").
- **Amounts** are in the smallest unit of each currency (usd, eur, gbp, jpy seen since Aug; yen has no cents). `usd_total` converts all of them (€ × 1.12, £ × 1.335, ¥ ÷ 157.7, fixed 2026-10-27). Before 2026-10-27 this query only had usd and eur columns, so pound and yen payers counted as paying with $0 cash.

**Fix (2026-10-18): only include orgs created since the experiment started** (join `organization_created`). Without this join, existing paying customers whose plan changed after Oct 1 leaked into "control Free/other" and inflated control's paying count from 1 to 6.

```sql
with neworg as (
  select organization_uuid_v4
  from sonarsource.product_events.organization_created
  where _event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
grp as (
  select s.organization_uuid_v4, min(s._event_timestamp) as first_sub_at,
    case when max(case when s.trial_type = 'CARD_LESS' then 1 else 0 end) = 1 then 'reverse_trial'
         when max(case when s.trial_type = 'CARD_BACKED' then 1 else 0 end) = 1 then 'control_card_trial'
         else 'control_free_or_other' end as arm
  from sonarsource.product_events.subscription_created s
  join neworg n on n.organization_uuid_v4 = s.organization_uuid_v4
  where s._event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
orgs as (
  select g.*, c.customer_id
  from grp g
  left join sonarsource.sonar.cad_billing_customers c on c.entity_id = g.organization_uuid_v4
  left join sonarsource.sonar.dim_sc_organization d on d.organization_uuid_v4 = g.organization_uuid_v4
  where coalesce(d.is_internal, false) = false
),
paid as (
  select customer_id, payment_currency,
         sum(amount_charged - coalesce(amount_refunded, 0)) as net_paid
  from sonarsource.sonar.dim_billing_charges
  where payment_status = 'succeeded' and payment_intented_at >= '2026-10-01' and amount_charged > 0
  group by 1, 2
)
select
  case when o.arm = 'reverse_trial' then 'reverse_trial' else 'control' end as grp,
  o.arm,
  case when o.first_sub_at < current_date - 21 then 'mature_21d' else 'too_young' end as maturity,
  count(distinct o.organization_uuid_v4) as orgs,
  count(distinct p.customer_id) as paying_orgs,
  sum(case when p.payment_currency = 'usd' then p.net_paid else 0 end) as usd_cents,
  sum(case when p.payment_currency = 'eur' then p.net_paid else 0 end) as eur_cents,
  sum(case p.payment_currency when 'usd' then p.net_paid/100.0 when 'eur' then p.net_paid/100.0*1.12
           when 'gbp' then p.net_paid/100.0*1.335 when 'jpy' then p.net_paid/157.7 end) as usd_total,
  sum(case when p.payment_currency not in ('usd','eur','gbp','jpy') then 1 else 0 end) as unknown_currency_rows,
  (select max(payment_intented_at) from sonarsource.sonar.dim_billing_charges)::varchar as charges_fresh_to
from orgs o left join paid p on p.customer_id = o.customer_id
group by 1, 2, 3 order by 3, 1, 2
/* mcp-query: ts=<ISO-8601 UTC> */
```

- **Paying line from 2026-10-22:** use only `mature_21d` rows. Show `paying_orgs / orgs × 100` for the reverse trial vs control. Show 2.7 only as a small "pre-launch baseline" reference, if at all.
- **2026-10-18 snapshot**, new orgs only (corrected); charges only loaded to Oct 15:
  - reverse trial: 1 paying / 2,962 ($34)
  - control card trial: 1 / 162 ($56)
  - control Free/other: 1 / 2,861 (€32)
- In total the experiment has collected about $90 + €32. Far too early to read anything into it.

## E1 — Reverse-trial funnel from billing events (USE THIS IN THE POST, from 2026-10-15)

Source: Gessie billing events in `product_events` (Atlan `query_assets_tool`, connection `default/redshift/1720789348`, database `sonarsource`). Outcomes are per org, and each org lands in exactly one bucket, assigned in this priority order:
1. joined their company's Enterprise account (label renamed 2026-10-29 from "moved to Enterprise"; a Sales contract or Sales-issued Enterprise trial, not a trial upgrade)
2. deleted org
3. chose Team
4. moved to Free
5. paused at day 14
6. no decision yet

```sql
with started as (
  select organization_uuid_v4, min(_event_timestamp) as started_at, max(trial_end_date) as trial_end
  from sonarsource.product_events.subscription_created
  where trial_type = 'CARD_LESS' and _event_timestamp >= '2026-10-01'
  group by 1
),
-- NOTE: "at" is a reserved word in Redshift, so always alias as evt_at (validated 2026-10-14)
conv     as (select organization_uuid_v4, min(_event_timestamp) as evt_at from sonarsource.product_events.subscription_tier_updated where _event_timestamp >= '2026-10-01' group by 1),
to_free  as (select organization_uuid_v4, min(_event_timestamp) as evt_at from sonarsource.product_events.subscription_plan_changed where fromplan = 'Team' and toplan like 'Free%' and _event_timestamp >= '2026-10-01' group by 1),
paused   as (select organization_uuid_v4, min(_event_timestamp) as evt_at from sonarsource.product_events.subscription_suspended where reason = 'trial_expired' and _event_timestamp >= '2026-10-01' group by 1),
resumed  as (select organization_uuid_v4, max(reactivatedplanname) as plan, min(_event_timestamp) as evt_at from sonarsource.product_events.subscription_resumed where _event_timestamp >= '2026-10-01' group by 1),
canceled as (select organization_uuid_v4, min(_event_timestamp) as evt_at, max(reason) as reason from sonarsource.product_events.subscription_canceled where _event_timestamp >= '2026-10-01' group by 1),
org as (
  select s.organization_uuid_v4,
    case
      when x.evt_at > s.started_at and x.reason = 'Organization added to enterprise' then 'moved_to_enterprise'
      when x.evt_at > s.started_at and x.reason = 'organization_deleted'             then 'deleted_org'
      when c.evt_at > s.started_at or (p.evt_at > s.started_at and r.plan = 'Team')     then 'chose_team'
      when f.evt_at > s.started_at or (p.evt_at > s.started_at and r.plan like 'Free%') then 'moved_to_free'
      when p.evt_at > s.started_at                                                       then 'paused_day14'
      else 'no_decision' end as bucket,
    case when p.evt_at > s.started_at and r.evt_at > p.evt_at then 1 else 0 end as came_back_after_pause
  from started s
  left join conv c     on c.organization_uuid_v4 = s.organization_uuid_v4
  left join to_free f  on f.organization_uuid_v4 = s.organization_uuid_v4
  left join paused p   on p.organization_uuid_v4 = s.organization_uuid_v4
  left join resumed r  on r.organization_uuid_v4 = s.organization_uuid_v4
  left join canceled x on x.organization_uuid_v4 = s.organization_uuid_v4
  left join sonarsource.sonar.dim_sc_organization o on o.organization_uuid_v4 = s.organization_uuid_v4
  where coalesce(o.is_internal, false) = false
)
select bucket, count(*) as orgs, sum(came_back_after_pause) as came_back_after_pause
from org group by 1 order by 2 desc
/* mcp-query: ts=<ISO-8601 UTC> */
```

Validated on 2026-10-14 (before any trial ended), internal orgs excluded: 2,175 started · no decision 2,023 · deleted org 132 · chose Team 13 · moved to Enterprise 7 · moved to Free 0 · paused 0.

**Internal filter lag (found 2026-10-18):** the internal-org filter relies on `dim_sc_organization`, which lags 1–3 days. A brand-new internal org is counted until it shows up there, then drops out.
- Example: org `cd7ed9cb-…` (internal, added to Enterprise on Oct 15) was counted on Day 15 and excluded from Day 16 on, so Enterprise went 10 → 9.
- Expect small day-over-day dips like this. They're not reversals.

**Known gap:** "Scheduled to Free" isn't in the events. `SubscriptionPlanChanged` only fires when the move to Free takes effect at trial end, so a scheduled move only shows from day 14.

**Paid:** the events record no payment. Until Massimiliano confirms the paid definition (first successful charge vs first non-trial Team subscription), "paying" = `chose_team` orgs whose `trial_end` has passed and that were not later paused or canceled. Label it as such.

## M2–M4 — Billing-event funnel (superseded by E1; Mixpanel shortcut, kept for reference) (Mixpanel Run-Query, insights, project 3667556) — SOURCE OF TRUTH since 2026-10-14

Measure every metric as aggregate-property `unique_values` of `organization_uuid_v4`, chartType `bar`, absolute date range from 2026-10-01 to today.

- **M2 Started:** `SubscriptionCreated`, filter `trial_type equals CARD_LESS`. (2026-10-14: 2,184)
- **M3 Chose Team:** `SubscriptionTierUpdated`, filter `oldloclimit is equal to 1900000` (number). (2026-10-14: 16)
- **M4 Expired unpaid:** `SubscriptionSuspended`, filter `reason equals trial_expired`. (0 until the first trials end on Oct 15)

Funnels don't work on these events (no user identity, so they return 0). Use insights totals only.

Example M3 report JSON:
```json
{"name":"RT chose Team","metrics":[{"eventName":"SubscriptionTierUpdated","measurement":{"type":"aggregate-property","math":"unique_values","propertyName":"organization_uuid_v4"},"filters":[{"type":"number","propertyName":"oldloclimit","operator":"is equal to","value":1900000}]}],"chartType":"bar","dateRange":{"type":"absolute","from":"2026-10-01","to":"<today>"}}
```

S2d (Stripe) is now used **only** for `no_decision`.

## M1 — Mixpanel onboarding by plan (Run-Query, insights, project 3667556)

Metrics: unique users of `UserOnboardingStarted`, `UserOnboardingPlanSelected`, `UserOnboardingCompleted`, `UserOnboardingExited`. Breakdown: event property `plan`. Date range: **2026-10-13 → yesterday** only.
Arms: `team-reverse-trial` = variant. `free` + `team` = control (post-fix only).
Use it for the onboarding-completion rate per arm: Completed ÷ Started.

## F1 — Still scanning after day 14 (guardrail, added 2026-10-18)

Share of new orgs per group with at least one completed scan in days 15–28 after creation. Only orgs at least 28 days old, so the first result is available from 2026-10-29. Same group definition as W2/P1 (control = card trial + started on Free). Not yet run end to end: validate on first use.

```sql
with neworg as (
  select organization_uuid_v4, min(_event_timestamp) as created_at
  from sonarsource.product_events.organization_created
  where _event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
grp as (
  select s.organization_uuid_v4,
    case when max(case when s.trial_type = 'CARD_LESS' then 1 else 0 end) = 1 then 'reverse_trial' else 'control' end as arm
  from sonarsource.product_events.subscription_created s
  join neworg n on n.organization_uuid_v4 = s.organization_uuid_v4
  where s._event_timestamp >= '2026-10-01 11:15:00'
  group by 1
),
base as (
  select n.organization_uuid_v4, n.created_at, g.arm
  from neworg n
  join grp g on g.organization_uuid_v4 = n.organization_uuid_v4
  left join sonarsource.sonar.dim_sc_organization d on d.organization_uuid_v4 = n.organization_uuid_v4
  where coalesce(d.is_internal, false) = false
    and n.created_at < dateadd(day, -28, current_date)
),
act as (
  select distinct b.organization_uuid_v4
  from base b
  join sonarsource.product_events.analysis_finished a
    on a.organization_uuid_v4 = b.organization_uuid_v4
   and a.analysis_status = 'completed'
   and a._event_timestamp >= dateadd(day, 15, b.created_at)
   and a._event_timestamp <  dateadd(day, 29, b.created_at)
)
select b.arm,
       count(*) as orgs_28d_old,
       count(a.organization_uuid_v4) as scanned_day15_28,
       round(100.0 * count(a.organization_uuid_v4) / count(*), 1) as pct
from base b
left join act a on a.organization_uuid_v4 = b.organization_uuid_v4
group by 1 order by 1
```


## Q11 — Paused at day 14: who is still active? (added 2026-11-07; feeds appendix section 3d)

Splits the E1 bucket `paused_day14` by scans after the pause date and by current project count. Takes about 1 minute (17-55s seen), so run it once per day and set a 180s wait. Sonar internal orgs excluded (same filter as E1). Copy the CTEs `started`, `conv`, `to_free`, `paused`, `resumed`, `canceled` and `org` from E1 unchanged, but add `p.evt_at as paused_at` to the `org` select list, then append:

```sql
, target as (select organization_uuid_v4, paused_at from org where bucket = 'paused_day14'),
proj as (
  select t.organization_uuid_v4, count(distinct p.project_id) as n_proj
  from target t
  left join sonarsource.sonar.dim_sc_project p on p.organization_uuid_v4 = t.organization_uuid_v4
  group by 1
),
scans as (
  select t.organization_uuid_v4,
    count(distinct case when a._event_timestamp > t.paused_at then trunc(a._event_timestamp) end) as days_scanned_after_pause,
    max(a._event_timestamp) as last_ok
  from target t
  join sonarsource.product_events.analysis_finished a
    on a.organization_uuid_v4 = t.organization_uuid_v4 and a.analysis_status = 'completed'
  group by 1
)
select
  case when s.organization_uuid_v4 is null then 'x_no_scan_ever'
       when s.days_scanned_after_pause = 0 then 'b_no_scan_after_pause'
       when s.days_scanned_after_pause = 1 then 'c_scanned_1_day_after_pause'
       else 'd_scanned_2plus_days_after_pause' end as seg,
  case when pr.n_proj = 0 then 'p0' when pr.n_proj = 1 then 'p1' else 'p2' end as proj_bucket,
  count(*) as orgs,
  sum(case when s.last_ok >= dateadd(day, -7, current_date) then 1 else 0 end) as scanned_last_7d
from target t
join proj pr on pr.organization_uuid_v4 = t.organization_uuid_v4
left join scans s on s.organization_uuid_v4 = t.organization_uuid_v4
group by 1, 2 order by 1, 2
/* mcp-query: ts=<ISO-8601 UTC> */
```

Map to the appendix `PAUSE_SPLIT` block: `never` = x_no_scan_ever + b_no_scan_after_pause when the org has no scan at all (x only); `silent` = b_no_scan_after_pause; `active` = c + d (`days2plus` = d orgs). Fields per segment: `orgs`, `p0`, `p1`, `p2` (orgs by project bucket), `last7` (sum of scanned_last_7d). Nov 5 check values: never 742, silent 1,934, active 390, total 3,066.
Note: an org with scans but none successful (2 orgs on Nov 5) falls in x_no_scan_ever via the join; keep it in "never".


## Q12 — Activity after day 14: paused and Free orgs (added 2026-11-07; feeds dashboard section "Are orgs still using it after day 14?")

Only orgs at least 14 days old. Buckets follow Q2 of the data guide. "Still scanning" = a completed scan after the org's own day 14. Takes about 15 seconds. Output rows map to `ACT_DATA` rows `Reverse, paused` (bucket 6, reverse) and `Normal, on Free` (bucket 5, normal): [scanning, quiet, never] = [a_after_day14, b_only_by_day14, x_never]. Reverse on Free (bucket 5, reverse) is NOT shown on purpose (those orgs chose Free).

```sql
with neworg as (select organization_uuid_v4, min(_event_timestamp)::timestamp as created_at from product_events.organization_created where organization_uuid_v4 not in (select organization_uuid_v4 from sonar.dim_sc_organization where is_internal) and _event_timestamp >= '2026-10-01 11:15:00' group by 1),
grp as (select s.organization_uuid_v4,
  max(case when s.trial_type='CARD_LESS' then 1 else 0 end) as is_rt,
  max(case when s.trial_type='CARD_BACKED' then 1 else 0 end) as is_card
  from product_events.subscription_created s join neworg n on n.organization_uuid_v4=s.organization_uuid_v4
  where s._event_timestamp >= '2026-10-01 11:15:00' group by 1),
conv as (select organization_uuid_v4, 1 as f from product_events.subscription_tier_updated where _event_timestamp >= '2026-10-01' group by 1),
to_free as (select organization_uuid_v4, 1 as f from product_events.subscription_plan_changed where fromplan='Team' and toplan like 'Free%' and _event_timestamp >= '2026-10-01' group by 1),
paused as (select organization_uuid_v4, min(_event_timestamp) as evt_at from product_events.subscription_suspended where _event_timestamp >= '2026-10-01' group by 1),
resumed as (select organization_uuid_v4, max(reactivatedplanname) as plan from product_events.subscription_resumed where _event_timestamp >= '2026-10-01' group by 1),
canceled as (select organization_uuid_v4, max(reason) as reason from product_events.subscription_canceled where _event_timestamp >= '2026-10-01' and reason in ('organization_deleted','Organization added to enterprise') group by 1),
cust as (select entity_id, customer_id, entity_name from sonar.cad_billing_customers),
paid as (select customer_id from sonar.dim_billing_charges where payment_status='succeeded' and payment_intented_at>='2026-10-01' and amount_charged>0 group by 1),
o as (select g.*, n.created_at, case
  when regexp_instr(lower(cu.entity_name),'^(sqc-e2e-tests-forge|sqc-dopex-e2e-tests-org|e2e-(gitlab|ghec|ghes|azdo)-onboarding-org-)')>0 then '0 test'
  when x.reason='organization_deleted' then '1 deleted'
  when x.reason='Organization added to enterprise' then '2 ent'
  when p2.customer_id is not null then '3 paying'
  when g.is_rt=1 and (c.f=1 or r.plan='Team') then '4 team'
  when g.is_rt=0 and g.is_card=1 and p.evt_at is null then '4 team'
  when (g.is_rt=1 and (f.f=1 or r.plan like 'Free%')) or (g.is_rt=0 and g.is_card=0) then '5 on_free'
  when p.evt_at is not null then '6 paused'
  else '7 undecided' end as bucket
 from grp g join neworg n on n.organization_uuid_v4=g.organization_uuid_v4
 left join canceled x on x.organization_uuid_v4=g.organization_uuid_v4
 left join conv c on c.organization_uuid_v4=g.organization_uuid_v4
 left join to_free f on f.organization_uuid_v4=g.organization_uuid_v4
 left join paused p on p.organization_uuid_v4=g.organization_uuid_v4
 left join resumed r on r.organization_uuid_v4=g.organization_uuid_v4
 left join cust cu on cu.entity_id=g.organization_uuid_v4
 left join paid p2 on p2.customer_id=cu.customer_id),
target as (select organization_uuid_v4, is_rt, bucket, created_at from o where bucket in ('5 on_free','6 paused') and created_at <= dateadd(day,-14,getdate())),
scans as (select t.organization_uuid_v4,
  max(case when a._event_timestamp::timestamp > dateadd(day,14,t.created_at) then 1 else 0 end) as after14
  from target t join product_events.analysis_finished a on a.organization_uuid_v4=t.organization_uuid_v4 and a.analysis_status='completed' group by 1)
select case when t.is_rt=1 then 'reverse' else 'normal' end as arm, t.bucket,
  case when s.organization_uuid_v4 is null then 'x_never' when s.after14=1 then 'a_after_day14' else 'b_only_by_day14' end as state,
  count(*) as orgs
from target t left join scans s on s.organization_uuid_v4=t.organization_uuid_v4
group by 1,2,3 order by 1,2,3
/* mcp-query: ts=<ISO-8601 UTC> */
```

## Q13 — Activity after day 14: paying orgs (added 2026-11-07)

Payers = orgs with a succeeded charge since Oct 1, minus deleted and Enterprise orgs and test orgs. "Still scanning" = a completed scan after the first payment. Maps to `ACT_DATA` rows `Reverse`, `Normal, card trial`, `Normal, started on Free` ([a_scanned_after_first_payment, b_quiet_since_first_payment, x_never]). Nov 7 values: reverse 60/5/1, normal card trial 53/15/9, normal Free start 17/5/0.

```sql
with neworg as (select organization_uuid_v4, min(_event_timestamp)::timestamp as created_at from product_events.organization_created where organization_uuid_v4 not in (select organization_uuid_v4 from sonar.dim_sc_organization where is_internal) and _event_timestamp >= '2026-10-01 11:15:00' group by 1),
grp as (select s.organization_uuid_v4,
  max(case when s.trial_type='CARD_LESS' then 1 else 0 end) as is_rt,
  max(case when s.trial_type='CARD_BACKED' then 1 else 0 end) as is_card
  from product_events.subscription_created s join neworg n on n.organization_uuid_v4=s.organization_uuid_v4
  where s._event_timestamp >= '2026-10-01 11:15:00' group by 1),
canceled as (select organization_uuid_v4, max(reason) as reason from product_events.subscription_canceled where _event_timestamp >= '2026-10-01' and reason in ('organization_deleted','Organization added to enterprise') group by 1),
cust as (select entity_id, customer_id, entity_name from sonar.cad_billing_customers),
paid as (select customer_id, min(payment_intented_at)::timestamp as first_paid from sonar.dim_billing_charges where payment_status='succeeded' and payment_intented_at>='2026-10-01' and amount_charged>0 group by 1),
t as (select g.organization_uuid_v4, g.is_rt, g.is_card, n.created_at, p2.first_paid
 from grp g join neworg n on n.organization_uuid_v4=g.organization_uuid_v4
 left join canceled x on x.organization_uuid_v4=g.organization_uuid_v4
 left join cust cu on cu.entity_id=g.organization_uuid_v4
 join paid p2 on p2.customer_id=cu.customer_id
 where x.reason is null and regexp_instr(lower(cu.entity_name),'^(sqc-e2e-tests-forge|sqc-dopex-e2e-tests-org|e2e-(gitlab|ghec|ghes|azdo)-onboarding-org-)')=0),
scans as (select t.organization_uuid_v4,
  max(case when a._event_timestamp::timestamp > t.first_paid then 1 else 0 end) as after_paid
  from t join product_events.analysis_finished a on a.organization_uuid_v4=t.organization_uuid_v4 and a.analysis_status='completed' group by 1)
select case when t.is_rt=1 then 'reverse' when t.is_card=1 then 'normal_card_trial' else 'normal_free_start' end as path,
  case when s.organization_uuid_v4 is null then 'x_never' when s.after_paid=1 then 'a_scanned_after_first_payment' else 'b_quiet_since_first_payment' end as state,
  count(*) as orgs
from t left join scans s on s.organization_uuid_v4=t.organization_uuid_v4
group by 1,2 order by 1,2
/* mcp-query: ts=<ISO-8601 UTC> */
```


## Q2v — Where every new org is today, paid-first (added 2026-11-07; feeds the status table and the "Paying now" card; replaces Q2 in the data guide)

One bucket per org, tested in this order: test org, paid (paying now or paid then stopped), deleted never paid, enterprise never paid, first charge due, on Free, paused, undecided.
- Paid then stopped = deleted, joined Enterprise, fully refunded, moved Team to Free after the first payment without a later re-upgrade, or suspended after the first payment without a later resume.
- First charge due: Reverse = latest tier-updated/resumed-Team not followed by a Team to Free move; Normal = card trial, not suspended, no Free move.
- Output: arm, bucket, paid_reason, orgs. Dashboard mapping: `1 paying_now` = Paying now; `2 paid_then_stopped` = Paid, then stopped (reasons: deleted, enterprise, refunded, moved_to_free, suspended); `5 chose_team_due` + `8 undecided` = Reverse "In trial"; `5 card_trial_due` = Normal "In trial" (no separate first-charge-due row since 2026-11-07); `6 on_free`, `7 paused`, `3 deleted_never_paid`, `4 enterprise_never_paid`, `0 test` map to the same-named rows.
- Paid once = paying now + paid then stopped (must equal the Paid-once figure from P1; see check C1).

```sql
with neworg as (select organization_uuid_v4 from product_events.organization_created where organization_uuid_v4 not in (select organization_uuid_v4 from sonar.dim_sc_organization where is_internal) and _event_timestamp >= '2026-10-01 11:15:00' group by 1),
grp as (select s.organization_uuid_v4, max(case when s.trial_type='CARD_LESS' then 1 else 0 end) as is_rt, max(case when s.trial_type='CARD_BACKED' then 1 else 0 end) as is_card
  from product_events.subscription_created s join neworg n on n.organization_uuid_v4=s.organization_uuid_v4 where s._event_timestamp >= '2026-10-01 11:15:00' group by 1),
up as (select organization_uuid_v4, max(at) as at from (select organization_uuid_v4, _event_timestamp as at from product_events.subscription_tier_updated where _event_timestamp >= '2026-10-01' union all select organization_uuid_v4, _event_timestamp from product_events.subscription_resumed where reactivatedplanname='Team' and _event_timestamp >= '2026-10-01') group by 1),
frd as (select organization_uuid_v4, max(_event_timestamp) as at from product_events.subscription_plan_changed where fromplan='Team' and toplan like 'Free%' and _event_timestamp >= '2026-10-01' group by 1),
resfree as (select organization_uuid_v4, 1 as f from product_events.subscription_resumed where reactivatedplanname like 'Free%' and _event_timestamp >= '2026-10-01' group by 1),
sus as (select organization_uuid_v4, min(_event_timestamp) as first_at, max(_event_timestamp) as last_at from product_events.subscription_suspended where _event_timestamp >= '2026-10-01' group by 1),
resm as (select organization_uuid_v4, max(_event_timestamp) as at from product_events.subscription_resumed where _event_timestamp >= '2026-10-01' group by 1),
cnl as (select organization_uuid_v4, max(reason) as reason from product_events.subscription_canceled where _event_timestamp >= '2026-10-01' and reason in ('organization_deleted','Organization added to enterprise') group by 1),
cust as (select entity_id, customer_id, entity_name from sonar.cad_billing_customers),
ch as (select customer_id, min(payment_intented_at) as first_paid, sum(amount_charged) as charged, sum(coalesce(amount_refunded,0)) as refunded from sonar.dim_billing_charges where payment_status='succeeded' and payment_intented_at>='2026-10-01' and amount_charged>0 group by 1),
o as (select g.is_rt, g.is_card, ch.first_paid, case
  when regexp_instr(lower(cu.entity_name),'^(sqc-e2e-tests-forge|sqc-dopex-e2e-tests-org|e2e-(gitlab|ghec|ghes|azdo)-onboarding-org-)')>0 then '0 test'
  when ch.customer_id is not null and (cnl.reason='organization_deleted' or cnl.reason='Organization added to enterprise' or ch.refunded>=ch.charged
      or (frd.at > ch.first_paid and (up.at is null or up.at < frd.at))
      or (sus.last_at > ch.first_paid and (resm.at is null or resm.at < sus.last_at))) then '2 paid_then_stopped'
  when ch.customer_id is not null then '1 paying_now'
  when cnl.reason='organization_deleted' then '3 deleted_never_paid'
  when cnl.reason='Organization added to enterprise' then '4 enterprise_never_paid'
  when g.is_rt=1 and up.at is not null and (frd.at is null or frd.at < up.at) then '5 chose_team_due'
  when g.is_rt=0 and g.is_card=1 and frd.at is null and sus.first_at is null then '5 card_trial_due'
  when frd.at is not null or rf.f=1 or (g.is_rt=0 and g.is_card=0) then '6 on_free'
  when sus.first_at is not null then '7 paused'
  else '8 undecided' end as bucket,
  case when ch.customer_id is not null then case when cnl.reason='organization_deleted' then 'deleted' when cnl.reason='Organization added to enterprise' then 'enterprise' when ch.refunded>=ch.charged then 'refunded' when frd.at > ch.first_paid then 'moved_to_free' when sus.last_at > ch.first_paid then 'suspended' else 'paying' end end as paid_reason
 from grp g left join cust cu on cu.entity_id=g.organization_uuid_v4 left join ch on ch.customer_id=cu.customer_id left join cnl on cnl.organization_uuid_v4=g.organization_uuid_v4
 left join up on up.organization_uuid_v4=g.organization_uuid_v4 left join frd on frd.organization_uuid_v4=g.organization_uuid_v4 left join resfree rf on rf.organization_uuid_v4=g.organization_uuid_v4
 left join sus on sus.organization_uuid_v4=g.organization_uuid_v4 left join resm on resm.organization_uuid_v4=g.organization_uuid_v4)
select case when is_rt=1 then 'reverse' else 'normal' end as arm, bucket, coalesce(paid_reason,'-') as paid_reason, count(*) as orgs
from o group by 1,2,3 order by 1,2,3
/* mcp-query: ts=<UTC> */
```

## Q14 — Overdue first charge (added 2026-11-07; Health line only, not on the dashboard)

Normal-trial orgs that are not test or internal orgs, whose trial ended more than 3 days ago, with no succeeded charge and not suspended. Count per arm, log each run; Health line when the count rises 20% or more versus yesterday's log. On Nov 7 this was 44 Normal orgs (cause unknown, with the Billing squad).
Use the `grp`, `sus`, `ch`, `cust` CTEs of Q2v; select `is_card=1` orgs with `subscription_created` older than 17 days, `ch.customer_id is null`, `sus.first_at is null`, and `bucket` = `5 card_trial_due`. Count only.

## Daily reconciliation checks (added 2026-11-07; any failure = safety stop, do not republish)

| # | Check | Pass when |
|---|---|---|
| C1 | Paying now + Paid then stopped = Paid once (P1) per arm | Equal (Nov 7: Reverse 66, Normal 101) |
| C2 | Sum of all status rows incl. test orgs = All new orgs per arm | Equal (Nov 7: 7,678 / 7,279) |
| C3 | "Paying now" card = Paying now row of the table | Equal |
| C4 | Cash card = sum of per-org net cash (USD, fixed rates) | Within $1 |
| C5 | Payer activity (Q13) rows add up to Paying now per arm (Reverse 66; Normal 77 + 22 = 99); Reverse paused activity total = Paused at day 14 row | Payers exact; paused within 1%. Normal on Free is age-filtered (3,708 of 5,912) and not checked. |
| C6 | Appendix paused total (Q11) vs main-page Paused at day 14 | Within 1% (Nov 7: 3,196 vs 3,195) |
| C7 | New currency or new cancel/suspend reason in the data | Stop and DM Simone; Health line |
