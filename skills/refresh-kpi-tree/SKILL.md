---
name: refresh-kpi-tree
description: >-
  Refresh the Growth KPI tree HTML with live sales-led and self-serve GRR/NRR
  from Redshift. Use when someone says "update the KPI tree", "refresh the KPI
  HTML", "pull GRR NRR onto the page", "/refresh-kpi-tree", or "update
  growth-kpi-tree html". Two books only (sales-led vs Stripe Team Monthly).
  Does not publish to Confluence or Slack. Does not invent Max/Team Monthly
  operating numbers.
---

# Refresh KPI tree HTML

Rewrite `DATA.books` in the shareable KPI page from Redshift. Leave operating-tree snapshots (Max, Mixpanel, stubs) alone.

## Defaults (tell the user)

- Saving the skill to `.claude/skills/refresh-kpi-tree/` per the team default
- Patching `publish/growth-kpi-tree-YYYY-MM-DD.html` (latest dated file) — not a new file
- **Not** publishing to Confluence or Slack
- **Not** blending the two books into a combined GRR/NRR on the stakeholder cards
- **Not** putting MoM on the stakeholder strip (store MoM on each book for the grain tab only)

## Do not

- Invent Max 90-day, AutoScan, or user/project staircases
- Use `fct_sales_combined_arr_waterfall_yearly` as the displayed KR (store `combinedGrr` / `combinedNrr` only as the “do not use” figure)
- Take `max(period_end_date)` — that table has future month buckets through 2027. Use `last_day(current_date)`
- Overwrite self-serve from Laura’s Metabase 397 query
- Auto-publish

## Page

Glob `publish/growth-kpi-tree-*.html` and edit the latest. The JSON lives in `<script id="data">`. Patch the `books` object in place. The page JS renders cards from that object — do not hardcode numbers in HTML.

## Warehouse

Atlan `query_assets_tool`:

- `connection_qualified_name`: `default/redshift/1720789348`
- `database`: `sonarsource`
- `schema`: `sonar`

Fallback: same SQL on SonarData if Atlan is down. If both fail, stop and name the gap — do not invent.

### Books

| Book | Table | What it is |
|---|---|---|
| Sales-led | `cad_sonar_company_arr_monthly` (begin) + `fct_sales_company_arr_waterfall_yearly` (end / churn / downsell) | SQS + SQC Ent + SQC Team Annual. Storefront KR. **USD. Tableau ELT definition.** |
| Self-serve | `sonar.fct_sales_online_arr_waterfall_yearly` (+ `_monthly`) | SQC Team Monthly / Stripe. **EUR actual** (not on Tableau ELT). |
| Combined (do not display as KR) | `sonar.fct_sales_combined_arr_waterfall_yearly` | Blend. Store only for the “do not use” line. |

### Formula

**Sales-led (Tableau ELT):** beginning book = companies with `period_ending_arr_usd > 0` in `cad_sonar_company_arr_monthly` on the date 12 months before `period_end_date`. Left-join yearly waterfall for those companies on `period_end_date`.

- **GRR** = `sum(begin_usd + downsell + churn) / sum(begin_usd)`
- **NRR** = `sum(coalesce(waterfall prior_usd + growth_usd, 0)) / sum(begin_usd)`
- `downsell` / `churn` from yearly waterfall `arr_growth_usd_actual` (`Downsell`; `Churn|Lost|Lapsed|Dormant`)
- Do **not** use `(waterfall prior + growth − new) / waterfall prior` for this book — that is ~1pp above ELT NRR

Closed months should match ELT bars (Dec NRR **121.2%**, Jul **119.6%**). Current month can sit a few tenths above the extract while MTD. CAD itself may not yet have the current month — still use CAD for the *beginning* (12 months ago) and waterfall for *ending*.

**Self-serve and combined:** unchanged EUR waterfall.

- **GRR** = `(prior + downsell + churn) / prior`
- **NRR** = `(prior + total_growth − new) / prior`
- columns = `*_eur_actual`

Round rates to 1 decimal. `priorM` = beginning ARR / 1e6, 1 decimal.

### SQL (run this)

Periods: `last_day(current_date)`, the prior three month-ends, and `date '2025-12-31'` (sales-led KR baseline only).

```sql
with periods as (
  select last_day(current_date) as d union all
  select last_day(dateadd(month, -1, current_date)) union all
  select last_day(dateadd(month, -2, current_date)) union all
  select last_day(dateadd(month, -3, current_date)) union all
  select date '2025-12-31'
),
sales_led as (
  select b.period_end_date,
    sum(b.begin_usd) as prior_amt,
    sum(b.begin_usd + coalesce(e.down_usd,0) + coalesce(e.churn_usd,0)) as grr_num,
    sum(coalesce(e.end_usd,0)) as nrr_num
  from (
    select p.d as period_end_date, c.company_account_id, c.period_ending_arr_usd as begin_usd
    from periods p
    join sonar.cad_sonar_company_arr_monthly c
      on c.period_end_date = dateadd(month, -12, p.d)::date
    where c.period_ending_arr_usd > 0
  ) b
  left join (
    select period_end_date, company_account_id,
      sum(prior_period_arr_usd_actual + arr_growth_usd_actual) as end_usd,
      sum(case when movement_type = 'Downsell' then arr_growth_usd_actual else 0 end) as down_usd,
      sum(case when movement_type in ('Churn','Lost','Lapsed','Dormant') then arr_growth_usd_actual else 0 end) as churn_usd
    from sonar.fct_sales_company_arr_waterfall_yearly
    where period_end_date in (select d from periods)
    group by 1, 2
  ) e
    on b.company_account_id = e.company_account_id
    and b.period_end_date = e.period_end_date
  group by 1
),
books as (
  select 'sales-led' as book, 'yoy' as window, period_end_date,
    grr_num as retained_or_end,
    prior_amt,
    nrr_num as end_amt
  from sales_led
  union all
  select 'online', 'yoy', period_end_date,
    sum(prior_period_arr_eur_actual) + sum(case when movement_type = 'Downsell' then arr_growth_eur_actual else 0 end) + sum(case when movement_type in ('Churn','Lost','Lapsed','Dormant') then arr_growth_eur_actual else 0 end),
    sum(prior_period_arr_eur_actual),
    sum(prior_period_arr_eur_actual) + sum(arr_growth_eur_actual) - sum(case when movement_type = 'New' then arr_growth_eur_actual else 0 end)
  from sonar.fct_sales_online_arr_waterfall_yearly
  where period_end_date in (select d from periods)
  group by 1, 2, 3
  union all
  select 'combined', 'yoy', period_end_date,
    sum(prior_period_arr_eur_actual) + sum(case when movement_type = 'Downsell' then arr_growth_eur_actual else 0 end) + sum(case when movement_type in ('Churn','Lost','Lapsed','Dormant') then arr_growth_eur_actual else 0 end),
    sum(prior_period_arr_eur_actual),
    sum(prior_period_arr_eur_actual) + sum(arr_growth_eur_actual) - sum(case when movement_type = 'New' then arr_growth_eur_actual else 0 end)
  from sonar.fct_sales_combined_arr_waterfall_yearly
  where period_end_date = last_day(current_date)
  group by 1, 2, 3
  union all
  select 'sales-led', 'mom', period_end_date,
    sum(prior_period_arr_usd_actual) + sum(case when movement_type = 'Downsell' then arr_growth_usd_actual else 0 end) + sum(case when movement_type in ('Churn','Lost','Lapsed','Dormant') then arr_growth_usd_actual else 0 end),
    sum(prior_period_arr_usd_actual),
    sum(prior_period_arr_usd_actual) + sum(arr_growth_usd_actual) - sum(case when movement_type = 'New' then arr_growth_usd_actual else 0 end)
  from sonar.fct_sales_company_arr_waterfall_monthly
  where period_end_date = last_day(current_date)
  group by 1, 2, 3
  union all
  select 'online', 'mom', period_end_date,
    sum(prior_period_arr_eur_actual) + sum(case when movement_type = 'Downsell' then arr_growth_eur_actual else 0 end) + sum(case when movement_type in ('Churn','Lost','Lapsed','Dormant') then arr_growth_eur_actual else 0 end),
    sum(prior_period_arr_eur_actual),
    sum(prior_period_arr_eur_actual) + sum(arr_growth_eur_actual) - sum(case when movement_type = 'New' then arr_growth_eur_actual else 0 end)
  from sonar.fct_sales_online_arr_waterfall_monthly
  where period_end_date = last_day(current_date)
  group by 1, 2, 3
)
select book, window, period_end_date,
  round(100.0 * retained_or_end / nullif(prior_amt, 0), 1) as grr_pct,
  round(100.0 * end_amt / nullif(prior_amt, 0), 1) as nrr_pct,
  round(prior_amt / 1e6, 1) as prior_m
from books
order by book, window, period_end_date
```

**Do not** also run the waterfall-only sales-led query `(prior + growth − new) / prior` in USD on `fct_sales_company_arr_waterfall_yearly` and treat it as this card. That NRR sits ~1pp above Tableau ELT. The sales-led block above is CAD beginning book + waterfall ending.

Redshift `dateadd` / `last_day` are the dialect. If `dateadd` fails, use `date_trunc('month', current_date) - interval '1 month'` equivalents.

## Constants (edit here when Ori changes the KR)

Do not pull targets from the warehouse.

- Sales-led `grrTarget`: `95.3`
- Sales-led `nrrTarget`: `122.2`
- `targetLabel`: `Dec 2026`
- Sales-led baseline period: `2025-12-31` → `fromLabel` `Dec 2025`
- Self-serve has **no** company KR (`grrTarget` / `nrrTarget` = `null`)
- Self-serve YoY trend: **May onward only** (online yearly coverage before mid-2025 is thin; Dec 2025 prior ARR was ~€1.0M)

## Patch `books`

Keep this shape (numbers from the query):

```json
"books": {
  "refreshed": "<today ISO>",
  "period": "<current month-end>",
  "periodLabel": "<Mon YYYY>",
  "window": "yoy",
  "combinedGrr": 90.6,
  "combinedNrr": 115.1,
  "salesLed": { "currency": "USD", "priorM": 331.8, "...trend last 4 YoY months..." },
  "selfServe": { "currency": "EUR", "priorM": 28.6, "...trend May–current..." }
}
```

Also refresh gap `#03b` “have” with `priorM / 100` on the sales-led book (USD). Do not rewrite other gaps.

Keep the **Source** chips on both book cards. The sales-led dialog must document the Tableau ELT definition (CAD begin + waterfall end) — do not revert its GRR/NRR lines to `(prior + growth − new) / prior`. SQL lives in page JS (`SOURCE_SQL`). **Copy all for an agent** pastes definition + do-nots + SQL. Metabase 397 is a *different* definition (ARR stock YoY %), not this page’s waterfall NRR. Do not overwrite self-serve numbers from Laura’s query.

Month labels: `Jan` … `Dec` from `period_end_date`.

## After the patch

Show the user a 4-row table (sales-led GRR/NRR, self-serve GRR/NRR, vs last month YoY, vs KR if any). Remind them the file is Confidential — open in Island, do not GitHub Pages.
