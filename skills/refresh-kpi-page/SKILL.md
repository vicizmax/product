---
name: refresh-kpi-page
description: >-
  Refresh the shareable KPI page HTML with live retention rates from the
  warehouse. Use when someone says "update the KPI tree", "refresh the KPI
  HTML", "pull the rates onto the page", "/refresh-kpi-page", or "update the
  KPI html". Updates only the books listed in the config. Does not publish.
  Does not invent numbers for sections marked leave-alone.
---

# Refresh KPI page HTML

> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent tables, formulas, targets, or rates that are not in the config. The query below is empty on purpose.

Rewrite `{{BOOKS_OBJECT_PATH}}` in the shareable KPI page from the warehouse. Leave `{{LEAVE_ALONE}}` alone.

## Config — fill in once

| Token | Replace with |
|---|---|
| `{{KPI_PAGE_GLOB}}` | Glob for the dated HTML page. Edit the latest file. Do not create a new file. |
| `{{DATA_SCRIPT_ID}}` | `id` of the `<script>` tag that holds the page JSON. |
| `{{BOOKS_OBJECT_PATH}}` | Object inside that JSON to patch in place. The page JS renders cards from it. |
| `{{LEAVE_ALONE}}` | Sections, snapshots, and staircases this skill must not rewrite or invent. |
| `{{WAREHOUSE_QUERY_TOOL}}` | Tool that runs the warehouse query. Match by name. Do not hardcode a server id. |
| `{{WAREHOUSE_CONNECTION}}` | Connection id the tool expects. |
| `{{WAREHOUSE_DATABASE}}` | Database. |
| `{{WAREHOUSE_SCHEMA}}` | Schema. |
| `{{WAREHOUSE_FALLBACK}}` | Second way to run the same SQL if the first tool is down. If both fail, stop. |
| `{{RATE_1}}` | First rate the cards show (name people use, such as GRR). |
| `{{RATE_2}}` | Second rate the cards show (name people use, such as NRR). |
| `{{STAKEHOLDER_WINDOW}}` | Window shown on the stakeholder cards (for example year over year). |
| `{{GRAIN_WINDOW}}` | Finer window stored on each book for the grain tab only. Do not put it on the stakeholder strip. |
| `{{DO_NOT_PUBLISH}}` | Destinations this skill must not publish to. |
| `{{DISTRIBUTION_RULE}}` | How the file may be opened and shared. |
| `{{PERIOD_RULE}}` | How to pick the period. Say so if a table contains future buckets and `max(period)` would be wrong. |
| `{{DO_NOT_OVERWRITE_FROM}}` | A different definition or query that must not replace a book's numbers. Name the book and the source. |
| `{{WRONG_DEFINITION}}` | A formula that looks close but must not be used for a displayed book. Say which book, and how you can tell it is wrong. |
| `{{CLOSED_MONTH_CHECKS}}` | Closed periods whose rates are already agreed. Use them as a sanity check. Leave blank if you have none. |
| `{{EXTRA_PATCH_RULES}}` | Other fields on the page to refresh from this same result. Leave blank to patch books only. |
| `{{TARGET_LABEL}}` | Label for the target date. Targets are typed here. Do not pull them from the warehouse. |
| `{{BASELINE_PERIOD}}` | Baseline period for the book that has one. |
| `{{BASELINE_LABEL}}` | Label for that baseline. |

### Books

One row per book the query returns. `Display` = yes means the stakeholder cards show it. A row with `Display` = no is stored only so the page can show a "do not use" figure. Do not blend display books into one combined rate on the cards.

| Key | What it is | Display | Currency | Targets | Trend start | Formula |
|---|---|---|---|---|---|---|
| `{{BOOK_1_KEY}}` | {{BOOK_1_WHAT}} | yes | {{BOOK_1_CURRENCY}} | {{RATE_1}} `{{BOOK_1_RATE_1_TARGET}}`, {{RATE_2}} `{{BOOK_1_RATE_2_TARGET}}` | full returned trend | {{BOOK_1_FORMULA}} |
| `{{BOOK_2_KEY}}` | {{BOOK_2_WHAT}} | yes | {{BOOK_2_CURRENCY}} | none (`null`) unless you fill `{{BOOK_2_RATE_1_TARGET}}` and `{{BOOK_2_RATE_2_TARGET}}` | {{BOOK_2_TREND_START}} | {{BOOK_2_FORMULA}} |
| `{{DO_NOT_DISPLAY_KEY}}` | {{DO_NOT_DISPLAY_WHAT}} | no | {{DO_NOT_DISPLAY_CURRENCY}} | none | current period only | {{DO_NOT_DISPLAY_FORMULA}} |

Add or delete rows to match the page. Paste each formula in words (numerator, denominator, which table, which movement types). Do not leave another product's formula here.

## Defaults (tell the user)

- Patching the latest file matching `{{KPI_PAGE_GLOB}}` — not a new file
- **Not** publishing to `{{DO_NOT_PUBLISH}}`
- **Not** blending display books into one combined rate on the stakeholder cards
- **Not** putting `{{GRAIN_WINDOW}}` on the stakeholder strip (store it on each book for the grain tab only)

## Do not

- Invent numbers for `{{LEAVE_ALONE}}`
- Show `{{DO_NOT_DISPLAY_KEY}}` as the displayed target. Store it only as the "do not use" figure.
- Pick a period in a way that breaks `{{PERIOD_RULE}}`
- Overwrite a book from `{{DO_NOT_OVERWRITE_FROM}}`
- Use `{{WRONG_DEFINITION}}` for a displayed book
- Auto-publish
- Fill a `{{TOKEN}}` from memory of another team's tables, targets, or rates

## Page

Glob `{{KPI_PAGE_GLOB}}` and edit the latest. The JSON lives in `<script id="{{DATA_SCRIPT_ID}}">`. Patch `{{BOOKS_OBJECT_PATH}}` in place. The page JS renders cards from that object — do not hardcode numbers in HTML.

## Warehouse

Call `{{WAREHOUSE_QUERY_TOOL}}` with:

- Connection: `{{WAREHOUSE_CONNECTION}}`
- Database: `{{WAREHOUSE_DATABASE}}`
- Schema: `{{WAREHOUSE_SCHEMA}}`

Fallback: the same SQL via `{{WAREHOUSE_FALLBACK}}` if the first tool is down. If both fail, stop and name the gap — do not invent.

### Query (paste this)

Periods follow `{{PERIOD_RULE}}`. Include `{{BASELINE_PERIOD}}` when that token is set.

```sql
-- PASTE THE REFRESH QUERY HERE
-- One row per book × window × period.
-- Return:
--   book            -- a Key from the books table
--   window          -- {{STAKEHOLDER_WINDOW}} or {{GRAIN_WINDOW}}
--   period_end_date
--   rate_1          -- {{RATE_1}}, already a percent to 1 decimal, or the numerator and denominator
--   rate_2          -- {{RATE_2}}, same
--   prior_amount    -- beginning amount for the card (the page may scale it)
-- Use the formula on that book's row. Do not use {{WRONG_DEFINITION}}.
```

If the warehouse dialect rejects a date function, rewrite that function only. Do not change the formula.

Round rates to 1 decimal. Scale the beginning amount the way the page already does.

## Constants

Do not pull targets from the warehouse. Read them from the books table and from `{{TARGET_LABEL}}`, `{{BASELINE_PERIOD}}`, and `{{BASELINE_LABEL}}`.

After the query returns, check `{{CLOSED_MONTH_CHECKS}}` when that token is set. If a closed month disagrees, stop and show both numbers. Do not silently take the new one.

## Patch the books object

Keep the shape the page already uses. Fill numbers from the query. Map each display book onto its object. Map the do-not-display book onto the "do not use" fields only.

```json
{
  "refreshed": "<today ISO>",
  "period": "<current period end>",
  "periodLabel": "<label>",
  "window": "{{STAKEHOLDER_WINDOW}}",
  "doNotUse": {
    "book": "{{DO_NOT_DISPLAY_KEY}}",
    "rate1": "<from query>",
    "rate2": "<from query>"
  },
  "{{BOOK_1_KEY}}": {
    "currency": "{{BOOK_1_CURRENCY}}",
    "priorAmount": "<scaled beginning amount>",
    "rate1Target": "{{BOOK_1_RATE_1_TARGET}}",
    "rate2Target": "{{BOOK_1_RATE_2_TARGET}}",
    "targetLabel": "{{TARGET_LABEL}}",
    "trend": []
  },
  "{{BOOK_2_KEY}}": {
    "currency": "{{BOOK_2_CURRENCY}}",
    "priorAmount": "<scaled beginning amount>",
    "rate1Target": null,
    "rate2Target": null,
    "trend": []
  }
}
```

Apply `{{EXTRA_PATCH_RULES}}` after the books patch. If that token is blank, do not rewrite other fields.

Keep the source chips on each display-book card. Each book's dialog must document that row's formula. Do not replace it with `{{WRONG_DEFINITION}}`. Where the page has a "copy for an agent" control, it pastes the definition, the do-nots, and the SQL that was run. `{{DO_NOT_OVERWRITE_FROM}}` is a different definition. Do not copy its numbers onto a book.

Period labels come from `period_end_date`, in the page's existing month style.

`{{BOOK_2_KEY}}` trend starts at `{{BOOK_2_TREND_START}}`. Drop earlier points when that token says coverage is too thin.

## After the patch

Show a short table: each display book's `{{RATE_1}}` and `{{RATE_2}}`, versus the prior `{{STAKEHOLDER_WINDOW}}` period, and versus target when the book has one.

Then remind the user of `{{DISTRIBUTION_RULE}}`.

## Edge cases

- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a table, a target, or a rate.
- **Query returns no row for a display book:** stop and name the book. Do not leave the old number unlabeled, and do not invent a replacement.
- **Closed-month check fails:** stop and show the query value next to `{{CLOSED_MONTH_CHECKS}}`.
