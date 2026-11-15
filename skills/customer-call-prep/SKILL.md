---
name: customer-call-prep
description: Generate structured pre-call briefs for external customer meetings as Word documents (.docx) saved to the team's "Sonar Call Briefs" Drive folder. Pulls from Glean (Salesforce), Zoom transcripts, Gmail, Confluence, Jira, Mixpanel, and SonarData in parallel. Right-click a brief in Drive → "Open with Google Docs" to view as a polished editable Google Doc. Two modes — single-call (one brief, chat reply) and batch (all tomorrow's external calls, Slack DM summary). Use this skill whenever the user is preparing for ANY external customer call, interview, or touchpoint, OR asks to batch-prep multiple calls. Triggers include "prep me for my next call," "I have a call with [customer]," "brief me on [company]," "customer interview prep," "what do I need to know about [account]," "prep my calls for tomorrow," "batch prep," or any mention of an upcoming external meeting that needs context.
---

# Customer Call Prep

Assemble structured pre-call briefs for external customer calls. Pull from multiple sources in parallel, generate a Word document (.docx), save to the team's "Sonar Call Briefs" Drive folder. Right-click → "Open with Google Docs" in Drive renders the brief as a polished editable Google Doc with proper headings, tables, lists, and formatting preserved.

## Tone & kickoff

- **State the target day in the first user-facing message** so the user can correct early. Example: `Briefing for Mon, Jun 1 — pulling calendar...`
- **Narrate as little as possible.** The DOCX brief and the Slack post are the deliverable; the chat reply is a confirmation line. Don't liveblog every fan-out tool call.
- **Don't ask permission for each step.** The user invoked the skill — they want the briefs, not a status meeting. The only legitimate questions are mode disambiguation (Step 1) and stop-on-error reports.

## Modes

| Mode | Trigger | Output | Chat / Slack |
|---|---|---|---|
| **single-call** | Explicit single-call phrasing — "prep me for my 3pm", "brief me on Acme", "I have a call with X", "what do I need to know about [account]", any **named-customer** request | 1 DOCX | Chat reply with file path + 2-3 standout findings |
| **batch** | Any **plural-implying** call phrasing — "prep my calls for tomorrow", "prep tomorrow's calls", "prep today's calls", "prep today's remaining calls", "prep my remaining calls", "batch prep", "my calls", OR invoked by the `batch-call-prep` scheduled task | N DOCXs (one per external call) | Slack DM + channel post + per-attendee DMs |

**Mode is determined by wording, not by how many calls are found.**

- If batch wording is used but only **1 call** matches → **still run the batch flow** (DM + channel post + per-attendee DMs), just with one bullet. Do not silently downgrade to single-call.
- If batch wording is used but **0 calls** match → post the short "no external calls" DM and stop.
- If trigger is genuinely ambiguous (e.g. "prep my call" — singular but unspecified) → default to single-call mode and ask "is this for tomorrow's calls (batch) or just one call (single)?".

**Why this matters:** a teammate asking "prep today's remaining calls" expects their internal co-attendees to get pinged. Treating it as single-call because only one call remains breaks that contract — the teammate gets a brief, but their co-attendees don't know one exists.

## Scheduling — running this daily

**Installing this skill does not make it run automatically.** A skill is a passive set of instructions — it only fires when someone (or a scheduled task) invokes it with matching trigger wording. To get a daily morning brief in Slack, set up a recurring scheduled task **once per user**. Scheduled tasks are per-user; there's no team-wide install.

Two ways to wire it up — pick one:

### Option A — Claude Desktop UI (no MCP required)

1. Open Claude Desktop → click the clock icon in the chat input toolbar (or `Settings → Scheduled tasks`).
2. **New task.** Configure:
   - **Prompt:** `prep tomorrow's calls`
   - **Schedule:** Mon–Fri at the time you want the brief delivered (e.g. `21:00 Sun–Thu` for night-before, or `07:00 Mon–Fri` for morning-of)
   - **Name:** `Customer call prep — daily batch`
3. Save. Claude runs the task at the scheduled time, the skill picks up the batch trigger, and the brief lands in your Slack DM.

### Option B — Programmatic via the scheduled-tasks MCP

If the `mcp__scheduled-tasks__create_scheduled_task` MCP is connected, ask Claude in chat:

```
Create a recurring scheduled task: run "prep tomorrow's calls" every weekday at 21:00 local time. Name it "Customer call prep — daily batch".
```

Claude will create the task via the MCP. Verify with `mcp__scheduled-tasks__list_scheduled_tasks`.

### Tuning the schedule

| Time | Why |
|---|---|
| **Night before, 21:00** | Brief is waiting when you start your day. Slight risk: calendar changes overnight aren't reflected |
| **Morning of, 06:30–07:30** | Latest calendar state; takes a few minutes to run, so leave buffer before your first meeting |
| **Both** | Run twice. The skill's dedup logic (Step 1.5) reuses existing briefs and won't regenerate from scratch |

### For Growth team members

The team's `/setup-personal-rhythm` skill handles other recurring rhythms (morning brief, EOD sweep). It does not yet wire up call prep — keep an eye out for that being folded in.

### Caveat — Slack notifications on the recipient end

Even with the schedule running, **self-DMs in Slack don't fire push/banner notifications** (covered in Step 5c). The brief lands in your "you to you" sidebar entry. Channel posts (Step 5d) DO notify the @-mentioned internal attendees normally. If you want a louder personal alert for yourself, consider posting to your own DM channel instead of self-DM, or rely on the channel @-mention if you're listed as an internal attendee.

## Step 0 — Resolve user and paths

Run `echo "$USER"` via Bash. Derive:
- `firstname` = lowercase before first `.`
- `output_dir` = `/Users/$USER/Library/CloudStorage/GoogleDrive-$USER@sonarsource.com/Shared drives/TM_Product_All/Product Management/Shared Knowledge/User Research/User Interview/Sonar Call Briefs`
- `skill_dir` = the directory containing **this** SKILL.md file (the customer-call-prep skill folder)
- `helper_script` = `<skill_dir>/call-prep-to-docx.py`

Verify `<output_dir>` exists — it's the team-shared "Sonar Call Briefs" folder on the `TM_Product_All` shared drive, which is the canonical location for briefs. If the folder doesn't exist locally, the user hasn't added the `TM_Product_All` shared drive to their Google Drive sync list. **Stop and ask them to sync it** ("Open Google Drive → Shared drives → right-click `TM_Product_All` → Add to My Drive / sync"). Do not write briefs to any other location — the shared folder is where teammates expect to find them.

**Helper-script existence check (CRITICAL — prevents broken DOCX uploads):**

Verify `<helper_script>` exists:

```bash
test -f "<helper_script>" && echo "ok" || echo "missing"
```

- **If "ok":** proceed normally.
- **If "missing":** the user is running the skill from a copy without the bundled helper script. **Auto-recover by writing the embedded fallback in Appendix A (at the bottom of this file) to `/tmp/call-prep-to-docx.py`, then set `helper_script = /tmp/call-prep-to-docx.py`.** Continue with the rest of the flow as normal.

**STRICT PROHIBITION — never improvise the DOCX:**

Do NOT under any circumstances:
- Fall back to `mcp__69638a02-...__create_file` to upload an inline-generated DOCX. The Drive MCP chunks files over a few KB and produces broken DOCX that don't render in Google Docs.
- Write a different/simpler DOCX generator inline. The helper script is the only sanctioned path.
- "Split" the brief across multiple files because something seems too big. Briefs are normal-sized; there's no legitimate reason to chunk them.

If the helper-script path is broken in some way that auto-recovery doesn't fix, stop and report the failure clearly. A halted run is better than a broken file linked from Slack.

## Step 0.5 — Tool availability check

Before fanning out, verify which MCPs are connected. State in one line which sources will be skipped — don't ask the user to fix anything, just degrade gracefully.

| Source | MCP prefix | If missing |
|---|---|---|
| Glean (Salesforce, broad context) | `mcp__a52ac0c2-...` | Commercial + contacts + broad-context sections empty |
| Zoom | `mcp__9dcd6671-...` | Past-call summaries empty |
| Gmail | `mcp__915b50f9-...` | Recent thread context empty |
| Confluence + Jira (Rovo) | `mcp__200a7382-...` | Internal research / tickets empty |
| SonarData (Atlan / Redshift) | `mcp__954cc09e-...` | Product usage + health signals empty |
| Mixpanel | `mcp__6f09e2ef-...` | Behavioral / funnel metrics empty |
| Google Drive | `mcp__69638a02-...` | Drive URL resolution falls back to filename-only |
| Slack (post) | `mcp__eb354c09-...` | Cannot post DM / channel summary; chat reply still works |

## Step 1 — Identify the call(s)

### Resolve the target day (batch mode only)

Default is **tomorrow** (full day, midnight to midnight in the user's local timezone).

Override the default if the invocation contains:

| User says... | Target day |
|---|---|
| "tomorrow", "tomorrow's calls", no day specified, or invoked by the scheduled task | Tomorrow, full day (default) |
| "today", "today's calls", "rest of today", "today's remaining calls", "my remaining calls" | Today, **from now to 23:59 local** |
| A specific day name ("Monday", "Thursday") | That day's full window. If the day name is in the past for this week, interpret as **next week's** occurrence |
| A specific date ("May 5", "June 15", "2026-06-15") | That full day |
| "this week", "the rest of the week" | Ambiguous — ask which day, don't fan out across multiple days |

State the resolved target day in the kickoff message (per the Tone & kickoff section).

### Single-call mode

- **If a customer is named in the request:** use that directly.
- **Otherwise:** query Google Calendar via `mcp__1f3bfc5c-f599-4189-a6d2-884689350fef__list_events` for the next event whose attendees include external (non-`@sonarsource.com`) email addresses. Extract: company name, key external attendee, meeting title, date/time.
- **If no external event found:** ask which customer.
- **If multiple external calls today:** default to the soonest; confirm.
- **If all attendees are internal:** stop and confirm — likely not the right meeting.

### Batch mode

- Query Google Calendar for **the resolved target day's events** (per the "Resolve the target day" sub-step above). Pass `timeMin` and `timeMax` accordingly.
- Filter to events with at least one external (non-`@sonarsource.com`) attendee.
- **Exclude events the user has declined** (`responseStatus = declined`) and **cancelled events** (`status = cancelled`).
- **Exclude external events that aren't customer calls.** Title patterns to drop:
  - `Interview with…`, `Candidate screen`, anything with "recruiting" / "candidate" / "screening" — these are hiring, not customers
  - `[VendorName] demo`, `Vendor sync`, procurement / sales-to-Sonar calls — Sonar is the customer, not the prospect
  - Internal communities of practice or partner meetings where the "external" attendee is a known partner/vendor, not a customer
  - **When in doubt, include.** False positives are cheap (a brief no one reads); missed briefs aren't (a teammate walks into a customer call blind).
- For each remaining external event, identify: company (from email domain or attendee name), key external attendee (first non-`@sonarsource.com` person), meeting time in **both CEST (Geneva, Europe/Zurich) and CDT (Austin, America/Chicago)** — Geneva first, then Austin, formatted `HH:MM CEST / HH:MM CDT`, meeting title.

**CRITICAL — Google Calendar timezone parsing.** This is easy to get wrong. When you call `list_events` with `timeZone: "Europe/Zurich"`:

- The `start.dateTime` and `end.dateTime` fields are returned **already converted to the requested timezone** (Europe/Zurich = Geneva). So `"dateTime": "2026-06-01T16:00:00"` from a `timeZone: Europe/Zurich` query means **16:00 Geneva time**, regardless of what the inner `start.timeZone` field says.
- The `start.timeZone` field on the event is the EVENT'S NATIVE timezone — where the organizer created it. It is **NOT** a hint about how to interpret `dateTime`. An event with `"start.dateTime": "2026-06-01T16:00:00"` and `"start.timeZone": "America/Chicago"` queried with `timeZone: Europe/Zurich` is at **16:00 Geneva = 09:00 Austin**, not 16:00 Austin.
- To get the Austin (CDT) time: take the Geneva time and **subtract 7 hours** (CEST = UTC+02:00, CDT = UTC-05:00, difference = 7 hours). In standard time periods (CET/CST), the difference is still 7 hours.
- Worked example: `dateTime = "2026-06-01T16:00:00"` from a Zurich-tz query → 16:00 CEST → 09:00 CDT. Never the other direction.
- Sanity-check rule: if your computed Austin time is **later in the day than** the Geneva time, you've inverted the conversion. Austin is always 7 hours behind Geneva.
- If 0 external calls (after the filters above): post a brief "no external calls [target day]" Slack DM and stop. Don't post to the public channel — no need to broadcast a zero.

## Step 1.5 — Dedup check (CRITICAL — runs before fan-out for each call)

For EACH identified call, check if a brief already exists in `<output_dir>`:

```bash
ls "<output_dir>" | grep -i "Brief.*<Company>.*<YYYY-MM-DD>"
```

Match by **name pattern** (company + date) regardless of extension. Three cases:

**Case A — Matching `.docx` exists (our format, from a prior run today):**
- **Skip fan-out + generation.** The existing DOCX is already our polished format.
- Use the existing file's Drive URL in Slack outputs. Tag the line with `(existing)`.

**Case B — Matching `.gdoc` or `.html` exists (plugin format or older format, NOT our format):**
- **Delete the existing file** via `rm "<output_dir>/<filename>"`. The local delete syncs up to Drive within a minute. (`.gdoc` is a small pointer file; the underlying Google Doc moves to Drive trash when the pointer is removed and can be restored if needed.)
- **Then proceed to Step 2 (fan-out + DOCX generation)** to produce the polished format. The Slack output uses the new `.docx` file's URL.
- Tag the line with `(replaced — was plugin format)` so the reader knows what happened.

**Case C — No matching brief exists:**
- Proceed to Step 2 normally (fresh generation).

**Why this matters:** the pm-call-prep plugin generates `.gdoc` files in old-style format that don't render with proper headings/tables/lists. This skill's `.docx` output converts cleanly to Google Doc with full formatting. Deleting and regenerating ensures the brief in the folder is always the better format. If you don't want this behavior (e.g., to preserve plugin files), modify the dedup logic above.

## Step 2 — For each call: fan out data sources

Run in parallel (single message, multiple tool uses). Don't serialize.

| Source | Tool | What to pull |
|---|---|---|
| Glean | `mcp__a52ac0c2-...__search` | Company name, broad sweep. Surfaces Salesforce account records + anything indexed company-wide. |
| Zoom | `mcp__9dcd6671-...__search_meetings` + `get_meeting_assets` | Past call transcripts/recordings with this customer. Summarize last 2–3. |
| Gmail | `mcp__915b50f9-...__search_threads` | Threads with this customer's domain in the last 30–60 days. Subjects + brief summaries. |
| Confluence (Rovo) | `mcp__200a7382-...__search` | Pages mentioning the company — prioritize Research, CS, Growth spaces. |
| Jira (Rovo) | `mcp__200a7382-...__search` | Issues filed by or tagged with this customer. |
| Mixpanel | `mcp__6f09e2ef-...__Run-Query` | Usage patterns for the org if scopeable. |
| SonarData / Atlan | `mcp__954cc09e-...__query_assets_tool` | See **SonarData queries** below — chained Q1→Q2→Q3 with health-signal flags. |

In batch mode, you can parallelize across calls too — each call's fan-out independent of the others. Cap parallel calls if memory is a concern.

If a source errors or returns nothing, note it in the brief's "sources missing" footer — don't silently drop.

### Filtering rules for unstructured sources

Every line in the brief should be something the PM running the call would want to know — not raw search results. Filter aggressively:

- **Slack:** include only deal-close threads (`team-sales-*`), support escalations (`team-support-*`), customer-named channels, and content from `ask-sonarcloud` / `ask-support`. **Exclude** DMs between Sonar employees and threads where the customer name appears incidentally (benchmarking, internal strategy, tool testing).
- **Gmail:** prioritize threads with at least one external attendee from the customer's domain. Skip newsletters, automated notifications, and threads where the customer was only CC'd.
- **Confluence:** prefer Research, CS, Growth, and Support spaces. Skip generic internal templates that happen to mention the company.
- **Zoom:** only past calls where the customer was a participant. Skip internal-only Sonar meetings that mentioned the company.

### SonarData queries (chained — fire each as its prereq returns)

Run against `sonarsource.sonar` via Atlan / Redshift. Try name variations: full company name, common abbreviations, organization key. Expect ~30% mismatch between Salesforce account name and SQC enterprise name — try both.

**Q1 — Enterprise-level usage (fire first):**

```sql
SELECT
  enterprise_name, enterprise_uuid, organization_count,
  active_organization_count, nb_of_projects, nb_of_active_projects,
  nb_of_billable_ncloc, nb_of_active_ncloc, nb_of_ncloc,
  nb_of_users, nb_of_active_users, nb_of_scan_last_30_days,
  nb_of_issue_fixed_last_30_days, first_analysis_date,
  last_analysis_date, is_active_enterprise, data_timestamp
FROM sonarsource.sonar.cad_sqc_latest_customer_product_usage
WHERE LOWER(enterprise_name) LIKE '%<customer_keyword>%'
```

**Q2 — Per-organization breakdown (fire as soon as Q1 returns `enterprise_uuid`):**

```sql
SELECT DISTINCT
  organization_uuid_v4, customer_name, billed_product_name,
  adjusted_sonar_plan, nb_of_ncloc, nb_of_users,
  is_active_organization, creation_date, first_analysis_date,
  last_analysis_date, instance_status
FROM sonarsource.sonar.fct_sc_organization
WHERE enterprise_uuid = '<enterprise_uuid>'
  AND processing_time = (
    SELECT MAX(processing_time) FROM sonarsource.sonar.fct_sc_organization
    WHERE enterprise_uuid = '<enterprise_uuid>'
  )
```

**Q3 — Language distribution (fire as soon as Q2 returns an active `organization_uuid_v4`):**

```sql
SELECT
  l.language_name,
  SUM(l.nb_of_largest_branch_ncloc) AS total_ncloc,
  COUNT(DISTINCT l.project_id) AS nb_projects
FROM sonarsource.sonar.fct_sc_language_by_project_last_6_months l
JOIN sonarsource.sonar.fct_sc_organization o
  ON l.organization_id = o.organization_id
WHERE o.organization_uuid_v4 = '<active_org_uuid_v4>'
  AND l.data_timestamp = (
    SELECT MAX(data_timestamp) FROM sonarsource.sonar.fct_sc_language_by_project_last_6_months
  )
  AND l.is_active_project = true
GROUP BY 1
ORDER BY total_ncloc DESC
LIMIT 15
```

**Data caveats — read before quoting numbers in the brief:**

- `cad_sqc_latest_customer_product_usage` is the authoritative source for billable NCLOC, project counts, and scan volume. Always query it first.
- `fct_sc_organization` is a date-spine table (~357M rows). Always filter to `MAX(processing_time)` or `DISTINCT`, otherwise the brief lists duplicates.
- `total_ncloc` from Q3 is inflated due to the date-spine join. Use project counts and relative percentages for language share. For absolute lines of code, use `nb_of_billable_ncloc` from Q1.
- If Q1 returns nothing, the customer is likely on a Team or Free plan. Query `fct_sc_organization` directly (Q2 shape, without the `enterprise_uuid` filter) using the customer name.

### Health signals to flag in standout findings

After SonarData returns, compute these and surface whichever apply at the top of the brief — not buried in the data section:

| Signal | Condition | Frame as |
|---|---|---|
| **Expansion** | `nb_of_billable_ncloc / contracted_ncloc > 85%` | Growth conversation opportunity — they're approaching their cap |
| **Churn risk** | `last_analysis_date` more than 30 days before today | Adoption risk — usage has gone quiet |
| **Low seat adoption** | `nb_of_active_users / nb_of_users < 50%` | Seat utilization weak — fewer than half of paid seats are active |
| **Low scan cadence** | `nb_of_scan_last_30_days / nb_of_active_projects < 5` | Projects aren't being scanned regularly — possible CI integration gap |
| **New deal / onboarding** | `first_analysis_date` within last 90 days | Onboarding-stage — bias the conversation toward activation, not expansion |

Plain-language framing in the brief: "Lines of code at 92% of contracted — expansion conversation" rather than "billable NCLOC utilization 0.92".

## Step 3 — For each call: build the JSON payload

Synthesize gathered data into a JSON object per the schema documented at the top of `<helper_script>`. Omit sections with no data — better than empty content.

Voice: specific over generic, numbers + dates + names, no filler. Follow project CLAUDE.md voice rules.

**Never include meta-context** about who requested the brief, why this skill was invoked, what tools ran, or anything about Claude's role in producing it. The brief reads as a standalone document — the reader (the PM running the call, plus any internal attendees who get the link) doesn't need to know how it was generated.

**Lead with the standout findings** computed in Step 2's health-signal table. The first thing the reader sees should be 2-4 bullets at exec-altitude — expansion / churn / activation signals + anything noteworthy from past calls or open tickets. Detail sections come after.

## Step 4 — For each call: generate the DOCX

Write JSON to `/tmp/call-prep-<company-slug>-<timestamp>.json`. Then run:

```bash
uv run --with python-docx python "<helper_script>" "/tmp/call-prep-<company-slug>-<timestamp>.json" "<output_dir>/<filename>"
```

**Filename convention** (matching pm-call-prep plugin):

```
Brief — <Company> (<Key Attendee>) — <YYYY-MM-DD HH:MM>.docx
```

Examples:
- `Brief — Avery Dennison (Izzy Tejada) — 2026-06-01 23:00.docx`
- `Brief — Excentia (Mario Bastardo) — 2026-06-02 00:30.docx`

Use the meeting's start time in CEST. If multiple briefs for the same company same day, that's fine — different timestamps disambiguate.

## Step 5 — Post output

### Single-call mode (chat reply)

Reply in chat (no emojis, Growth team voice):

```
Brief saved: <output_dir>/<filename>

To open as a Google Doc:
1. Open Drive → Sonar Call Briefs folder
2. Right-click the file → Open with Google Docs

Standout findings:
- <one-line finding>
- <one-line finding>
- <one-line finding>

Sources pulled: <list>. Missing: <list>.
```

Pick 2-3 standout findings worth knowing pre-call — the kind of thing you'd Slack yourself 5 min before the meeting.

### Batch mode (Slack DM + public channel post)

**Step 5a — Resolve Drive URLs.** For each brief (newly generated OR dedup-matched existing one), get its Drive file URL. Use `mcp__69638a02-...__search_files` to find the file by name, then construct: `https://drive.google.com/file/d/<FILE_ID>/view`.

**Step 5b — Resolve internal attendee Slack IDs.** For each call, build the full internal attendee list. **Include ALL `@sonarsource.com` people on the invite**, regardless of whether they're marked optional or whether they're the user running the skill (yes, ping yourself — you're attending). The ONLY people to exclude are those whose `responseStatus` is `declined`. Concretely:

- Include: `accepted`, `tentative`, `needsAction` — whether required or optional, organizer or attendee, self or other.
- Exclude: `declined` (whether optional or required).
- Exclude: resource calendars / rooms (they have `resource: true`).

Look up Slack user IDs for each remaining attendee via `mcp__eb354c09-...__slack_search_users` (query = email address). Cache results within the run — multiple calls often share attendees. If a lookup fails, fall back to the person's name in plain text (no `<@...>` syntax).

**Step 5c — Post Slack DM to the user's own ID.** Use `mcp__eb354c09-...__slack_send_message` with the user's own Slack user ID as `channel_id`. Resolve the user_id in this order — stop at the first one that works:

1. **Check the `slack_send_message` tool description.** Some Claude environments surface the logged-in user's `user_id` directly in the tool description (e.g. "the current logged in user's user_id is U07B8J4FMNE"). If present, use it.
2. **Look up by email** via `mcp__eb354c09-...__slack_search_users` with the user's `@sonarsource.com` email (derived from `$USER` in Step 0: `<firstname.lastname>@sonarsource.com`). Use the returned `user_id`.
3. **Known fallbacks** (only if 1 and 2 fail): Simone = `U07B8J4FMNE`. For other teammates, add their ID here as the skill gets adopted.

**Self-DM doesn't notify.** Slack does NOT fire push/banner notifications for self-DMs. The message lands in the user's "you to you" sidebar entry. The user sees it next time they open Slack, not as a banner. That's expected — not a bug. The message is still delivered and linkable.

DM format — no @-mentions in the DM:

```
*Customer call prep — <Weekday>, <Mon DD>*

<N> customer calls <today|tomorrow> · briefs ready

• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Attendee>) — <Drive URL with text "Brief">
• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Attendee>) — <Drive URL with text "Brief">  (existing)
• ...

_Right-click each `.docx` in Drive → Open with Google Docs for the polished view._
```

Header uses Slack `*bold*` with an em-dash (`—`) between "Customer call prep" and the date — matches the format Simone prefers.

Timestamp format: Geneva (CEST, Europe/Zurich) first, then Austin (CDT, America/Chicago), separated by ` / `. The team is split between Geneva and Austin — both timezones matter at a glance.

Use `today` when briefs are for the current day, `tomorrow` when they're for the next day (the scheduled batch run is usually next-day).

If a brief was dedup-matched (not freshly generated), append `(existing)` to the line so the reader knows.

**Step 5d — Post public channel summary to #pm-call-brief.** Use `mcp__eb354c09-...__slack_send_message` with `channel_id: "C0B15DUDQDT"`. Same header style as 5c, with internal attendee @-mentions per call:

```
*Customer call prep — <Weekday>, <Mon DD>*

<N> customer calls <today|tomorrow> · briefs ready

• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Customer Attendee>) — <Drive URL with text "Brief"> · <@U_INTERNAL1> <@U_INTERNAL2> <@U_SELF>
• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Customer Attendee>) — <Drive URL with text "Brief"> · <@U_INTERNAL1> <@U_INTERNAL3> <@U_SELF>
• ...

_Right-click each `.docx` in Drive → Open with Google Docs for the polished view._
```

Use Slack `*bold*` and `_italic_`. Timestamp format: Geneva (CEST) first, then Austin (CDT), separated by ` / `. The `<@USER_ID>` syntax pings internal attendees so they get a notification. List ALL internal attendees per the Step 5b inclusion rules — that means everyone on the invite who didn't decline, **including the user running the skill** and **optional attendees who haven't declined**.

If a brief was dedup-matched (already existed), still post to the channel with the link — but append `(existing)` so attendees know it wasn't freshly regenerated.

If 0 calls found tomorrow: short DM saying "No external customer calls tomorrow." Do NOT post to the channel (no need to broadcast a zero).

If a brief failed to generate (source error): include it in BOTH the DM and channel post with "(brief failed — manual prep needed)" instead of a link.

**Step 5e — Belt-and-suspenders per-attendee DMs.** The channel post pings everyone, but a teammate on PTO / DND / who isn't a member of `#pm-call-brief` may miss it. After the channel post lands, DM each non-self internal attendee directly with their own brief link(s).

For each unique Slack user ID surfaced in Step 5b (excluding the user running the skill — they already got the full summary in Step 5c):

1. Collect every brief where this person is an internal attendee.
2. Send ONE DM per person (not one per call — group their briefs together to avoid spam).
3. Use `mcp__eb354c09-...__slack_send_message` with `channel_id` = their Slack user ID.

DM format (single brief):

```
*Customer call prep — <Weekday>, <Mon DD>*

You're on 1 external customer call <today|tomorrow>:

• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Customer Attendee>) — <Drive URL with text "Brief">

_Right-click each `.docx` in Drive → Open with Google Docs for the polished view._
```

DM format (multiple briefs — same person on 2+ calls):

```
*Customer call prep — <Weekday>, <Mon DD>*

You're on <N> external customer calls <today|tomorrow>:

• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Customer Attendee>) — <Drive URL with text "Brief">
• <HH:MM CEST> / <HH:MM CDT> · _<Company>_ (<Customer Attendee>) — <Drive URL with text "Brief">

_Right-click each `.docx` in Drive → Open with Google Docs for the polished view._
```

Mark `(existing)` on lines matching dedup'd briefs, same as in 5c and 5d.

If a per-attendee DM fails for one person, log it and continue — don't let one bad DM block the others.

**Step 5f — Failure handling for posts:** If the channel post fails (permission, channel not found), the user DM (5c) and per-attendee DMs (5e) still go out. Note the channel post failure in the user's summary DM as a footnote. If a per-attendee DM fails (user not found, deactivated, etc.), note which attendees missed out in the user's summary DM.

## Step 6 — (Optional) Clean up the temp JSON files

Delete `/tmp/call-prep-*.json` after the DOCXs are generated. Not critical (it's in /tmp), but tidy.

## Edge cases

- **New prospect, no history:** produce the brief anyway, flag relationship sections as empty.
- **Ambiguous company name:** if Glean returns multiple matching accounts, disambiguate before fanning out.
- **Internal meeting mis-identified:** if all attendees are `@sonarsource.com`, skip in batch mode (don't generate a brief). In single-call mode, stop and confirm.
- **Sparse data across all sources:** still produce the brief, but note in chat (single mode) or summary (batch mode) — this is a signal to adjust expectations.
- **Helper script fails:** if `uv` isn't installed or python-docx fails, fall back to writing JSON as markdown directly into `<output_dir>/<filename>.md` so the brief isn't lost.
- **Output folder doesn't exist:** the user hasn't synced the `TM_Product_All` shared drive. Stop and instruct them to add it via Google Drive UI; do not write briefs anywhere else.

## Why DOCX instead of native Google Doc

The Google Drive MCP doesn't auto-convert most upload types to Google Docs. DOCX is the cleanest path: standard Word document with proper formatting, Drive's well-supported DOCX → Google Doc conversion preserves everything. One right-click in Drive is the cost. The plugin (pm-call-prep, via Glean GTM Agents) produces native Google Docs directly because Glean has different output capabilities.

## Team scale

Once polished from real use, this skill can be ported to update the `pm-call-prep` Anthropic plugin (which Simone authored) via ITOps so the whole company benefits from improved formatting + DOCX conversion path.

---

## Appendix A — Embedded fallback for `call-prep-to-docx.py`

If `<skill_dir>/call-prep-to-docx.py` is missing (per the Step 0 check), write the contents below verbatim to `/tmp/call-prep-to-docx.py` and use that path as `helper_script`. Keep this in sync with the canonical script at `<skill_dir>/call-prep-to-docx.py` — any change to one should be reflected in the other.

```python
"""Generate a customer call prep DOCX from a JSON payload.

Usage:
    uv run --with python-docx python call-prep-to-docx.py <input.json> <output.docx>

Or pass JSON via stdin and output path as the only argument:
    cat brief.json | uv run --with python-docx python call-prep-to-docx.py - <output.docx>

The output DOCX uploads cleanly to Google Drive — right-click → "Open with Google Docs"
preserves headings, tables, lists, bold, and italic formatting.

JSON schema (all fields optional; missing sections are skipped):
{
  "company": "Acme Corp",
  "meeting_date": "Monday, 1 June 2026, 14:00 CET",
  "call_type": "Quarterly business review",
  "attendees": {
    "internal": ["Name (Role)", ...],
    "customer": ["Name (Role)", ...]
  },
  "account_snapshot": {
    "fields": [["Size", "..."], ["Plan", "..."], ...],
    "health_pill": "At risk"  // optional, appears as a bracketed label after section title
  },
  "usage": ["bullet 1", "bullet 2", ...],
  "relationship_history": {
    "past_calls": [["YYYY-MM-DD", "summary"], ...],
    "email_threads": ["subject — sender, when", ...],
    "jira_tickets": ["KEY title status", ...]
  },
  "what_we_know": ["bullet 1", ...],
  "hypotheses": ["hypothesis 1", "hypothesis 2", ...],
  "open_questions": ["question 1", "question 2", ...],
  "interview_arc": [["Opening (3 min)", "description"], ...],
  "handle_with_care": "single paragraph",
  "sources": {
    "pulled": ["Glean", "Zoom", ...],
    "missing": ["Mixpanel", ...]
  }
}
"""

from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

from docx import Document
from docx.shared import Pt, RGBColor


# --- styling helpers --------------------------------------------------------

def add_heading_with_pill(doc, text, pill_text=None, pill_color_hex="C00000"):
    h = doc.add_heading(text, level=2)
    if pill_text:
        run = h.add_run(f"  [{pill_text}]")
        run.bold = True
        run.font.color.rgb = RGBColor.from_string(pill_color_hex)
        run.font.size = Pt(11)


def add_kv_table(doc, rows):
    """Two-column key-value table."""
    if not rows:
        return
    table = doc.add_table(rows=len(rows), cols=2)
    table.style = "Light Grid Accent 1"
    for i, (key, val) in enumerate(rows):
        cells = table.rows[i].cells
        cells[0].text = str(key)
        for run in cells[0].paragraphs[0].runs:
            run.bold = True
        cells[1].text = str(val)


def add_bullets(doc, items, style="List Bullet"):
    for item in items:
        doc.add_paragraph(str(item), style=style)


def add_numbered(doc, items):
    add_bullets(doc, items, style="List Number")


# --- main generator ---------------------------------------------------------

def build_doc(data: dict, output_path: str):
    doc = Document()

    # --- Title block ---
    company = data.get("company", "[Customer]")
    doc.add_heading(f"Customer Call Prep — {company}", level=1)

    meta_lines = []
    if data.get("meeting_date"):
        meta_lines.append(("Date", data["meeting_date"]))
    if data.get("call_type"):
        meta_lines.append(("Call type", data["call_type"]))
    attendees = data.get("attendees") or {}
    if attendees.get("internal"):
        meta_lines.append(("Attendees (internal)", ", ".join(attendees["internal"])))
    if attendees.get("customer"):
        meta_lines.append(("Attendees (customer)", ", ".join(attendees["customer"])))
    if meta_lines:
        meta_p = doc.add_paragraph()
        for i, (label, value) in enumerate(meta_lines):
            if i > 0:
                meta_p.add_run("\n")
            meta_p.add_run(f"{label}: ").bold = True
            meta_p.add_run(str(value))

    # --- 1. Account snapshot ---
    snapshot = data.get("account_snapshot") or {}
    if snapshot.get("fields"):
        add_heading_with_pill(
            doc, "1. Account snapshot",
            pill_text=snapshot.get("health_pill"),
        )
        add_kv_table(doc, snapshot["fields"])

    # --- 2. Usage at a glance ---
    if data.get("usage"):
        doc.add_heading("2. Usage at a glance", level=2)
        add_bullets(doc, data["usage"])

    # --- 3. Relationship history ---
    rel = data.get("relationship_history") or {}
    if rel.get("past_calls") or rel.get("email_threads") or rel.get("jira_tickets"):
        doc.add_heading("3. Relationship history", level=2)

        if rel.get("past_calls"):
            doc.add_heading("Past calls", level=3)
            for date, summary in rel["past_calls"]:
                p = doc.add_paragraph(style="List Bullet")
                p.add_run(str(date)).bold = True
                p.add_run(f" — {summary}")

        if rel.get("email_threads"):
            doc.add_heading("Recent email threads", level=3)
            add_bullets(doc, rel["email_threads"])

        if rel.get("jira_tickets"):
            doc.add_heading("Jira tickets", level=3)
            add_bullets(doc, rel["jira_tickets"])

    # --- 4. What we already know ---
    if data.get("what_we_know"):
        doc.add_heading("4. What we already know", level=2)
        add_bullets(doc, data["what_we_know"])

    # --- 5. Hypotheses ---
    if data.get("hypotheses"):
        doc.add_heading("5. Hypotheses going in", level=2)
        add_numbered(doc, data["hypotheses"])

    # --- 6. Open questions ---
    if data.get("open_questions"):
        doc.add_heading("6. Open questions to probe", level=2)
        add_bullets(doc, data["open_questions"])

    # --- 7. Suggested interview arc ---
    if data.get("interview_arc"):
        doc.add_heading("7. Suggested interview arc", level=2)
        for label, text in data["interview_arc"]:
            p = doc.add_paragraph(style="List Bullet")
            p.add_run(f"{label}:").bold = True
            p.add_run(f" {text}")

    # --- 8. Handle with care ---
    if data.get("handle_with_care"):
        doc.add_heading("8. Handle with care", level=2)
        p = doc.add_paragraph()
        run = p.add_run(str(data["handle_with_care"]))
        run.italic = True

    # --- Footer: sources ---
    sources = data.get("sources") or {}
    if sources.get("pulled") or sources.get("missing"):
        doc.add_paragraph("─" * 60)
        footer = doc.add_paragraph()
        parts = []
        if sources.get("pulled"):
            parts.append(f"Sources pulled: {', '.join(sources['pulled'])}.")
        if sources.get("missing"):
            parts.append(f"Missing / empty: {', '.join(sources['missing'])}.")
        run = footer.add_run(" ".join(parts))
        run.italic = True
        run.font.size = Pt(9)

    # Atomic write: save to a temp file on local disk, then move to the final
    # destination. python-docx writes a ZIP (the .docx) in streaming fashion —
    # entries first, central directory last. Writing directly into a Google
    # Drive-synced folder can produce a truncated ZIP (missing End-of-Central-
    # Directory record) because Drive sync may snapshot partial bytes before
    # save() finishes. Saving to /tmp and then moving guarantees Drive only
    # ever sees a complete file.
    tmp_fd, tmp_path = tempfile.mkstemp(suffix=".docx", prefix="call-prep-", dir="/tmp")
    os.close(tmp_fd)
    try:
        doc.save(tmp_path)
        shutil.move(tmp_path, output_path)
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def main():
    if len(sys.argv) < 3:
        print(
            "Usage: python call-prep-to-docx.py <input.json|-> <output.docx>",
            file=sys.stderr,
        )
        sys.exit(2)

    input_arg = sys.argv[1]
    output_path = sys.argv[2]

    if input_arg == "-":
        data = json.load(sys.stdin)
    else:
        with open(input_arg, "r", encoding="utf-8") as f:
            data = json.load(f)

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    build_doc(data, output_path)
    print(f"DOCX saved: {output_path}")


if __name__ == "__main__":
    main()
```
